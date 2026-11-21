import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/update_widget_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_station_order_list_response.dart';
// import 'package:mygenie_restaurant/data/model/response/get_pos_order_list_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/base/food_item_action_button.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/widget/kds_order_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
// import 'package:timeago/timeago.dart' as timeago;

class KdsOrderList extends StatelessWidget {
  final Orders order;
  int? orderStatus;
  final PrinterManager printerManager;
  List<int>? pendingTask;
  final FlutterTts flutterTts;
  final Function isPrintKot;

  final BTStatus blutoothStatus;
  KdsOrderList({
    Key? key,
    required this.order,
    this.orderStatus,
    required this.printerManager,
    this.pendingTask,
    required this.flutterTts,
    required this.blutoothStatus,
    required this.isPrintKot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // DateTime tempDate = DateTime.parse(order.createdAt);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
          color: order.orderDetailsOrder!.orderType == 'delivery'
              ? Color.fromRGBO(253, 237, 237, 1)
              : order.orderDetailsOrder!.orderType == 'take_away'
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantTable == null ||
                                order.restaurantTable!.tableNo == ''
                            ? order.orderDetailsOrder!.orderType == 'delivery'
                                ? 'Delivery'
                                : order.orderDetailsOrder!.orderType ==
                                        'take_away'
                                    ? 'Take Away'
                                    : 'WC'
                            : order.restaurantTable!.title == ''
                                ? '#${order.restaurantTable!.tableNo}'
                                : '#${order.restaurantTable!.title}-${order.restaurantTable!.tableNo}',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 15, color: Colors.black),
                        maxLines: 2,
                      ),
                      Text(
                        '${order.restaurantTable!.restaurantWaiterName ?? ''}',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                  Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .settings!
                                              .useDisplayToken ==
                                          'Yes'
                                      ? '${order.orderDetailsOrder?.restaurantOrderId} (${order.orderDetailsOrder?.tokenNo})'
                                      : '${order.orderDetailsOrder?.restaurantOrderId}',
                   
                        style: poppinsBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color: Colors.black),
                      ),
                      if ((order.orderDetailsOrder?.userId != null) ||
                          (order.orderDetailsOrder?.username ?? '') != '')
                        Text(
                          order.orderDetailsOrder?.userId != null
                              ? (order.user?.phone == '+919579504871'
                                  ? ''
                                  : (order.orderDetailsOrder?.username ?? '') !=
                                          ''
                                      ? (order.orderDetailsOrder?.username ??
                                          '')
                                      : '${order.user?.fName ?? ''} ${order.user?.lName ?? ''}')
                              : (order.orderDetailsOrder?.username ?? ''),
                          style: poppinsMedium.copyWith(
                              fontSize: 11, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                    ],
                  ),
                ),
                order.orderDetailsOrder!.orderType == 'delivery'
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: InkWell(
                            onTap: () async {
                              showAddressDialog(order);
                            },
                            child: Icon(CupertinoIcons.location_solid,
                                color: ColorTheme.appColor)),
                      )
                    : SizedBox(width: 40),
              ],
            ),
          ),

          SizedBox(height: 9),
          Divider(color: ColorTheme.hintText, height: 1),
          // MediaQuery.of(context).size.shortestSide > 600
          //     ? KdsTabletOrderItemList(
          //         flutterTts: flutterTts,
          //         orderStatus: orderStatus,
          //         orderItemList: order.orderDetails,
          //         order: order)
          //     :
          KdsOrderItemList(
              flutterTts: flutterTts,
              orderStatus: orderStatus,
              orderItemList: order.orderDetailsFood ?? [],
              order: order),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          order.orderDetailsOrder!.orderNote == null ||
                  order.orderDetailsOrder!.orderNote == ''
              ? SizedBox.shrink()
              : SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          order.orderDetailsOrder!.orderNote == null ||
                  order.orderDetailsOrder!.orderNote == ''
              ? SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Notes: ',
                            style: poppinsMedium.copyWith(
                                fontSize: 10,
                                color: ColorTheme.kdsLeftMenuBlue),
                          ),
                          TextSpan(
                            text: ' ${order.orderDetailsOrder!.orderNote}',
                            style: poppinsMedium.copyWith(
                                fontSize: 10, color: ColorTheme.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          Row(
            children: [
              GetBuilder<UpdateWidgetController>(builder: (updateController) {
                return Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: InkWell(
                      onTap: () async {
                        if (updateController.orderId ==
                            order.orderDetailsOrder!.restaurantOrderId) {
                          updateController.updateWidget('');
                          await flutterTts.pause();
                        } else {
                          String speakString = '';
                          for (var d = 0;
                              d < order.orderDetailsFood!.length;
                              d++) {
                            OrderDetailsFood food = order.orderDetailsFood![d];
                            String variationText = '';
                            if (food.variation != null &&
                                food.variation!.isNotEmpty) {
                              for (int j = 0; j < food.variation!.length; j++) {
                                variationText +=
                                    '${variationText.isNotEmpty ? ', ' : ''}${food.variation![j].name ?? ''} (';

                                if (food.variation![j].values != null) {
                                  List<String> labelList = [];
                                  for (var element
                                      in food.variation![j].values!) {
                                    labelList.add(element.level ?? '');
                                  }
                                  variationText +=
                                      '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                }
                                variationText += ')';
                              }
                            }

                            String addons = '';
                            if (food.addOns != null) {
                              for (var i = 0; i < food.addOns!.length; i++) {
                                addons +=
                                    '(${food.addOns![i].qty ?? ''}) ${food.addOns![i].name ?? ''}';
                              }
                            }

                            speakString +=
                                "Item${d + 1}  ${food.foodDetails?.name ?? ''} ${food.quantity ?? ''},  ${addons == '' ? '' : "Add-Ons' ':''$addons"},  ${variationText == '' ? '' : "Variants  :$variationText"}";
                          }
                          if (speakString != '') {
                            Get.find<UpdateWidgetController>().updateWidget(
                                order.orderDetailsOrder?.restaurantOrderId ??
                                    '');

                            speak('$speakString');
                          }
                        }
                      },
                      child: Icon(
                          updateController.orderId ==
                                  order.orderDetailsOrder!.restaurantOrderId
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline_outlined,
                          size: 30,
                          color: ColorTheme.appColor)),
                );
              }),
              if (orderStatus != 7)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: InkWell(
                      onTap: () async {
                        Get.find<KdsController>().updateOrderIndex(
                            Get.find<KdsController>()
                                .getStationOrderListResponse!
                                .orders!
                                .indexOf(order));
                        isPrintKot(order);
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SvgPicture.asset(
                          Images.ic_print_kot,
                          height: 24,
                        ),
                      )),
                ),
              if (orderStatus == 7)
                InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Get.bottomSheet(
                      ConfirmationDialog(
                          icon: Images.support,
                          description:
                              'Are you sure you want to cancel the complete order?',
                          isLogOut: true,
                          onYesPressed: () async {
                            Map<String, dynamic> jsonBody = {
                              'order_id':
                                  order.orderDetailsOrder!.id.toString(),
                              'order_status': 'cancelled',
                              'role_name': 'Manager',
                              'stations': [
                                ...?order.orderDetailsFood
                                    ?.map((e) => e.station ?? ''),
                                ...?order.readyDetails
                                    ?.map((e) => e.station ?? ''),
                              ]
                                  .where((s) => s.isNotEmpty)
                                  .toSet()
                                  .toList(),
                            };
                            Get.back();
                            Get.find<KdsController>()
                                .changeOrderStatus(jsonBody, callback);
                          }),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child:
                        Icon(Icons.close, size: 35, color: ColorTheme.appColor),
                  ),
                ),
              Spacer(),
              // if (order.audioFile != null)
              // Padding(
              //   padding: const EdgeInsets.only(right: 10),
              //   child: InkWell(
              //     onTap: () async {
              //       if (order.audioFile != null) {
              //         await Get.dialog(
              //             PlayVoiceNoteDialoge(audio: order.audioFile));
              //       }
              //     },
              //     child: Icon(
              //       Icons.mic_none,
              //       color: ColorTheme.appColor,
              //       size: 30,
              //     ),
              //   ),
              // ),
              // InkWell(
              //   splashColor: Colors.transparent,
              //   hoverColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              //   onTap: () {
              //     Map<String, dynamic> jsonBody = {
              //       'order_id': order.id.toString(),
              //       'role_name': Get.find<AuthController>()
              //           .profileModel
              //           .role
              //           .first,
              //       'order_status': orderStatus == 1 ? 'ready' : 'cooking'
              //     };
              //     Get.find<KdsController>()
              //         .changeOrderStatus(jsonBody, callback);
              //   },
              //   child: Container(
              //     width: 110,
              //     padding:
              //         EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              //     decoration: BoxDecoration(
              //         border: Border.all(color: Colors.transparent),
              //         color: ColorTheme.appColor,
              //         // border:
              //         //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
              //         borderRadius: BorderRadius.circular(
              //             Dimensions.RADIUS_DEFAULT)),
              //     child: Center(
              //       child: Text(
              //         orderStatus == 1 ? 'ready'.tr : 'accept_all'.tr,
              //         style: poppinsMedium.copyWith(
              //             fontSize: Dimensions.FONT_SIZE_DEFAULT,
              //             color: Colors.white),
              //       ),
              //     ),
              //   ),
              // ),
              // if (Get.find<AuthController>()
              //             .profileModel
              //             .restaurants
              //             .first
              //             .defOrdStatus !=
              //         2 &&
              //     Get.find<AuthController>()
              //             .profileModel
              //             .restaurants
              //             .first
              //             .defOrdStatus !=
              //         5)
              if (orderStatus == 1 || orderStatus == 7)
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: FoodButton(
                    onTap: () async {
                      // _searchOrder.clear();
                      if (orderStatus == 7) {
                        FocusManager.instance.primaryFocus?.unfocus();

                        Map<String, dynamic> jsonBody = {
                          'order_id': order.orderDetailsOrder!.id.toString(),
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
                          'role_name':
                              Get.find<AuthController>().profileModel!.roleName,
                        };
                        await Get.find<KdsController>().acceptOrderStatus(
                            jsonBody, (bool isSuccess, String message) async {
                          if (isSuccess) {
                            // showToast(message);
                          } else {
                            // showCustomSnackBar(message);
                          }
                        });
                      } else {
                        Map<String, dynamic> jsonBody = {
                          'order_id': order.orderDetailsOrder!.id.toString(),
                          'role_name':
                              Get.find<AuthController>().profileModel!.roleName,
                          'order_status': orderStatus == 1 ? 'ready' : 'cooking'
                        };
                        Get.find<KdsController>()
                            .changeOrderStatus(jsonBody, callback);
                      }
                    },
                    title: orderStatus == 7
                        ? 'Confirm'
                        : orderStatus == 1
                            ? 'ready'.tr
                            : 'accept_all'.tr,
                  ),
                ),
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
                if (orderStatus != 7 && orderStatus != 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FoodButton(
                        isDisable: true,
                        onTap: () {},
                        title: 'Serve',
                      ),
                    ),
                  )
              // if (order.audioFile != null)
              //   Padding(
              //     padding: const EdgeInsets.only(left: 10),
              //     child: InkWell(
              //       onTap: () async {
              //         if (order.audioFile != null) {
              //           await Get.dialog(
              //               PlayVoiceNoteDialoge(audio: order.audioFile));
              //         }
              //       },
              //       child: Image.asset(Images.ic_voice_note,
              //           height: 50, width: 50),
              //     ),
              //   ),
              // Get.find<KdsController>().selectedSubMenu == 0
              //     ? SizedBox(width: 10)
              //     : SizedBox.shrink()
            ],
          ),

          // if (orderStatus != 7 && orderStatus != 1)
          //   Padding(
          //     padding: const EdgeInsets.only(right: 18),
          //     child: Align(
          //       alignment: Alignment.centerRight,
          //       child: FoodButton(
          //         isDisable: true,
          //         onTap: () {},
          //         title: 'Serve',
          //       ),
          //     ),
          //   )
          // SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
        ],
      ),
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      // Get.find<KdsController>().startLoading();
      // Get.find<KdsController>().clearOrderList();
      // Get.find<KdsController>().getPOSOrderList();
      // showToast(message);
      // showCustomSnackBar(message, isError: false);
      // Get.find<OrderController>().stopLoader();

      // Get.offNamed(
      //     RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
    } else {
      // showCustomSnackBar(message);
    }
  }

  void showAddressDialog(Orders order) {
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
                      Text(
                          'Phone: ${order.deliveryAddress?.contactPersonNumber ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),
                      const SizedBox(height: 5),
                      // Text(
                      //     'Address type: ${order.deliveryAddress?.addressType ?? ''}',
                      //     style: poppinsMedium.copyWith(fontSize: 14)),
                      // const SizedBox(height: 5),
                      Text('Address: ${order.deliveryAddress?.address ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),
                      const SizedBox(height: 5),
                      Text(
                          'House No/Flat No.: ${order.deliveryAddress?.house ?? ''}',
                          style: poppinsMedium.copyWith(fontSize: 14)),
                      // Text('Pincode: ${order.deliveryAddress?.pincode ?? ''}',
                      //     style: poppinsMedium.copyWith(fontSize: 14)),
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

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      Get.find<UpdateWidgetController>().updateWidget('');
    });
  }
}

