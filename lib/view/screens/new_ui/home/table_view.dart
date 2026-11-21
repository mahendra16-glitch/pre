import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_pos_printer_platform_image_3/printer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
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
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_button.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/base/select_print_dialog.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/kds_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/pos_screen_window/pos_screen_order_screen.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/cancel_order_dialog.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/widget/waiter_order_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_waiter_product_list.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/pos_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

class TableViewHome extends StatefulWidget {
  StreamSubscription<BTStatus>? subscriptionBtStatus;

  TableViewHome({
    super.key,
    this.subscriptionBtStatus,
  });

  @override
  State<TableViewHome> createState() => _TableViewHomeState();
}

class _TableViewHomeState extends State<TableViewHome> {
  String selectedStatus = 'All';

  final List<String> statusOptions = ['All', 'New', 'Occupied', 'Empty'];

  // final List<Map<String, dynamic>> tables = List.generate(14, (index) {
  //   if (index == 0) {
  //     return {
  //       'id': 'T1',
  //       'status': 'occupied',
  //       'guests': 2,
  //       'items': 14,
  //       'time': '35 Min',
  //       'amount': '₹3500'
  //     };
  //   } else if (index == 1) {
  //     return {'id': 'T2', 'status': 'reserved', 'guests': 4, 'time': '2:30 PM'};
  //   } else {
  //     return {'id': 'T${index + 1}', 'status': 'empty'};
  //   }
  // });

  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<KdsController>(builder: (kdsController) {
        return GetBuilder<TableController>(builder: (tableController) {
          return tableController.isLoading
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    // if (isMobile(context) || isTablet(context))
                    const SizedBox(height: 15),
                    // if (isMobile(context) || isTablet(context))
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      width: Get.width,
                      child: Row(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          // Yellow dropdown for status
                          if (kdsController.selectedOrderForTableView == null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedStatus,
                                  dropdownColor: Colors.yellow[100],
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.black),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  items: statusOptions.map((String status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedStatus = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          // SizedBox(width: 12),
                          Spacer(),

                          if (kdsController.selectedOrderForTableView != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () {
                                  kdsController.updateSelectedOrder(null);
                                },
                                child: Icon(
                                  Icons.close,
                                  color: ColorTheme.appColor,
                                  size: 32,
                                ),
                              ),
                            ),
                          // Add user icon button
                          if (kdsController.selectedOrderForTableView == null)
                            InkWell(
                              onTap: () {
                                Get.bottomSheet(mergeTableList(context),
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    ignoreSafeArea: false);
                              },
                              child: SvgPicture.asset(
                                Images.ic_show_table,
                              ),
                            ),
                          if (kdsController.selectedOrderForTableView == null)
                            SizedBox(width: 15),
                          // Refresh icon button
                          if (kdsController.selectedOrderForTableView == null)
                            InkWell(
                              onTap: () {
                                Get.bottomSheet(openTableList(context),
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    ignoreSafeArea: false);
                              },
                              child: SvgPicture.asset(
                                Images.ic_switch_table,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0), // slide from right
                                  end: Offset.zero, // to center
                                ).animate(animation),
                                child: child,
                              );
                            },
                            child: kdsController.selectedOrderForTableView !=
                                    null
                                ? Padding(
                                    key: const ValueKey('WaiterOrderList'),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7.0),
                                    child: WaiterOrderList(
                                      widget.subscriptionBtStatus,
                                      searchOrder: TextEditingController(),
                                      order: kdsController
                                          .selectedOrderForTableView!,
                                      isWaiter: true,
                                    ),
                                  )
                                : StaggeredGrid.count(
                                    key: const ValueKey('StaggeredGrid'),
                                    axisDirection: AxisDirection.down,
                                    crossAxisCount: isMobile(context)
                                        ? 3
                                        : isTablet(context)
                                            ? 5
                                            : 9,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    children: tableController.allTableList
                                        .where((table) {
                                      if (selectedStatus == 'New') {
                                        if (table.order != null &&
                                            (table.order?.fOrderStatus == 7 ||
                                                table.order?.fOrderStatus ==
                                                    1)) {
                                          return true;
                                        }
                                      } else if (selectedStatus == 'Occupied') {
                                        if (table.order != null &&
                                            (table.order?.fOrderStatus == 1 ||
                                                table.order?.fOrderStatus ==
                                                    2 ||
                                                table.order?.fOrderStatus ==
                                                    5)) {
                                          return true;
                                        }
                                      } else if (selectedStatus == 'Empty') {
                                        if (table.order == null) {
                                          return true;
                                        }
                                      } else if (selectedStatus == 'All') {
                                        return true;
                                      }

                                      return false;
                                    }).map((table) {
                                      // Now return the widget directly
                                      return buildTableCard(table);
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        });
      }),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      toolbarHeight: screenHeight * 0.085,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          if (!isMobile(context))
            Image.asset(
              Images.app_logo,
              height: screenHeight * 0.06,
            ),
          if (isMobile(context))
            Icon(Icons.menu, color: Colors.deepOrangeAccent),
          const SizedBox(width: 10),
          Text(
            'Dine In',
            style: poppinsSemiBold.copyWith(
                fontSize: 16, color: Colors.deepOrange),
          ),
        ],
      ),
      actions: [
        if (!isMobile(context)) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Text('Online',
                  style: poppinsSemiBold.copyWith(
                      fontSize: 14, color: Color(0xFF329937))),
            ),
          ),
          Transform.scale(
            scale: 0.5,
            child: Switch(
              value: isSwitched,
              activeColor: Color(0xFF18A84A),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              trackOutlineWidth: WidgetStatePropertyAll(3),
              inactiveThumbColor: Color(0xFFCACACA),
              trackOutlineColor: isSwitched
                  ? WidgetStatePropertyAll(Color(0xFF18A84A))
                  : WidgetStatePropertyAll(Color(0xFFCACACA)),
              onChanged: (bool value) {
                setState(() {
                  isSwitched = value;
                });
              },
            ),
          ),
        ]
      ],
      elevation: 0,
    );
  }

  Widget buildTableCard(TableResponseModel table) {
    return table.isEngage == 'Yes' && table.order != null
        ? InkWell(
            onTap: () async {
              isMobile(context)
                  ? await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WaiterPosScreen(editOrder: table.order)))
                  : await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TabletPosScreen(
                                editOrder: table.order,
                              )));
            },
            child: AspectRatio(
              aspectRatio: isMobile(context)
                  ? 85 / 115
                  : isTablet(context)
                      ? 85 / 105
                      : 85 / 95,
              child: Card(
                color: Colors.white,
                elevation: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: isTablet(context) ? 3 : 3),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, right: 5, top: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // (table.order?.readyDetails?.length == 0)
                          //     ? SizedBox()
                          //     :
                          InkWell(
                            onTap: () {
                              Get.find<KdsController>()
                                  .updateSelectedOrder(table.order!);
                            },
                            child: SizedBox(
                                width: 30,
                                child: Icon(Icons.edit,
                                    size: isMobile(context)
                                        ? 20
                                        : isTablet(context)
                                            ? 25
                                            : 18,
                                    color: Color(0xFF828282))

                                //  Image.asset(
                                //    Images.edit,
                                //    width: isMobile(context)
                                //        ? 20
                                //        : isTablet(context)
                                //            ? 25
                                //            : 18,
                                //  ),
                                ),
                          ),
                          if (table.order?.fOrderStatus != 7)
                            InkWell(
                              onTap: () {
                                Get.bottomSheet(
                                    CancelOrderDialog(
                                      cancelType: 'order',
                                      orderId: table.order!.id.toString(),
                                      stations: [
                                        ...?table.order?.orderDetails
                                            ?.map((e) => e.station ?? ''),
                                        ...?table.order?.serveOrderDetails
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
                              child: Container(
                                width: 27,
                                height: 27,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC6C6C6),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.close,
                                    size: 21, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                        height: 1,
                        width: double.infinity,
                        color: Color(0xFFEFEFEF)),
                    Spacer(),
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: isMobile(context)
                                ? 8
                                : isTablet(context)
                                    ? 8
                                    : 8,
                            horizontal: isMobile(context)
                                ? 30
                                : isTablet(context)
                                    ? 40
                                    : 25),
                        decoration: BoxDecoration(
                            color: table.order?.fOrderStatus == 7
                                ? ColorTheme.appColor
                                : Colors.green,
                            borderRadius: BorderRadius.circular(40)),
                        child: Text(
                          table.title == ''
                              ? '${table.tableNo}'
                              : '${table.title.length >= 1 ? table.title.substring(0, 1) : table.title}-${table.tableNo}',
                          style: poppinsSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: isMobile(context)
                                ? 16
                                : isTablet(context)
                                    ? 18
                                    : 15,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Color(0xFFEFEFEF),
                    ),
                    if (table.order?.fOrderStatus == 7)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.bottomSheet(
                                    CancelOrderDialog(
                                      cancelType: 'order',
                                      orderId: table.order!.id.toString(),
                                      stations: [
                                        ...?table.order?.orderDetails
                                            ?.map((e) => e.station ?? ''),
                                        ...?table.order?.serveOrderDetails
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
                              child: Container(
                                width: 37,
                                height: 37,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC6C6C6),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.close,
                                    size: 21, color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () async {
                                Map<String, dynamic> jsonBody = {
                                  'order_id': table.order!.id.toString(),
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
                                        (bool isSuccess, String message) async {
                                  if (isSuccess) {
                                    // showToast(message);
                                  } else {
                                    // showCustomSnackBar(message);
                                  }
                                });
                              },
                              child: Container(
                                width: 37,
                                height: 37,
                                decoration: BoxDecoration(
                                  color: ColorTheme.green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.check,
                                    size: 21, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (table.order?.fOrderStatus != 7)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                getShortTimeAgo(
                                    Jiffy.parse(table.order!.createdAt!)
                                        .fromNow()),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: poppinsSemiBold.copyWith(
                                  color: Color(0xFF828282),
                                  fontSize: isTablet(context)
                                      ? 14
                                      : isDesktop(context)
                                          ? 12
                                          : 11,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: isTablet(context)
                                ? 23
                                : isDesktop(context)
                                    ? 25
                                    : 15,
                            width: 1,
                            color: Color(0xFFEFEFEF),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                table.order?.orderAmount ?? '0',
                                style: poppinsSemiBold.copyWith(
                                  color: Color(0xFF828282),
                                  fontSize: isTablet(context)
                                      ? 14
                                      : isDesktop(context)
                                          ? 12
                                          : 11,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    // SizedBox(height: 2),
                    if (table.order?.fOrderStatus != 7)
                      Container(height: 1, color: Color(0xFFEFEFEF)),
                    if (table.order?.fOrderStatus != 7)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                List<List<OrderDetails>> cartProductList = [];
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
                                  List<OrderDetails> tempCartList = [];
                                  for (var e in table.order!.orderDetails!) {
                                    if ((printer.areaName!.toUpperCase() ==
                                                'MASTER_KOT' ||
                                            e.station == printer.areaName) &&
                                        (e.foodStatus != 3)) {
                                      tempCartList.add(e);
                                    }
                                  }
                                  cartProductList.add(tempCartList);
                                }
                                if (cartProductList.isNotEmpty) {
                                  if (table.order!.restaurantTable != null &&
                                      table.order!.restaurantTable!.rtype ==
                                          'RM') {
                                  } else {
                                    showToast('Please wait..');
                                    Get.find<LoadingController>()
                                        .startLoading(true);
                                    await Get.find<PosController>()
                                        .getCollectBillDetail(
                                            {'order_id': '${table.order!.id}'});
                                    Get.find<LoadingController>()
                                        .startLoading(false);
                                    if (Get.isBottomSheetOpen ?? false)
                                      Get.back();
                                  }
                                  await Get.bottomSheet(
                                      PrintDialog(
                                        isBillPrint:
                                            table.order!.restaurantTable !=
                                                        null &&
                                                    table
                                                            .order!
                                                            .restaurantTable!
                                                            .rtype ==
                                                        'RM'
                                                ? false
                                                : true,
                                        collectBillResponse:
                                            Get.find<PosController>()
                                                .getCollectBillDetailResponse,
                                        cartProductList: cartProductList,
                                        index: Get.find<KdsController>()
                                            .getWaiterOrderListResponse!
                                            .orders!
                                            .indexOf(table.order!),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      ignoreSafeArea: false);
                                }
                              },
                              child: Container(
                                height: isTablet(context)
                                    ? 30
                                    : isDesktop(context)
                                        ? 40
                                        : 23,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'KOT',
                                    style: poppinsSemiBold.copyWith(
                                      color: Color(0xFF2E2E2E),
                                      fontSize: isTablet(context)
                                          ? 15
                                          : isDesktop(context)
                                              ? 16
                                              : 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(
                                  RouteHelper.getWaiterCollectPaymentRoute(
                                      table.order!.id.toString()),
                                );
                              },
                              child: Container(
                                height: isTablet(context)
                                    ? 30
                                    : isDesktop(context)
                                        ? 40
                                        : 23,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFE100),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Center(
                                    child: Text(
                                  'Bill',
                                  style: poppinsSemiBold.copyWith(
                                    color: Color(0xFF2E2E2E),
                                    fontSize: isTablet(context)
                                        ? 15
                                        : isDesktop(context)
                                            ? 16
                                            : 12,
                                  ),
                                )),
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
          )
        : InkWell(
            onTap: () async {
              isMobile(context)
                  ? await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WaiterPosScreen(
                                editOrder: null,
                                selectedTable: table,
                              )))
                  : await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TabletPosScreen(
                                editOrder: null,
                                selectedTable: table,
                              )));
            },
            child: AspectRatio(
              // width: 106,
              // height: 123,
              aspectRatio: isMobile(context)
                  ? 85 / 115
                  : isTablet(context)
                      ? 85 / 105
                      : 85 / 95,
              child: Card(
                color: Colors.white,
                elevation: 1,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(height: 50),
                      Container(
                        margin:
                            EdgeInsets.only(top: isTablet(context) ? 48 : 32),
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet(context) ? 8 : 8,
                            horizontal: isTablet(context) ? 40 : 25),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          table.title == ''
                              ? '${table.tableNo}'
                              : '${table.title.length >= 1 ? table.title.substring(0, 1) : table.title}-${table.tableNo}',
                          style: poppinsSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: isTablet(context) ? 18 : 15,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: isTablet(context) ? -30 : -33,
                        left: isTablet(context) ? 33 : 15,
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFFF7E27),
                          radius: 18,
                          child: Icon(Icons.add,
                              size: isTablet(context) ? 25 : 20,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

    // switch (table['status']) {
    //   case 'occupied':
    //     return InkWell(
    //       onTap: () {
    //         Get.to(() => OrderPosTabletScreen());
    //       },
    //       child: SizedBox(
    //         width: 106,
    //         height: 123,
    //         child: Card(
    //           color: Colors.white,
    //           elevation: 1,
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               // SizedBox(height: isTablet(context) ? 3 : 3),
    //               Padding(
    //                 padding: const EdgeInsets.only(
    //                     left: 5.0, right: 5, top: 5, bottom: 5),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     Row(children: [
    //                       SizedBox(
    //                         width: 30,
    //                         child: SvgPicture.asset(
    //                           Images.boiling_pan,
    //                           width: isMobile(context)
    //                               ? 20
    //                               : isTablet(context)
    //                                   ? 25
    //                                   : 18,
    //                         ),
    //                       ),
    //                       SizedBox(width: 2),
    //                       Text('${table['guests']}',
    //                           style: poppinsSemiBold.copyWith(
    //                               fontSize: isMobile(context)
    //                                   ? 13
    //                                   : isTablet(context)
    //                                       ? 15
    //                                       : 11,
    //                               color: Color(0xFF828282))),
    //                     ]),
    //                     Row(children: [
    //                       Text('${table['items']}',
    //                           style: poppinsSemiBold.copyWith(
    //                               fontSize: isMobile(context)
    //                                   ? 13
    //                                   : isTablet(context)
    //                                       ? 15
    //                                       : 11,
    //                               color: Color(0xFF828282))),
    //                       SizedBox(width: 2),
    //                       Icon(Icons.restaurant_menu,
    //                           size: isMobile(context)
    //                               ? 20
    //                               : isTablet(context)
    //                                   ? 25
    //                                   : 18,
    //                           color: Color(0xFFC6C6C6)),
    //                     ])
    //                   ],
    //                 ),
    //               ),
    //               Container(
    //                 height: 1,
    //                 width: double.infinity,
    //                 color: Color(0xFFEFEFEF),
    //               ),
    //               Spacer(),
    //               Center(
    //                 child: Container(
    //                   padding: EdgeInsets.symmetric(
    //                       vertical: isMobile(context)
    //                           ? 8
    //                           : isTablet(context)
    //                               ? 8
    //                               : 8,
    //                       horizontal: isMobile(context)
    //                           ? 30
    //                           : isTablet(context)
    //                               ? 40
    //                               : 25),
    //                   decoration: BoxDecoration(
    //                       color: Colors.green,
    //                       borderRadius: BorderRadius.circular(40)),
    //                   child: Text(
    //                     table['id'],
    //                     style: poppinsSemiBold.copyWith(
    //                       color: Colors.white,
    //                       fontSize: isMobile(context)
    //                           ? 16
    //                           : isTablet(context)
    //                               ? 18
    //                               : 15,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               Spacer(),
    //               Container(
    //                 height: 1,
    //                 width: double.infinity,
    //                 color: Color(0xFFEFEFEF),
    //               ),
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                 children: [
    //                   Text(
    //                     table['time'],
    //                     style: poppinsSemiBold.copyWith(
    //                       color: Color(0xFF828282),
    //                       fontSize: isTablet(context) ? 14 : 11,
    //                     ),
    //                   ),
    //                   Container(
    //                     height: isTablet(context) ? 23 : 15,
    //                     width: 1,
    //                     color: Color(0xFFEFEFEF),
    //                   ),
    //                   Text(
    //                     table['amount'],
    //                     style: poppinsSemiBold.copyWith(
    //                       color: Color(0xFF828282),
    //                       fontSize: isTablet(context) ? 14 : 11,
    //                     ),
    //                   )
    //                 ],
    //               ),
    //               // SizedBox(height: 2),
    //               Container(height: 1, color: Color(0xFFEFEFEF)),
    //               Row(
    //                 children: [
    //                   Expanded(
    //                     child: Container(
    //                       height: isTablet(context) ? 30 : 23,
    //                       decoration: BoxDecoration(
    //                         color: Colors.transparent,
    //                         borderRadius: BorderRadius.only(
    //                           bottomLeft: Radius.circular(12),
    //                         ),
    //                       ),
    //                       child: Center(
    //                         child: Text(
    //                           'KOT',
    //                           style: poppinsSemiBold.copyWith(
    //                             color: Color(0xFF2E2E2E),
    //                             fontSize: isTablet(context) ? 15 : 12,
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   Expanded(
    //                     child: Container(
    //                       height: isTablet(context) ? 30 : 23,
    //                       decoration: BoxDecoration(
    //                         color: Color(0xFFFFE100),
    //                         borderRadius: BorderRadius.only(
    //                           bottomRight: Radius.circular(12),
    //                         ),
    //                       ),
    //                       child: Center(
    //                           child: Text(
    //                         'Bill',
    //                         style: poppinsSemiBold.copyWith(
    //                           color: Color(0xFF2E2E2E),
    //                           fontSize: isTablet(context) ? 15 : 12,
    //                         ),
    //                       )),
    //                     ),
    //                   )
    //                 ],
    //               )
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   case 'reserved':
    //     return SizedBox(
    //       width: 106,
    //       height: 123,
    //       child: Card(
    //         color: Colors.white,
    //         elevation: 1,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.symmetric(
    //                   horizontal: 5.0, vertical: 2.5),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Icon(Icons.group_outlined,
    //                       size: isTablet(context) ? 30 : 20,
    //                       color: Color(0xFFC6C6C6)),
    //                   Icon(Icons.edit_outlined,
    //                       size: isTablet(context) ? 30 : 20,
    //                       color: Color(0xFF047DD4))
    //                 ],
    //               ),
    //             ),
    //             Container(height: 1, color: Color(0xFFEFEFEF)),
    //             Spacer(),
    //             Container(
    //               padding: EdgeInsets.symmetric(
    //                   vertical: isTablet(context) ? 8 : 8,
    //                   horizontal: isTablet(context) ? 40 : 25),
    //               decoration: BoxDecoration(
    //                   color: Color(0xFFC6C6C6),
    //                   borderRadius: BorderRadius.circular(40)),
    //               child: Text(
    //                 table['id'],
    //                 style: poppinsSemiBold.copyWith(
    //                   color: Colors.white,
    //                   fontSize: isTablet(context) ? 18 : 15,
    //                 ),
    //               ),
    //             ),
    //             Spacer(),
    //             Container(height: 1, color: Color(0xFFEFEFEF)),
    //             Text(
    //               '${table['time']}',
    //               style: poppinsSemiBold.copyWith(
    //                 color: Color(0xFF828282),
    //                 fontSize: isTablet(context) ? 15 : 11,
    //               ),
    //             ),
    //             SizedBox(height: 3),
    //             Container(
    //               height: isTablet(context) ? 30 : 23,
    //               decoration: BoxDecoration(
    //                 color: Colors.black,
    //                 borderRadius: BorderRadius.only(
    //                   bottomLeft: Radius.circular(12),
    //                   bottomRight: Radius.circular(12),
    //                 ),
    //               ),
    //               child: Center(
    //                 child: Text(
    //                   'Reserved',
    //                   style: poppinsSemiBold.copyWith(
    //                     color: Colors.white,
    //                     fontSize: isTablet(context) ? 15 : 10,
    //                   ),
    //                 ),
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     );

    //   default:
    //     return SizedBox(
    //       width: 106,
    //       height: 123,
    //       child: Card(
    //         color: Colors.white,
    //         elevation: 1,
    //         child: Align(
    //           alignment: Alignment.topCenter,
    //           child: Stack(
    //             clipBehavior: Clip.none,
    //             children: [
    //               SizedBox(height: 50),
    //               Container(
    //                 margin: EdgeInsets.only(top: isTablet(context) ? 48 : 32),
    //                 padding: EdgeInsets.symmetric(
    //                     vertical: isTablet(context) ? 8 : 8,
    //                     horizontal: isTablet(context) ? 40 : 25),
    //                 decoration: BoxDecoration(
    //                   color: Colors.grey[400],
    //                   borderRadius: BorderRadius.circular(20),
    //                 ),
    //                 child: Text(
    //                   table['id'],
    //                   style: poppinsSemiBold.copyWith(
    //                     color: Colors.white,
    //                     fontSize: isTablet(context) ? 18 : 15,
    //                   ),
    //                 ),
    //               ),
    //               Positioned(
    //                 bottom: isTablet(context) ? -30 : -33,
    //                 left: isTablet(context) ? 33 : 15,
    //                 child: CircleAvatar(
    //                   backgroundColor: Color(0xFFFF7E27),
    //                   radius: 18,
    //                   child: Icon(Icons.add,
    //                       size: isTablet(context) ? 25 : 20,
    //                       color: Colors.white),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    // }
  }

  String getShortTimeAgo(String fromNow) {
    return fromNow
        .replaceAll('minutes', 'm')
        .replaceAll('minute', 'm')
        .replaceAll('hours', 'h')
        .replaceAll('hour', 'h')
        .replaceAll('days', 'd')
        .replaceAll('day', 'd')
        .replaceAll('seconds', 's')
        .replaceAll('second', 's')
        .replaceAll('a min', '1 m')
        .replaceAll('an h', '1 h')
        .replaceAll('a d', '1 d');
  }

  Widget openTableList(BuildContext context) {
    TextEditingController searchTable = TextEditingController();
    TableResponseModel? engageTableIdSelect;
    TableResponseModel? emptyTableIdSelect;
    List<TableResponseModel> engageTableList = [];
    List<TableResponseModel> emptyTableList = [];

    emptyTableList = Get.find<TableController>()
        .allTableList
        .where((item) => item.order == null)
        .toList();
    engageTableList = Get.find<TableController>()
        .allTableList
        .where((item) => item.order != null)
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select Table',
                      style: poppinsMedium.copyWith(
                          color: Colors.black, fontSize: 18)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
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
                      emptyTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) =>
                              item.order == null &&
                              (item.title.toLowerCase().contains(
                                      searchTable.text.toLowerCase()) ||
                                  item.tableNo.toLowerCase().contains(
                                      searchTable.text.toLowerCase())))
                          .toList();
                      engageTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) =>
                              item.order != null &&
                              (item.title.toLowerCase().contains(
                                      searchTable.text.toLowerCase()) ||
                                  item.tableNo.toLowerCase().contains(
                                      searchTable.text.toLowerCase())))
                          .toList();
                    } else {
                      emptyTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) => item.order == null)
                          .toList();
                      engageTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) => item.order != null)
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
                    if (engageTableList.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('From Select Table',
                            style: poppinsMedium.copyWith(
                                color: Colors.black, fontSize: 16)),
                      ),
                    if (engageTableList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: engageTableList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 7,
                                  childAspectRatio: 1.8,
                                  mainAxisSpacing: 7,
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  engageTableIdSelect = engageTableList[index];
                                  restaurantController.update();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: engageTableIdSelect ==
                                              engageTableList[index]
                                          ? ColorTheme.appColor
                                          : ColorTheme.tableBoxGrey,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: engageTableIdSelect ==
                                                  engageTableList[index]
                                              ? ColorTheme.appColor
                                              : ColorTheme.borderGrey)),
                                  child: Center(
                                    child: Text(
                                        '${engageTableList[index].title} ${engageTableList[index].tableNo} ',
                                        style: poppinsMedium.copyWith(
                                            fontSize: 10,
                                            color: engageTableIdSelect ==
                                                    engageTableList[index]
                                                ? Colors.white
                                                : ColorTheme.hintText)),
                                  ),
                                ));
                          },
                        ),
                      ),
                    if (emptyTableList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('To Select Table',
                              style: poppinsMedium.copyWith(
                                  color: Colors.black, fontSize: 16)),
                        ),
                      ),
                    if (emptyTableList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: emptyTableList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 7,
                                  childAspectRatio: 1.8,
                                  mainAxisSpacing: 7,
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  emptyTableIdSelect = emptyTableList[index];
                                  restaurantController.update();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: emptyTableIdSelect ==
                                              emptyTableList[index]
                                          ? ColorTheme.appColor
                                          : ColorTheme.tableBoxGrey,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: emptyTableIdSelect ==
                                                  emptyTableList[index]
                                              ? ColorTheme.appColor
                                              : ColorTheme.borderGrey)),
                                  child: Center(
                                    child: Text(
                                        '${emptyTableList[index].title} ${emptyTableList[index].tableNo} ',
                                        style: poppinsMedium.copyWith(
                                            fontSize: 10,
                                            color: emptyTableIdSelect ==
                                                    emptyTableList[index]
                                                ? Colors.white
                                                : ColorTheme.hintText)),
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
            CustomButton(
              width: Get.width / 2.0,
              buttonText: 'Done',
              onPressed: () async {
                if (emptyTableIdSelect != null && engageTableIdSelect != null) {
                  Map<String, dynamic> jsonData = {
                    'order_id': engageTableIdSelect!.order!.id,
                    'old_table_id': '${engageTableIdSelect!.id}',
                    'new_table_id': '${emptyTableIdSelect!.id}',
                  };
                  Get.find<CartController>().changeTable('TB', jsonData,
                      (bool isSucces) {
                    if (isSucces) {
                      Get.find<TableController>().switchTableForTableView(
                          emptyTableIdSelect!,
                          engageTableIdSelect!,
                          engageTableIdSelect!.order!);
                      // order.tableId = tableIdSelect!.id;
                      // order.restaurantTable = RestaurantTable(
                      //     id: tableIdSelect!.id,
                      //     rtype: tableIdSelect!.type,
                      //     tableNo: tableIdSelect!.tableNo,
                      //     title: tableIdSelect!.title);
                      if (Get.isBottomSheetOpen ?? false) Get.back();
                      Get.find<KdsController>().update();
                    } else {
                      // showErrorToast(
                      //     tableIdSelect.type == 'RM'
                      //         ? 'Failed room changed'
                      //         : 'Failed table changed',
                      //     isError: false);
                    }
                  });
                }
              },
            ),
          ]);
        }),
      ),
    );
  }

  Widget mergeTableList(BuildContext context) {
    TextEditingController searchTable = TextEditingController();
    TableResponseModel? engageTableIdSelect;
    TableResponseModel? emptyTableIdSelect;
    List<TableResponseModel> engageTableList = [];
    List<TableResponseModel> emptyTableList = [];
    bool isSwitchNote = false;

    emptyTableList = Get.find<TableController>()
        .allTableList
        .where((item) => item.order != null)
        .toList();

    engageTableList = Get.find<TableController>()
        .allTableList
        .where((item) => item.order != null)
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select Table',
                      style: poppinsMedium.copyWith(
                          color: Colors.black, fontSize: 18)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
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
                      emptyTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) =>
                              item.order != null &&
                              (item.title.toLowerCase().contains(
                                      searchTable.text.toLowerCase()) ||
                                  item.tableNo.toLowerCase().contains(
                                      searchTable.text.toLowerCase())))
                          .toList();
                      engageTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) =>
                              item.order != null &&
                              (item.title.toLowerCase().contains(
                                      searchTable.text.toLowerCase()) ||
                                  item.tableNo.toLowerCase().contains(
                                      searchTable.text.toLowerCase())))
                          .toList();
                    } else {
                      emptyTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) => item.order != null)
                          .toList();

                      engageTableList = Get.find<TableController>()
                          .allTableList
                          .where((item) => item.order != null)
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
                    if (engageTableList.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('From Select Table',
                            style: poppinsMedium.copyWith(
                                color: Colors.black, fontSize: 16)),
                      ),
                    if (engageTableList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: engageTableList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 7,
                                  childAspectRatio: 1.8,
                                  mainAxisSpacing: 7,
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if ((engageTableIdSelect == null &&
                                          emptyTableIdSelect == null) ||
                                      engageTableList[index].id !=
                                          emptyTableIdSelect?.id) {
                                    engageTableIdSelect =
                                        engageTableList[index];
                                  }
                                  restaurantController.update();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: engageTableIdSelect ==
                                              engageTableList[index]
                                          ? ColorTheme.appColor
                                          : ColorTheme.tableBoxGrey,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: engageTableIdSelect ==
                                                  engageTableList[index]
                                              ? ColorTheme.appColor
                                              : ColorTheme.borderGrey)),
                                  child: Center(
                                    child: Text(
                                        '${engageTableList[index].title} ${engageTableList[index].tableNo} ',
                                        style: poppinsMedium.copyWith(
                                            fontSize: 10,
                                            color: engageTableIdSelect ==
                                                    engageTableList[index]
                                                ? Colors.white
                                                : ColorTheme.hintText)),
                                  ),
                                ));
                          },
                        ),
                      ),
                    if (emptyTableList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('To Select Table',
                              style: poppinsMedium.copyWith(
                                  color: Colors.black, fontSize: 16)),
                        ),
                      ),
                    if (emptyTableList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: emptyTableList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 7,
                                  childAspectRatio: 1.8,
                                  mainAxisSpacing: 7,
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if ((engageTableIdSelect == null &&
                                          emptyTableIdSelect == null) ||
                                      engageTableIdSelect?.id !=
                                          emptyTableList[index].id) {
                                    emptyTableIdSelect = emptyTableList[index];
                                  }
                                  restaurantController.update();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: emptyTableIdSelect ==
                                              emptyTableList[index]
                                          ? ColorTheme.appColor
                                          : ColorTheme.tableBoxGrey,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: emptyTableIdSelect ==
                                                  emptyTableList[index]
                                              ? ColorTheme.appColor
                                              : ColorTheme.borderGrey)),
                                  child: Center(
                                    child: Text(
                                        '${emptyTableList[index].title} ${emptyTableList[index].tableNo} ',
                                        style: poppinsMedium.copyWith(
                                            fontSize: 10,
                                            color: emptyTableIdSelect ==
                                                    emptyTableList[index]
                                                ? Colors.white
                                                : ColorTheme.hintText)),
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
                ]),
            SizedBox(height: 10),
            CustomButton(
              width: Get.width / 2.0,
              buttonText: 'Done',
              onPressed: () async {
                if (emptyTableIdSelect != null && engageTableIdSelect != null) {
                  Map<String, dynamic> jsonData = {
                    'source_order_id': engageTableIdSelect!.order!.id,
                    'transfer_note': isSwitchNote ? 'Yes' : 'No',
                    'target_order_id': '${emptyTableIdSelect!.order!.id}',
                  };
                  Get.find<KdsController>().mergeTable(jsonData,
                      (bool isSucces) {
                    if (isSucces) {
                      Get.find<TableController>().switchTableForTableView(
                          emptyTableIdSelect!, engageTableIdSelect!, null);
                      // order.tableId = tableIdSelect!.id;
                      // order.restaurantTable = RestaurantTable(
                      //     id: tableIdSelect!.id,
                      //     rtype: tableIdSelect!.type,
                      //     tableNo: tableIdSelect!.tableNo,
                      //     title: tableIdSelect!.title);
                      if (Get.isBottomSheetOpen ?? false) Get.back();
                      Get.find<KdsController>().update();
                    } else {
                      // showErrorToast(
                      //     tableIdSelect.type == 'RM'
                      //         ? 'Failed room changed'
                      //         : 'Failed table changed',
                      //     isError: false);
                    }
                  });
                }
              },
            ),
          ]);
        }),
      ),
    );
  }
}
