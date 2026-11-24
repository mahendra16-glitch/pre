import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
// import '../../../../helper/colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../controller/auth_controller.dart';
import '../../../../../controller/loader_contoller.dart';
import '../../../../../controller/swiggy_controller.dart';
import '../../../../../data/model/body/bluetoothPrinterBody.dart';
import '../../../../../data/model/response/get_swiggy_order_list_response.dart';
import '../../../../../data/model/response/profile_model.dart';
import '../../../../../helper/colors.dart';
import '../../../../../util/app_constants.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/print_byte_convert.dart';
import '../../../../base/custom_snackbar.dart';
import '../../../../base/swiggy_order_print_dialog.dart';
import '../../../KDS/home/kds_home_screen.dart';
import 'countdown_timer.dart';

class SwiggyZomatoUI extends StatefulWidget {
  @override
  State<SwiggyZomatoUI> createState() => _SwiggyZomatoUIState();
}

class _SwiggyZomatoUIState extends State<SwiggyZomatoUI> {
  TextEditingController searchOrder = TextEditingController();
  PrinterManager individualPrinter = PrinterManager.instance;
  StreamSubscription<BTStatus>? _singlePrintBtStatus;
  List<int>? pendingTask;
  Timer? timer;
  Socket? socket;
  List<OrderIdType> orderIdQueue = [];
  List<Order> orderQueue = [];
  bool isProcessingOrderQueue = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getInitData();
      connectToSocketIO();
      timer = Timer.periodic(Duration(minutes: 1),
          (Timer t) => Get.find<SwiggyController>().update());
    });
  }

  getInitData() async {
    await Get.find<SwiggyController>().fetchStoreStatus();
    await Get.find<SwiggyController>().fetchOrders();
  }

  @override
  void dispose() {
    socket?.dispose();
    timer?.cancel();

    _singlePrintBtStatus?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // List selectedOrder = [0, 1, 2, 3, 4];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // final gridItemWidth = screenWidth * 0.35;
    // final gridItemHeight = screenHeight * 0.22;
    // final circleAvatarSize = gridItemWidth * 0.25;
    // final fontSize = screenWidth * 0.035;
    // final fontSize1 = screenWidth * 0.035;

    int image = 0;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.085,
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_sharp,
              color: ColorTheme.appColor, size: 40),
          onPressed: () {
            socket?.disconnect();
            Get.back();
          },
        ),
        title: Image.asset(
          Images.app_logo,
          width: screenWidth * 0.09,
        ),
        elevation: 0,
        actions: [
          GetBuilder<SwiggyController>(builder: (swiggyController) {
            return Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.7,
                      child: SizedBox(
                        width: 45,
                        child: CupertinoSwitch(
                          value: swiggyController.isSwiggyStoreOpen == 'Yes',
                          onChanged: (bool value) {
                            swiggyController.setStoreOpenVal(
                                value ? 'Yes' : 'No',
                                isLoading: true,
                                isSwiggy: true);
                          },
                        ),
                      ),
                    ),
                    Text(
                      'Swiggy', // Display the current mode
                      style: poppinsMedium.copyWith(
                          fontSize: 12, color: Colors.black),
                    ),
                    // Add some space between text and switch
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.7,
                        child: SizedBox(
                          width: 45,
                          child: CupertinoSwitch(
                            value: swiggyController.isZommatoStoreOpen == 'Yes',
                            onChanged: (bool value) {
                              swiggyController.setStoreOpenVal(
                                  value ? 'Yes' : 'No',
                                  isLoading: true,
                                  isSwiggy: false);
                            },
                          ),
                        ),
                      ),
                      Text(
                        'Zommato', // Display the current mode
                        style: poppinsMedium.copyWith(
                            fontSize: 12, color: Colors.black),
                      ),
                      // Add some space between text and switch
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.end,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Row(
        //           children: [
        //             Icon(
        //               Icons.circle,
        //               color: Colors.green[500],
        //               size: 15,
        //             ),
        //             SizedBox(
        //               width: 10,
        //             ),
        //             Text(
        //               'Online',
        //               style: montserratBold.copyWith(
        //                   fontSize: 16,
        //                   color: Color(0xFF18A84A),
        //                   height: 19 / 16),
        //             ),
        //           ],
        //         ),
        //         Row(
        //           children: [
        //             Text(
        //               'Last Synced',
        //               style: montserratMedium.copyWith(
        //                 fontSize: 12,
        //                 color: Color(0xFF8C8C8C),
        //                 height: 15 / 12,
        //               ),
        //             ),
        //             SizedBox(
        //               width: 3,
        //             ),
        //             Text(
        //               'Just Now',
        //               style: montserratSemiBold.copyWith(
        //                 fontSize: 12,
        //                 color: Color(0xFF636363),
        //                 height: 15 / 12,
        //               ),
        //             ),
        //           ],
        //         )
        //       ],
        //     ),
        //   )
        // ],
      ),
      body: GetBuilder<SwiggyController>(builder: (swiggyController) {
        if (swiggyController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (swiggyController.order.isEmpty) {
          return const Center(child: Text('No orders found... Sorry!'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            await Get.find<SwiggyController>().fetchOrders();
          },
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: StaggeredGrid.count(
                    crossAxisCount: 1,
                    // crossAxisSpacing: 50,
                    mainAxisSpacing: 20,
                    children: swiggyController.order.where((order) {
                      // Filter with dine in
                      if ((order.orderDetailsOrder.fOrderStatus == 0 ||
                                  order.orderDetailsOrder.fOrderStatus == 1 ||
                                  order.orderDetailsOrder.fOrderStatus == 2 ||
                                  order.orderDetailsOrder.fOrderStatus == 5) &&
                              (searchOrder.text.isEmpty
                                  ? true
                                  : order.orderDetailsOrder.aggregatorOrderId
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchOrder.text.toLowerCase()))
                          //  ||
                          // order.orderDetailsOrder.fOrderStatus == 5
                          ) {
                        return true;
                      }

                      return false;
                    }).map((order) {
                      // itemCount: 5,
                      // itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Container(
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
                                      height: screenHeight * 0.045,
                                      width: screenWidth * 0.045,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                color: image == 1
                                                    ? Color(0xFFF08520)
                                                    : Color(0xFFE23744)),
                                          ),
                                          Text(
                                            Jiffy.parse(order.orderDetailsOrder
                                                    .createdAt)
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
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: ColorTheme
                                                                      .borderGrey)),
                                                          child: Icon(
                                                              Icons.done,
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
                                                              'message':
                                                                  'Success'
                                                            };
                                                            await swiggyController
                                                                .changeOrderStatus(
                                                                    jsonBody);
                                                          },
                                                          child:
                                                              SvgPicture.asset(
                                                            Images
                                                                .correct_button,
                                                            height:
                                                                screenHeight *
                                                                    0.047,
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
                                        : order.orderDetailsOrder
                                                    .fOrderStatus ==
                                                2
                                            ? Flexible(
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        'Waiting for rider',
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
                                                        //   Map<String, dynamic>
                                                        //       jsonBody = {
                                                        //     'order_id': order
                                                        //         .orderDetailsOrder
                                                        //         .id,
                                                        //     "urban_order_id": order
                                                        //         .orderDetailsOrder
                                                        //         .urbanOrderId,
                                                        //     'new_status':
                                                        //         'Dispatched',
                                                        //     'message': 'Success'
                                                        //   };
                                                        //   await swiggyController
                                                        //       .changeOrderStatus(
                                                        //           jsonBody);
                                                        //   // print(jsonBody);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey[350],
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: ColorTheme
                                                                    .borderGrey)),
                                                        child: Icon(Icons.check,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : order.orderDetailsOrder
                                                        .fOrderStatus ==
                                                    0
                                                ? Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (order
                                                              .orderDetailsOrder
                                                              .orderPlateform ==
                                                          'zomato')
                                                        InkWell(
                                                          onTap: () {
                                                            searchOrder.clear();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                            Get.bottomSheet(
                                                                cancelOrder(
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
                                                              Images
                                                                  .cancel_button,
                                                              height:
                                                                  Get.height *
                                                                      0.047),
                                                        ),
                                                      SizedBox(width: 10),
                                                      Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () async {
                                                              searchOrder
                                                                  .clear();
                                                              FocusManager
                                                                  .instance
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
                                                            child: SvgPicture
                                                                .asset(
                                                              Images
                                                                  .correct_button,
                                                              height:
                                                                  Get.height *
                                                                      0.047,
                                                              // width: 40,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text('Accept',
                                                              style: montserratSemiBold
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12,
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
                                                                color:
                                                                    ColorTheme
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
                                    if (order.orderDetailsOrder.serveAt != '' &&
                                        order.riderInfo != null &&
                                        (order.orderDetailsOrder
                                                    .fOrderStatus ==
                                                0 ||
                                            order.orderDetailsOrder
                                                    .fOrderStatus ==
                                                1 ||
                                            order.orderDetailsOrder
                                                    .fOrderStatus ==
                                                2))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0, bottom: 7),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: CountdownTimerWidget(
                                            orderId: order.orderDetailsOrder
                                                .aggregatorOrderId
                                                .toString(),
                                            scheduleAt:
                                                order.orderDetailsOrder.serveAt,
                                            createdAt: order
                                                .orderDetailsOrder.createdAt,
                                          ),
                                        ),
                                      ),
                                    if (order.orderDetailsOrder.fOrderStatus !=
                                            0 &&
                                        order.riderInfo != null)
                                      Container(
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              Images.user_img,
                                              width: screenWidth * 0.1,
                                              height: screenHeight * 0.06,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      '${order.riderInfo?.name ?? ''}',
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF2E2E2E))),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                          '${order.riderInfo?.phone ?? ''}',
                                                          style: montserratMedium
                                                              .copyWith(
                                                                  fontSize: 14,
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
                                                    order.riderInfo?.phone ??
                                                        '');
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: Colors.yellow,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: ColorTheme
                                                            .borderGrey)),
                                                child: Icon(Icons.call,
                                                    color: Colors.black),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    if (order.orderDetailsOrder.fOrderStatus !=
                                            0 &&
                                        order.riderInfo != null)
                                      Container(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 7),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (order.riderInfo
                                                      ?.orderReturnOtp !=
                                                  '')
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      'Order return OTP : ${order.riderInfo?.orderReturnOtp}',
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.blue)),
                                                ),
                                              if (order.riderInfo
                                                      ?.bagReturnOtp !=
                                                  '')
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        'Bag return OTP : ${order.riderInfo?.bagReturnOtp}',
                                                        style: montserratMedium
                                                            .copyWith(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .blue)),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    if (order.orderDetailsOrder.fOrderStatus !=
                                        0)
                                      Divider(
                                          height: 30,
                                          thickness: 1,
                                          color: Color(0xFFF0F0F0)),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ListView.separated(
                                                  padding: EdgeInsets.zero,
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: order
                                                          .orderDetailsFood
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
                                                    String? addonGroupTitle;
                                                    String? variationGroupTitle;
                                                    String addonText = '';
                                                    String variationText = '';

                                                    for (var addon in order
                                                        .orderDetailsFood[i]
                                                        .addOns) {
                                                      if (addon.group != null) {
                                                        if (addon.group!
                                                                .isVariant ==
                                                            true) {
                                                          // 🔹 Handle Variation
                                                          variationGroupTitle ??=
                                                              addon.group!
                                                                      .title ??
                                                                  '';
                                                          variationText +=
                                                              "${addon.title}(${addon.quantity ?? 0}), ";
                                                        } else {
                                                          // 🔹 Handle Add-on
                                                          addonGroupTitle ??=
                                                              addon.group!
                                                                      .title ??
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
                                                    if (variationText
                                                        .isNotEmpty) {
                                                      variationText =
                                                          "${variationText.trim().replaceAll(RegExp(r',$'), '')}";
                                                      // variationText =
                                                      //     "$variationGroupTitle (${variationText.trim().replaceAll(RegExp(r',$'), '')})";
                                                    }
                                                    return Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5.0),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                image == 0
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green,
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
                                                              SizedBox(
                                                                  height: 5),
                                                              if (variationText !=
                                                                  '')
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        'Variant:',
                                                                        style: montserratMedium.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.blue)),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                        '$variationText',
                                                                        style: montserratMedium.copyWith(
                                                                            fontSize:
                                                                                12)),
                                                                  ],
                                                                ),
                                                              SizedBox(
                                                                  height: 5),
                                                              if (addonText !=
                                                                  '')
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        'Addons:',
                                                                        style: montserratMedium.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.blue)),
                                                                    SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                        '$addonText',
                                                                        style: montserratMedium.copyWith(
                                                                            fontSize:
                                                                                12)),
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
                                                                          top:
                                                                              5),
                                                                  child: Text(
                                                                      '${order.orderDetailsFood[i].foodLevelNotes ?? ''}',
                                                                      style: montserratMedium.copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.blue)),
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
                                                    style: montserratMedium
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.blue)),

                                              if (order.orderDetailsOrder
                                                          .preparationTime !=
                                                      '' &&
                                                  order.orderDetailsOrder
                                                          .readyAt !=
                                                      '' &&
                                                  order.orderDetailsOrder
                                                          .fOrderStatus ==
                                                      1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                  0)
                                                Text(
                                                    '₹ ${order.orderDetailsOrder.orderAmount}',
                                                    style: rupeeForadianRegular
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF18A84A))),
                                              if (order.orderDetailsOrder
                                                      .fOrderStatus !=
                                                  0)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                      '${order.customerDetails.name} | ${order.customerDetails.phone}',
                                                      style: montserratMedium
                                                          .copyWith(
                                                              fontSize: 12)),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (order.orderDetailsOrder
                                                .fOrderStatus !=
                                            0)
                                          Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 7),
                                              height: screenHeight * 0.05,
                                              width: 2,
                                              color: Color(0xFFF0F0F0)),
                                        // Text(
                                        //     '\u20B9 ${order.orderDetailsOrder.orderAmount} ',
                                        //     style:
                                        //         rupeeForadianRegular.copyWith(
                                        //             fontSize: 14,
                                        //             color: Color(0xFF18A84A)))
                                        if (order.orderDetailsOrder
                                                .fOrderStatus !=
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
                                                      color: ColorTheme
                                                          .borderGrey)),
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
                                                    style: rupeeForadianRegular
                                                        .copyWith(
                                                            fontSize: 18,
                                                            color: Color(
                                                                0xFF18A84A))),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                      '${order.customerDetails.name} | ${order.customerDetails.phone}',
                                                      style: montserratMedium
                                                          .copyWith(
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
                                                      color: ColorTheme
                                                          .borderGrey),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Text('Call Customer',
                                                  style:
                                                      montserratMedium.copyWith(
                                                          fontSize: 12,
                                                          color: ColorTheme
                                                              .appColor)),
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
                                                    backgroundColor:
                                                        Colors.yellow,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)))),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                          Get.find<
                                                                  AuthController>()
                                                              .profileModel!
                                                              .restaurantPrinterNew!
                                                              .length;
                                                      i++) {
                                                    RestaurantPrinterNew
                                                        printer = Get.find<
                                                                AuthController>()
                                                            .profileModel!
                                                            .restaurantPrinterNew![i];
                                                    List<OrderFoodDetails>
                                                        tempCartList = [];
                                                    for (var e in order
                                                        .orderDetailsFood) {
                                                      if (e.station ==
                                                          printer.areaName) {
                                                        tempCartList.add(e);
                                                      }
                                                    }
                                                    cartProductList
                                                        .add(tempCartList);
                                                  }
                                                  if (cartProductList
                                                      .isNotEmpty) {
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
                                                        isScrollControlled:
                                                            true,
                                                        ignoreSafeArea: false);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.yellow,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)))),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                                    backgroundColor:
                                                        Colors.yellow,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30)))),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                        ),
                      );
                    }).toList(),
                    // },
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void connectToSocketIO() {
    try {
      // Configure socket transports must be specified
      socket = io(
        AppConstants.SOCKET_BASE_URL,
        OptionBuilder()
            // .setPath('/socket') // Same as path in your JS code
            .setTransports(['websocket']) // Important for WebSocket only
            .enableForceNew() // Optional: always creates a new connection
            .enableReconnection()
            .enableAutoConnect() // Optional: auto reconnect
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

      // Connect to websocket
      // if (!socket.connected)
      socket?.connect();

      // Handle socket events
      // socket.on('connect', (_) => print('connect: ${socket.id}'));

      socket?.on(
          'aggregator_order_${Get.find<AuthController>().profileModel!.restaurants![0].id}',
          (data) async {
        print('////aggregator_order_/////$data');
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

      socket?.on('disconnect', (d) {
        print('disconnect----$d');

        // if (!socket.connected) {
        // print('Attempting to reconnect...');
        // socket.connect();
        // }
        socket = io(
          AppConstants.SOCKET_BASE_URL,
          OptionBuilder()
              // .setPath('/socket') // Same as path in your JS code
              .setTransports(['websocket']) // Important for WebSocket only
              .enableForceNew() // Optional: always creates a new connection
              .enableReconnection()
              .enableAutoConnect() // Optional: auto reconnect
              .build(),
        );
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void processNextOrderFromSocket() async {
    // If no orders in the queue or an order is currently being processed, return.
    if (orderIdQueue.isEmpty || isProcessingOrderQueue) return;

    // Mark as processing
    isProcessingOrderQueue = true;

    // Remove the next order from the queue
    var currentOrder =
        orderIdQueue.removeAt(0); // Get and remove the first order

    try {
      // Your byte conversion or printing logic here
      // Simulate byte conversion or printing process for the current order
      // showCustomSnackBar('Socket order api call');

      var isCallApi =
          await Get.find<SwiggyController>().getOrderDetailFromSocket(
        // socket: socket,
        foodStatus: '0',
        type: currentOrder.orderType,
        orderId: '${currentOrder.orderId}',
      );

      await Future.delayed(Duration(seconds: 1)); // Simulate async processing
    } finally {
      // After processing, mark as not processing
      isProcessingOrderQueue = false;

      // If there are more orders in the queue, process the next one
      if (orderIdQueue.isNotEmpty) {
        processNextOrderFromSocket(); // Continue with the next order
      }
    }
  }

  // Method to check and add an order to the queue
  void checkQueueProcessFromSocket(
      {String? orderType,
      String? orderId,
      String? otherValue,
      dynamic newOrderJson}) {
    // Add the new order to the queue
    orderIdQueue.add(OrderIdType(
        orderId: orderId,
        orderType: orderType,
        orderOthervalue: otherValue,
        newOrderJson: newOrderJson));

    // Start processing the next order if not already processing
    if (!isProcessingOrderQueue) {
      processNextOrderFromSocket();
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
                              height: MediaQuery.of(context).size.width > 1600
                                  ? 65
                                  : 40,
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
                          fontSize: MediaQuery.of(context).size.width > 1600
                              ? 18
                              : 14,
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

  Future _kdsPrintEscPos(List<int> bytes) async {
    // await printerManager.disconnect(type: PrinterType.bluetooth);
    BluetoothPrinter bluetoothPrinter;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      bluetoothPrinter = await BluetoothPrinter(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
          typePrinter: PrinterType.usb);
    } else {
      bluetoothPrinter = await BluetoothPrinter(
          address: Get.find<AuthController>().profileModel!.billPrinterIp,
          deviceName: Get.find<AuthController>()
              .profileModel!
              .billPrinterName); // ip was mandadory
    }

    var data;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      data = await individualPrinter.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
        ),
      );
    } else {
      data = await individualPrinter.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
          name: bluetoothPrinter.deviceName,
          address: bluetoothPrinter.address!,
        ),
      );
    }
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        // bytes += generator.feed(2);
        await individualPrinter.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        await individualPrinter.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
          ),
        );
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        // bytes += generator.feed(2);
        await individualPrinter.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
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
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance.disconnect(
            type: Get.find<AuthController>().profileModel!.billPrinterType ==
                    'usb'
                ? PrinterType.usb
                : PrinterType.bluetooth);
      });
      // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    } catch (e) {}
    if (data != null && !data) {
      await Get.find<LoadingController>().changeText(
          data:
              Get.find<AuthController>().profileModel!.billPrinterType == 'usb'
                  ? 'Failed to usb connect!!'
                  : 'Failed to bluetooth connect!!',
          error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  Future _iosPrintEscPos(List<int> bytes) async {
    print('########## bytes length ${bytes.length}');
    // bytes += generator.feed(2);
    // await PrintBluetoothThermal.pairedBluetooths;

    // Future.delayed(Duration(seconds: 5), () async {
    final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.billPrinter(), 
        macPrinterAddress:
            Get.find<AuthController>().profileModel!.macBillPrinterIp!);

    Future.delayed(Duration(seconds: 1), () async {
      if (result) {
        // List<int> ticket = await testTicket();
        await IosPrintTransport.writeBytes(bytes);

        Future.delayed(
            Duration(
                seconds: bytes.length <= 5850
                    ? 2
                    : bytes.length <= 7890
                        ? 3
                        : bytes.length <= 10195
                            ? 6
                            : bytes.length <= 13100
                                ? 10
                                : bytes.length <= 21150
                                    ? 15
                                    : 20), () async {
          Get.find<LoadingController>().startLoading(false);

          await Get.find<LoadingController>()
              .changeText(data: 'Successfully printed!!');
          await Get.find<LoadingController>().changeStatus(data: true);
          var isDisconnect =
          print('is disconnect $isDisconnect');
        });
        print("print test result:  $result");
      } else {
        //no conectado, reconecte
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Failed to bluetooth connect!!', error: true);
        await Get.find<LoadingController>().changeStatus(data: true);
        // showErrorToast('Failed to bluetooth connect');
      }
      // });
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

  printBill(Order order) async {
    if (GetPlatform.isWindows) {
      int numberOfPrint = int.parse(Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .settings!
              .noOfBillPrint ??
          '1');
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
                orderSubTotal: order.orderDetailsOrder.subTotal ?? 0.0,
                discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
                serviceChargeAmount: 0,
                deliveryCharge: 0,
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
              ),
            );

            await Future.delayed(Duration(seconds: 2));
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
          orderSubTotal: order.orderDetailsOrder.subTotal ?? 0.0,
          discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
          serviceChargeAmount: 0,
          deliveryCharge: 0,
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
          orderSubTotal: order.orderDetailsOrder.subTotal ?? 0.0,
          discount: order.orderDetailsOrder.orderDiscount ?? 0.0,
          serviceChargeAmount: 0,
          deliveryCharge: 0,
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
}