class KdsTabletOrderList extends StatelessWidget {
  final Orders order;
  int? orderStatus;
  final FlutterTts flutterTts;
  final Function isPrintKot;

  KdsTabletOrderList(
      {required this.order,
      this.orderStatus,
      required this.flutterTts,
      required this.isPrintKot});

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    DateTime tempDate = DateTime.parse(order.orderDetailsOrder!.createdAt!);
    return Container(
      height: Get.find<AuthController>()
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
          color: order.orderDetailsOrder!.orderType == 'delivery'
              ? Color.fromRGBO(253, 237, 237, 1)
              : order.orderDetailsOrder!.orderType == 'take_away'
                  ? Color.fromRGBO(220, 244, 192, 1)
                  : order.restaurantTable != null &&
                          order.restaurantTable!.rtype == 'RM'
                      ? ColorTheme.roomCardBgColor
                      : Color.fromRGBO(254, 245, 208, 1)),
      margin: EdgeInsets.only(top: 20, left: 10),
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantTable == null ||
                                order.restaurantTable?.tableNo == ''
                            ? order.orderDetailsOrder?.orderType == 'delivery'
                                ? 'Delivery'
                                : order.orderDetailsOrder?.orderType ==
                                        'take_away'
                                    ? 'Take Away'
                                    : 'WC'
                            : order.restaurantTable?.title == ''
                                ? '#${order.restaurantTable?.tableNo}'
                                : '#${order.restaurantTable?.title}-${order.restaurantTable?.tableNo}',
                        style: poppinsSemiBold.copyWith(
                            fontSize: 15, color: Colors.black),
                        maxLines: 2,
                      ),
                      Text(
                        '${order.restaurantTable?.restaurantWaiterName ?? ''}',
                        style: poppinsMedium.copyWith(
                            fontSize: 11, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .settings!
                                              .useDisplayToken ==
                                          'Yes'
                                      ? '${order.orderDetailsOrder?.restaurantOrderId} (${order.orderDetailsOrder?.tokenNo})'
                                      : '${order.orderDetailsOrder?.restaurantOrderId}',
                        style: poppinsBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color: Colors.black),
                      ),
                      if (order.orderDetailsOrder?.userId != null ||
                          (order.orderDetailsOrder?.username ?? '') != '')
                        Text(
                          order.orderDetailsOrder?.userId != null
                              ? (order.user?.phone == '+919579504871'
                                  ? ''
                                  : (order.orderDetailsOrder?.username ?? '') !=
                                          ''
                                      ? (order.orderDetailsOrder?.username ??
                                          '')
                                      : '${order.user?.fName ?? ''} ${order.user?.lName ?? ''}')
                              : (order.orderDetailsOrder?.username ?? ''),
                          style: poppinsMedium.copyWith(
                              fontSize: 11, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                    ],
                  ),
                ),
                order.orderDetailsOrder!.orderType == 'delivery'
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: InkWell(
                            onTap: () async {
                              showAddressDialog(order);
                            },
                            child: Icon(CupertinoIcons.location_solid,
                                color: ColorTheme.appColor)),
                      )
                    : SizedBox(width: 40),
              ],
            ),
          ),
          SizedBox(height: 9),
          Divider(color: ColorTheme.hintText, height: 1),
          // MediaQuery.of(context).size.shortestSide > 600
          //     ?
          KdsTabletOrderItemList(
              flutterTts: flutterTts,
              orderStatus: orderStatus,
              orderItemList: order.orderDetailsFood!,
              order: order),
          // :
          //  KdsOrderItemList(
          //     flutterTts: flutterTts,
          //     orderStatus: orderStatus,
          //     orderItemList: order.orderDetails,
          //     order: order),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     '${order.orderNote ?? ''}',
          //     style: poppinsMedium.copyWith(fontSize: 10, color: Colors.black),
          //   ),
          // ),
          order.orderDetailsOrder!.orderNote == null ||
                  order.orderDetailsOrder!.orderNote == ''
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Notes  :',
                            style: poppinsMedium.copyWith(
                                fontSize: 12,
                                color: ColorTheme.kdsLeftMenuBlue),
                          ),
                          TextSpan(
                            text: ' ${order.orderDetailsOrder!.orderNote}',
                            style: poppinsMedium.copyWith(
                                fontSize: 11, color: ColorTheme.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          order.orderDetailsOrder!.orderNote == null
              ? const SizedBox.shrink()
              : SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     Get.find<KdsController>().selectedSubMenu == 0
            //         ? MainAxisAlignment.spaceAround
            //         : MainAxisAlignment.center,
            children: [
              GetBuilder<UpdateWidgetController>(builder: (updateController) {
                return Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: InkWell(
                      onTap: () async {
                        if (updateController.orderId ==
                            order.orderDetailsOrder!.restaurantOrderId) {
                          updateController.updateWidget('');
                          await flutterTts.pause();
                        } else {
                          String speakString = '';
                          for (var d = 0;
                              d < (order.orderDetailsFood?.length ?? 0);
                              d++) {
                            final food = order.orderDetailsFood?[d];
                            String variationText = '';
                            if (food?.variation != null &&
                                food!.variation!.isNotEmpty) {
                              for (int j = 0;
                                  j < (food.variation?.length ?? 0);
                                  j++) {
                                final variation = food.variation![j];
                                variationText +=
                                    '${variationText.isNotEmpty ? ', ' : ''}${variation.name ?? ''} (';

                                if (variation.values != null) {
                                  List<String> labelList = [];
                                  for (var element in variation.values!) {
                                    labelList.add(element.level ?? '');
                                  }
                                  variationText +=
                                      '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                }
                                variationText += ')';
                              }
                            }

                            String addons = '';
                            if (food?.addOns != null) {
                              for (var i = 0;
                                  i < (food!.addOns?.length ?? 0);
                                  i++) {
                                final addOn = food.addOns![i];
                                addons +=
                                    '(${addOn.qty ?? ''}) ${addOn.name ?? ''}';
                              }
                            }

                            speakString +=
                                "Item${d + 1}  ${food?.foodDetails?.name ?? ''} ${food?.quantity ?? ''},  ${addons == '' ? '' : "Add-Ons' ':''$addons"},  ${variationText == '' ? '' : "Variants  :$variationText"}";
                          }
                          if (speakString != '') {
                            Get.find<UpdateWidgetController>().updateWidget(
                                order.orderDetailsOrder?.restaurantOrderId ??
                                    '');

                            speak('$speakString');
                          }
                        }
                      },
                      child: Icon(
                          updateController.orderId ==
                                  order.orderDetailsOrder!.restaurantOrderId
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline_outlined,
                          size: 40,
                          color: ColorTheme.appColor)),
                );
              }),
              if (orderStatus != 7)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: InkWell(
                      onTap: () async {
                        Get.find<KdsController>().updateOrderIndex(
                            Get.find<KdsController>()
                                .getStationOrderListResponse!
                                .orders!
                                .indexOf(order));
                        isPrintKot(order);
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SvgPicture.asset(
                          Images.ic_print_kot,
                          height: 30,
                        ),
                      )),
                ),
              if (orderStatus == 7)
                InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Get.bottomSheet(
                      ConfirmationDialog(
                          icon: Images.support,
                          description:
                              'Are you sure you want to cancel the complete order?',
                          isLogOut: true,
                          onYesPressed: () async {
                            Map<String, dynamic> jsonBody = {
                              'order_id':
                                  order.orderDetailsOrder!.id.toString(),
                              'order_status': 'cancelled',
                              'role_name': 'Manager',
                              'stations': [
                                ...?order.orderDetailsFood
                                    ?.map((e) => e.station ?? ''),
                                ...?order.readyDetails
                                    ?.map((e) => e.station ?? ''),
                              ]
                                  .where((s) => s.isNotEmpty)
                                  .toSet()
                                  .toList(),
                            };
                            Get.back();
                            Get.find<KdsController>()
                                .changeOrderStatus(jsonBody, callback);
                          }),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child:
                        Icon(Icons.close, size: 40, color: ColorTheme.appColor),
                  ),
                ),
              Spacer(),
              // if (order.audioFile != null)
              // Padding(
              //   padding: const EdgeInsets.only(right: 10),
              //   child: InkWell(
              //     onTap: () async {
              //       if (order.audioFile != null) {
              //         await Get.dialog(
              //             PlayVoiceNoteDialoge(audio: order.audioFile));
              //       }
              //     },
              //     child: Icon(
              //       Icons.mic_none,
              //       color: ColorTheme.appColor,
              //       size: 30,
              //     ),
              //   ),
              // ),
              // InkWell(
              //   splashColor: Colors.transparent,
              //   hoverColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              //   onTap: () {
              //     Map<String, dynamic> jsonBody = {
              //       'order_id': order.id.toString(),
              //       'role_name': Get.find<AuthController>()
              //           .profileModel
              //           .role
              //           .first,
              //       'order_status': orderStatus == 1 ? 'ready' : 'cooking'
              //     };
              //     Get.find<KdsController>()
              //         .changeOrderStatus(jsonBody, callback);
              //   },
              //   child: Container(
              //     width: 110,
              //     padding:
              //         EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              //     decoration: BoxDecoration(
              //         border: Border.all(color: Colors.transparent),
              //         color: ColorTheme.appColor,
              //         // border:
              //         //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
              //         borderRadius: BorderRadius.circular(
              //             Dimensions.RADIUS_DEFAULT)),
              //     child: Center(
              //       child: Text(
              //         orderStatus == 1 ? 'ready'.tr : 'accept_all'.tr,
              //         style: poppinsMedium.copyWith(
              //             fontSize: Dimensions.FONT_SIZE_DEFAULT,
              //             color: Colors.white),
              //       ),
              //     ),
              //   ),
              // ),
              if (orderStatus == 1 || orderStatus == 7)
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: FoodButton(
                    onTap: () async {
                      // _searchOrder.clear();
                      if (orderStatus == 7) {
                        FocusManager.instance.primaryFocus?.unfocus();

                        Map<String, dynamic> jsonBody = {
                          'order_id': order.orderDetailsOrder!.id.toString(),
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
                          'role_name':
                              Get.find<AuthController>().profileModel!.roleName,
                        };
                        await Get.find<KdsController>().acceptOrderStatus(
                            jsonBody, (bool isSuccess, String message) async {
                          if (isSuccess) {
                            // showToast(message);
                          } else {
                            // showCustomSnackBar(message);
                          }
                        });
                      } else {
                        Map<String, dynamic> jsonBody = {
                          'order_id': order.orderDetailsOrder!.id.toString(),
                          'role_name':
                              Get.find<AuthController>().profileModel!.roleName,
                          'order_status': orderStatus == 1 ? 'ready' : 'cooking'
                        };
                        Get.find<KdsController>()
                            .changeOrderStatus(jsonBody, callback);
                      }
                    },
                    title: orderStatus == 7
                        ? 'Confirm'
                        : orderStatus == 1
                            ? 'ready'.tr
                            : 'accept_all'.tr,
                  ),
                ),
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
                if (orderStatus != 7 && orderStatus != 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FoodButton(
                        isDisable: true,
                        onTap: () {},
                        title: 'Serve',
                      ),
                    ),
                  )
              // if (order.audioFile != null)
              // Padding(
              //   padding: const EdgeInsets.only(right: 10),
              //   child: InkWell(
              //     onTap: () async {
              //       if (order.audioFile != null) {
              //         await Get.dialog(
              //             PlayVoiceNoteDialoge(audio: order.audioFile));
              //       }
              //     },
              //     child: Icon(
              //       Icons.mic_none,
              //       color: ColorTheme.appColor,
              //       size: 30,
              //     ),
              //   ),
              // ),
              // InkWell(
              //   splashColor: Colors.transparent,
              //   hoverColor: Colors.transparent,
              //   highlightColor: Colors.transparent,
              //   onTap: () {
              //     Map<String, dynamic> jsonBody = {
              //       'order_id': order.id.toString(),
              //       'role_name': Get.find<AuthController>()
              //           .profileModel
              //           .role
              //           .first,
              //       'order_status': orderStatus == 1 ? 'ready' : 'cooking'
              //     };
              //     Get.find<KdsController>()
              //         .changeOrderStatus(jsonBody, callback);
              //   },
              //   child: Container(
              //     width: 110,
              //     padding:
              //         EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              //     decoration: BoxDecoration(
              //         border: Border.all(color: Colors.transparent),
              //         color: ColorTheme.appColor,
              //         // border:
              //         //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
              //         borderRadius: BorderRadius.circular(
              //             Dimensions.RADIUS_DEFAULT)),
              //     child: Center(
              //       child: Text(
              //         orderStatus == 1 ? 'ready'.tr : 'accept_all'.tr,
              //         style: poppinsMedium.copyWith(
              //             fontSize: Dimensions.FONT_SIZE_DEFAULT,
              //             color: Colors.white),
              //       ),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(right: 18),
              //   child: FoodButton(
              //     onTap: () async {
              //       // _searchOrder.clear();
              //       if (orderStatus == 7) {
              //         FocusManager.instance.primaryFocus?.unfocus();

              //         Map<String, dynamic> jsonBody = {
              //           'order_id': order.id.toString(),
              //           'order_status': Get.find<AuthController>()
              //                       .profileModel
              //                       .restaurants
              //                       .first
              //                       .defOrdStatus ==
              //                   0
              //               ? 'new'
              //               : Get.find<AuthController>()
              //                           .profileModel
              //                           .restaurants
              //                           .first
              //                           .defOrdStatus ==
              //                       1
              //                   ? 'cooking'
              //                   : 'ready',
              //           'role_name':
              //               Get.find<AuthController>().profileModel.role.first,
              //         };
              //         await Get.find<KdsController>().acceptOrderStatus(
              //             jsonBody, (bool isSuccess, String message) async {
              //           if (isSuccess) {
              //             // showToast(message);
              //           } else {
              //             // showCustomSnackBar(message);
              //           }
              //         });
              //       } else {
              //         Map<String, dynamic> jsonBody = {
              //           'order_id': order.id.toString(),
              //           'role_name':
              //               Get.find<AuthController>().profileModel.role.first,
              //           'order_status': orderStatus == 1 ? 'ready' : 'cooking'
              //         };
              //         Get.find<KdsController>()
              //             .changeOrderStatus(jsonBody, callback);
              //       }
              //     },
              //     title: orderStatus == 7
              //         ? 'Confirm'
              //         : orderStatus == 1
              //             ? 'ready'.tr
              //             : 'accept_all'.tr,
              //   ),
              // )
              // if (order.audioFile != null)
              //   Padding(
              //     padding: const EdgeInsets.only(left: 10),
              //     child: InkWell(
              //       onTap: () async {
              //         if (order.audioFile != null) {
              //           await Get.dialog(
              //               PlayVoiceNoteDialoge(audio: order.audioFile));
              //         }
              //       },
              //       child: Image.asset(Images.ic_voice_note,
              //           height: 50, width: 50),
              //     ),
              //   ),
              // Get.find<KdsController>().selectedSubMenu == 0
              //     ? SizedBox(width: 10)
              //     : SizedBox.shrink()
            ],
          ),

          // if (Get.find<KdsController>().selectedSubMenu == 2)
          //   Padding(
          //     padding: const EdgeInsets.only(right: 18),
          //     child: Align(
          //       alignment: Alignment.centerRight,
          //       child: FoodButton(
          //         isDisable: true,
          //         onTap: () {},
          //         title: 'Serve',
          //       ),
          //     ),
          //   )
        ],
      ),
    );
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      Get.find<UpdateWidgetController>().updateWidget('');
    });
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      // Get.find<KdsController>().startLoading();
      // Get.find<KdsController>().clearOrderList();
      // Get.find<KdsController>().getPOSOrderList();
      // Get.find<KdsController>().getTotalKdsOrder();
      // showCustomSnackBar(message, isError: false);

      // Get.offNamed(
      //     RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
    } else {
      // showCustomSnackBar(message);
    }
  }

  void showAddressDialog(Orders order) {
    Get.dialog(StatefulBuilder(builder: (context, setState) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE)),
        insetPadding: EdgeInsets.all(20),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SizedBox(
          width: Get.width * 0.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  Text('Address',
                      style: poppinsMedium.copyWith(
                          fontSize: 18, color: Theme.of(context).primaryColor)),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.close,
                            color: Theme.of(context).primaryColor)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${order.deliveryAddress?.contactPersonName ?? ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Phone: ${order.deliveryAddress?.contactPersonNumber ?? ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Address type: ${order.deliveryAddress?.addressType ?? ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Address: ${order.deliveryAddress?.address ?? ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Pincode: ${order.deliveryAddress?.pincode ?? ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }));
  }
}

class PlayVoiceNoteDialoge extends StatefulWidget {
  final String? audio;

  const PlayVoiceNoteDialoge({Key? key, this.audio}) : super(key: key);

  @override
  State<PlayVoiceNoteDialoge> createState() => _PlayVoiceNoteDialogeState();
}

class _PlayVoiceNoteDialogeState extends State<PlayVoiceNoteDialoge> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE)),
        insetPadding: EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: SizedBox(
            width: MediaQuery.of(context).size.width > 1600
                ? Get.width * 0.2
                : Get.width * 0.8,
            child: Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      Text(
                        'Voice note',
                        textAlign: TextAlign.center,
                        style: poppinsMedium.copyWith(
                            fontSize: MediaQuery.of(context).size.width > 1600
                                ? 20
                                : Dimensions.FONT_SIZE_EXTRA_LARGE,
                            color: Colors.black),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Image.asset(Images.ic_cancel,
                            color: Colors.red, height: 23),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                  // SizedBox(
                  //   height: Get.height * 0.1,
                  //   child: AudioPlayer(
                  //     type: 'kds',
                  //     source: '${widget.audio}',
                  //     onDelete: () {},
                  //   ),
                  // ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                  InkWell(
                    onTap: () async {
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                          vertical: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                          color: ColorTheme.appColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_DEFAULT)),
                      child: Text(
                        'Ok',
                        style: poppinsMedium.copyWith(
                            fontSize: MediaQuery.of(context).size.width > 1600
                                ? 19
                                : Dimensions.FONT_SIZE_LARGE,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ]),
              ),
            )),
      );
    });
  }
}
