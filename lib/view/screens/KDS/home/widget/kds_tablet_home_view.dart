import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/enums.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_kds_order_total_food_item_response.dart';
// import 'package:mygenie_restaurant/data/model/response/get_pos_order_list_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/widget/Kds_order_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import '../../swiggy/swiggy_order_ui.dart';

class KdsTabletHomeView extends StatefulWidget {
  TextEditingController searchController;
  final FlutterTts flutterTts;
  final GlobalKey<ScaffoldState> scaffoldKey;
  List<String> orderTypeList;
  SuperTooltipController dropdownContoller;
  final Function isPrintKot;

  KdsTabletHomeView({
    Key? key,
    required this.searchController,
    required this.flutterTts,
    required this.scaffoldKey,
    required this.orderTypeList,
    required this.dropdownContoller,
    required this.isPrintKot,
  }) : super(key: key);

  @override
  State<KdsTabletHomeView> createState() => _KdsTabletHomeViewState();
}

class _KdsTabletHomeViewState extends State<KdsTabletHomeView> {
  int orderStatus = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          color: Colors.white,
          height: Get.height,
          child: Column(
            children: [
              tabletAppBar(),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height:
                            MediaQuery.of(context).size.width >= 1500 ? 50 : 36,
                        child: TextField(
                          controller: widget.searchController,
                          textInputAction: TextInputAction.search,
                          autofocus: false,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                              suffixIcon: Icon(Icons.search,
                                  color: ColorTheme.appColor),
                              hintText:
                                  'Search by Table no. / Name / Phone No.',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey)),
                              hintStyle: poppinsRegular.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.width >= 1500
                                          ? 16
                                          : 13,
                                  color: ColorTheme.hintText),
                              filled: true,
                              fillColor: Colors.white),
                          style: poppinsMedium.copyWith(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width >= 1500
                                      ? 16
                                      : 13),
                          onChanged: (value) async {
                            Get.find<KdsController>().update();
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await Get.find<KdsController>().getPOSOrderList();
                        await Get.find<KdsController>().getTotalKdsOrder();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(Icons.refresh_outlined,
                            color: ColorTheme.appColor, size: 35),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (MediaQuery.of(context).size.width >= 1500 ||
                              MediaQuery.of(context).orientation ==
                                  Orientation.landscape)
                            Container(
                              padding: EdgeInsets.all(
                                  Dimensions.PADDING_SIZE_DEFAULT),
                              margin: EdgeInsets.only(
                                left: Dimensions.PADDING_SIZE_SMALL,
                                right: Dimensions.PADDING_SIZE_DEFAULT,
                              ),
                              width: Get.width * 0.2,
                              // height: Get.height * 0.9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_LARGE),
                                // color: Colors.green
                                color: Color.fromRGBO(250, 250, 250, 1),
                              ),
                              child: GetBuilder<KdsController>(
                                  builder: (kdsController) {
                                return kdsController.getKdsTotalOrderResponse ==
                                        null
                                    ? SizedBox.shrink()
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Stations',
                                            style: poppinsBold.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_OVER_LARGE,
                                                color: ColorTheme.appColor),
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics: BouncingScrollPhysics(),
                                              itemCount: kdsController
                                                  .getKdsTotalOrderResponse!
                                                  .orderedCategories
                                                  .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                OrderedCategories
                                                    orderedCategory =
                                                    kdsController
                                                        .getKdsTotalOrderResponse!
                                                        .orderedCategories[index];

                                                return Container(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Item',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                          SizedBox(
                                                              width: Dimensions
                                                                  .PADDING_SIZE_DEFAULT),
                                                          Expanded(
                                                            child: Center(
                                                              child: Text(
                                                                '${orderedCategory.categoryName ?? ''}',
                                                                style: poppinsMedium.copyWith(
                                                                    fontSize: 16,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    color: index % 3 == 0
                                                                        ? ColorTheme.kdsLeftMenuBlue
                                                                        : index % 2 == 0
                                                                            ? ColorTheme.green
                                                                            : ColorTheme.kdsLeftMenuBrown),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: Dimensions
                                                                  .PADDING_SIZE_DEFAULT),
                                                          Text(
                                                            'Quantity',
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(
                                                          color: Colors.black),
                                                      SizedBox(
                                                          height: Dimensions
                                                              .PADDING_SIZE_SMALL),
                                                      ListView.builder(
                                                          itemCount:
                                                              orderedCategory
                                                                  .foodCounts
                                                                  .length,
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int i) {
                                                            return Container(
                                                              padding: EdgeInsets.only(
                                                                  bottom: Dimensions
                                                                      .PADDING_SIZE_SMALL),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                    width:
                                                                        Get.width *
                                                                            0.14,
                                                                    child: Text(
                                                                      orderedCategory
                                                                          .foodCounts[
                                                                              i]
                                                                          .split(
                                                                              ':')
                                                                          .first,
                                                                      style: poppinsMedium.copyWith(
                                                                          overflow: TextOverflow.ellipsis,
                                                                          fontSize: 16,
                                                                          color: index % 3 == 0
                                                                              ? ColorTheme.kdsLeftMenuBlue
                                                                              : index % 2 == 0
                                                                                  ? ColorTheme.green
                                                                                  : ColorTheme.kdsLeftMenuBrown),
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          DottedLine(
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    alignment:
                                                                        WrapAlignment
                                                                            .center,
                                                                    lineThickness:
                                                                        1.0,
                                                                    dashLength:
                                                                        1.0,
                                                                    dashColor: index %
                                                                                3 ==
                                                                            0
                                                                        ? ColorTheme
                                                                            .kdsLeftMenuBlue
                                                                        : index % 2 ==
                                                                                0
                                                                            ? ColorTheme.green
                                                                            : ColorTheme.kdsLeftMenuBrown,
                                                                  )),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left: Dimensions
                                                                            .PADDING_SIZE_SMALL),
                                                                    child: Text(
                                                                      orderedCategory
                                                                          .foodCounts[
                                                                              i]
                                                                          .split(
                                                                              ':')
                                                                          .last,
                                                                      style: poppinsMedium.copyWith(
                                                                          fontSize: 14,
                                                                          color: index % 3 == 0
                                                                              ? ColorTheme.kdsLeftMenuBlue
                                                                              : index % 2 == 0
                                                                                  ? ColorTheme.green
                                                                                  : ColorTheme.kdsLeftMenuBrown),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                      SizedBox(
                                                        height: Dimensions
                                                            .PADDING_SIZE_EXTRA_LARGE,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                        ],
                                      );
                              }),
                            ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: GetBuilder<KdsController>(
                                  builder: (kdsController) {
                                return kdsController.selectedMainMenu == 5
                                    ? KdsSwiggyUI()
                                    : Column(
                                        children: [
                                          if (kdsController.selectedMainMenu ==
                                              3)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: KdsSwiggyUI(),
                                            ),
                                          kdsController
                                                      .getStationOrderListResponse ==
                                                  null
                                              ? const SizedBox.shrink()
                                              : kdsController.isLoading
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : showConfigOrderList(
                                                      context,
                                                      orderStatus,
                                                      kdsController,
                                                      widget.searchController,
                                                      widget.flutterTts),
                                        ],
                                      );

                                // Wrap(
                                //     runAlignment:
                                //         WrapAlignment.start,
                                //     direction: Axis.horizontal,
                                //     alignment: WrapAlignment.start,
                                //     crossAxisAlignment:
                                //         WrapCrossAlignment.start,
                                //     children: kdsController
                                //         .getWaiterOrderListResponse
                                //         .orders
                                //         .map((order) {
                                //       return orderTypeListViewBuilder(
                                //         order,
                                //         kdsController,
                                //         Get.find<AuthController>()
                                //                 .profileModel
                                //                 .role
                                //                 .contains('BAR')
                                //             ? order.bOrderStatus
                                //             : order.kOrderStatus,
                                //         flutterTts:
                                //             widget.flutterTts,
                                //       );
                                //     }).toList(),
                                //   );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget orderTypeListViewBuilder(
  //     OrderList order, KdsController kdsController, int orderStatus,
  //     {@required FlutterTts flutterTts}) {
  //   return kdsController.selectedMainMenu == 0
  //       ? kdsController.selectedSubMenu == 1
  //           ? orderStatus == 1 || orderStatus == 7
  //               ? widget.searchController.text.isEmpty
  //                   ? ((order.restaurantTable != null ? order.restaurantTable.rtype != 'RM' : true) &&
  //                           (order?.orderType == 'pos' ||
  //                               order?.orderType == 'WalkIn' ||
  //                               order?.orderType == 'dinein'))
  //                       ? KdsTabletOrderList(
  //                           flutterTts: flutterTts,
  //                           order: order,
  //                           orderStatus: orderStatus)
  //                       : SizedBox.shrink()
  //                   : (order.restaurantTable != null &&
  //                               order.restaurantTable.tableNo != '' &&
  //                               (order.restaurantTable.tableNo
  //                                       .toUpperCase()
  //                                       .contains(widget.searchController.text
  //                                           .toUpperCase()) ||
  //                                   order.restaurantTable.title
  //                                       .toUpperCase()
  //                                       .contains(widget.searchController.text
  //                                           .toUpperCase()))) ||
  //                           // (order.id.toUpperCase().contains(
  //                           //     widget.searchController.text.toUpperCase())) ||
  //                           // ||
  //                           (order.userId == null &&
  //                               order.userName.toUpperCase().contains(widget
  //                                   .searchController.text
  //                                   .toUpperCase())) ||
  //                           (order.userId != null &&
  //                               (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) ||
  //                                   order.user.lName
  //                                       .toUpperCase()
  //                                       .contains(widget.searchController.text.toUpperCase()))) ||
  //                           (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                           (order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase()))
  //                       ? ((order.restaurantTable != null ? order.restaurantTable.rtype != 'RM' : true) && (order?.orderType == 'pos' || order?.orderType == 'WalkIn' || order?.orderType == 'dinein'))
  //                           ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                           : const SizedBox.shrink()
  //                       : SizedBox.shrink()
  //               : const SizedBox.shrink()
  //           : kdsController.selectedSubMenu == 2
  //               ? (orderStatus == 2 || ((Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 || Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 2) ? (orderStatus == 7 || orderStatus == 5) : orderStatus == 2))
  //                   ? widget.searchController.text.isEmpty
  //                       ? ((order.restaurantTable != null ? order.restaurantTable.rtype != 'RM' : true) && (order?.orderType == 'pos' || order?.orderType == 'WalkIn' || order?.orderType == 'dinein'))
  //                           ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                           : SizedBox.shrink()
  //                       : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                               (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                               (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                               (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                               // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                               order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                           ? ((order.restaurantTable != null ? order.restaurantTable.rtype != 'RM' : true) && (order?.orderType == 'pos' || order?.orderType == 'WalkIn' || order?.orderType == 'dinein'))
  //                               ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                               : SizedBox.shrink()
  //                           : const SizedBox.shrink()
  //                   : const SizedBox.shrink()

  //               // : const SizedBox.shrink()
  //               : const SizedBox.shrink()
  //       :

  //       ////
  //       kdsController.selectedMainMenu == 1
  //           ? kdsController.selectedSubMenu == 1
  //               ? orderStatus == 1 || orderStatus == 7
  //                   ? widget.searchController.text.isEmpty
  //                       ? (order?.orderType == 'take_away')
  //                           ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                           : SizedBox.shrink()
  //                       : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                               (order.userId == null && order.userName.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                               (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                               (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                               // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                               order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                           ? (order?.orderType == 'take_away')
  //                               ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                               : SizedBox.shrink()
  //                           : const SizedBox.shrink()
  //                   : const SizedBox.shrink()
  //               : kdsController.selectedSubMenu == 2
  //                   ? (orderStatus == 2 || ((Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 || Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 2) ? (orderStatus == 7 || orderStatus == 5) : orderStatus == 2))
  //                       ? widget.searchController.text.isEmpty
  //                           ? (order?.orderType == 'take_away')
  //                               ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                               : SizedBox.shrink()
  //                           : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                   (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                   (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                   (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                   // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                   order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                               ? (order?.orderType == 'take_away')
  //                                   ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                   : SizedBox.shrink()
  //                               : const SizedBox.shrink()
  //                       : const SizedBox.shrink()

  //                   // : const SizedBox.shrink()
  //                   : const SizedBox.shrink()
  //           :
  //           ////
  //           ///
  //           ///
  //           kdsController.selectedMainMenu == 2
  //               ? kdsController.selectedSubMenu == 1
  //                   ? orderStatus == 1 || orderStatus == 7
  //                       ? widget.searchController.text.isEmpty
  //                           ? (order?.orderType == 'delivery')
  //                               ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                               : SizedBox.shrink()
  //                           : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                   (order.userId == null && order.userName.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                   (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                   (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                   // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                   order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                               ? (order?.orderType == 'delivery')
  //                                   ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                   : SizedBox.shrink()
  //                               : const SizedBox.shrink()
  //                       : const SizedBox.shrink()
  //                   : kdsController.selectedSubMenu == 2
  //                       ? (orderStatus == 2 || ((Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 || Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 2) ? (orderStatus == 7 || orderStatus == 5) : orderStatus == 2))
  //                           ? widget.searchController.text.isEmpty
  //                               ? (order?.orderType == 'delivery')
  //                                   ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                   : SizedBox.shrink()
  //                               : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                       (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                       order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                                   ? (order?.orderType == 'delivery')
  //                                       ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                       : SizedBox.shrink()
  //                                   : const SizedBox.shrink()
  //                           : const SizedBox.shrink()

  //                       // : const SizedBox.shrink()
  //                       : const SizedBox.shrink()
  //               :
  //               ////////////////////////////
  //               kdsController.selectedMainMenu == 4
  //                   ? kdsController.selectedSubMenu == 1
  //                       ? orderStatus == 1 || orderStatus == 7
  //                           ? widget.searchController.text.isEmpty
  //                               ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
  //                                   ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                   : SizedBox.shrink()
  //                               : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       (order.userId == null && order.userName.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                       (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                       order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                                   ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
  //                                       ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                       : SizedBox.shrink()
  //                                   : const SizedBox.shrink()
  //                           : const SizedBox.shrink()
  //                       : kdsController.selectedSubMenu == 2
  //                           ? (orderStatus == 2 || ((Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 || Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 2) ? (orderStatus == 7 || orderStatus == 5) : orderStatus == 2))
  //                               ? widget.searchController.text.isEmpty
  //                                   ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
  //                                       ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                       : SizedBox.shrink()
  //                                   : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                           (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                           (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                           (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                           // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                           order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                                       ? (order.restaurantTable != null && order.restaurantTable.rtype == 'RM')
  //                                           ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                           : SizedBox.shrink()
  //                                       : const SizedBox.shrink()
  //                               : const SizedBox.shrink()

  //                           // : const SizedBox.shrink()
  //                           : const SizedBox.shrink()
  //                   :

  //                   ////
  //                   ///
  //                   ///
  //                   kdsController.selectedSubMenu == 1
  //                       ? orderStatus == 1 || orderStatus == 7
  //                           ? widget.searchController.text.isEmpty
  //                               ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                               : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       (order.userId == null && order.userName.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                       (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                       // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                       order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase())
  //                                   ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                   : const SizedBox.shrink()
  //                           : const SizedBox.shrink()
  //                       : kdsController.selectedSubMenu == 2
  //                           ? (orderStatus == 2 || ((Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 5 || Get.find<AuthController>().profileModel.restaurants.first.defOrdStatus == 2) ? (orderStatus == 7 || orderStatus == 5) : orderStatus == 2))
  //                               ? widget.searchController.text.isEmpty
  //                                   ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                   : (order.restaurantTable != null && order.restaurantTable.tableNo != '' && (order.restaurantTable.tableNo.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.restaurantTable.title.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                           (order.userId == null && '${order?.userName ?? ''}'.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                           (order.userId != null && (order.user.fName.toUpperCase().contains(widget.searchController.text.toUpperCase()) || order.user.lName.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                           (order.userId != null && (order.user.phone.toUpperCase().contains(widget.searchController.text.toUpperCase()))) ||
  //                                           // (order.id.toUpperCase().contains(widget.searchController.text.toUpperCase())) ||
  //                                           (order.restaurantOrderId.toUpperCase().contains(widget.searchController.text.toUpperCase()))
  //                                       ? KdsTabletOrderList(flutterTts: flutterTts, order: order, orderStatus: orderStatus)
  //                                       : const SizedBox.shrink()
  //                               : const SizedBox.shrink()

  //                           // : const SizedBox.shrink()
  //                           : const SizedBox.shrink();
  // }

  Widget tabletAppBar() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: IconButton(
            icon: Icon(Icons.menu, color: ColorTheme.appColor),
            onPressed: () {
              widget.scaffoldKey.currentState!.openDrawer();
            },
          ),
        ),
        Text(
          Get.find<AuthController>().profileModel!.roleName!.toUpperCase(),
          style: poppinsSemiBold.copyWith(
              color: ColorTheme.appColor, fontSize: 15),
        ),
        // Image.asset(
        //     Get.find<AuthController>().profileModel.role.contains('BAR')
        //         ? Images.ic_bar_app_logo
        //         : Images.ic_kds_app_logo,
        //     width: Get.width * 0.2),
        SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
        // MediaQuery.of(context).size.width >= 1500
        //     ? Get.find<AuthController>()
        //                 .profileModel
        //                 .restaurants[0]
        //                 .isDelivery ==
        //             'true'
        //         ? orderTypeTab()
        //         : foodStatusTab()
        //     :
        readyTab(),
      ],
    );
  }

  Widget readyTab() {
    return GetBuilder<KdsController>(builder: (kdsController) {
      return Container(
        color: Color(0xFFF6F6F6),
        padding: EdgeInsets.only(right: 10),
        width: Get.width * 0.65,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                await widget.dropdownContoller.showTooltip();
              },
              child: SuperTooltip(
                borderRadius: 2,
                borderColor: Colors.white,
                shadowColor: Colors.black.withOpacity(0.1),
                showBarrier: true,
                controller: widget.dropdownContoller,
                popupDirection: TooltipDirection.down,
                backgroundColor: Colors.white,
                right: Get.width * 0.5 + 20,
                left: Get.width * 0.3,
                constraints: BoxConstraints(
                    maxHeight: 40, minWidth: 0, minHeight: 10, maxWidth: 100),
                arrowTipDistance: 10,
                arrowBaseWidth: 2.0,
                arrowLength: 0,
                touchThroughAreaShape: ClipAreaShape.rectangle,
                touchThroughAreaCornerRadius: 5,
                barrierColor: Colors.transparent,
                content: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.orderTypeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 20,
                            top: 25,
                            bottom: index == widget.orderTypeList.length - 1
                                ? 25
                                : 0),
                        child: InkWell(
                          onTap: () async {
                            if (widget.orderTypeList[index] == 'Dine In') {
                              kdsController.setMainMenuIndex(0);
                            } else if (widget.orderTypeList[index] ==
                                'Take Away') {
                              kdsController.setMainMenuIndex(1);
                            } else if (widget.orderTypeList[index] ==
                                'Delivery') {
                              kdsController.setMainMenuIndex(2);
                            } else if (widget.orderTypeList[index] ==
                                'Swiggy-Zommato') {
                              kdsController.setMainMenuIndex(5);
                            } else if (widget.orderTypeList[index] == 'Room') {
                              kdsController.setMainMenuIndex(4);
                            } else {
                              kdsController.setMainMenuIndex(3);
                            }
                            FocusManager.instance.primaryFocus?.unfocus();
                            await widget.dropdownContoller.hideTooltip();
                          },
                          child: Text(
                            widget.orderTypeList[index],
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      );
                    }),
                child: Container(
                  height: 50,
                  width: Get.width * 0.15,
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                    color: ColorTheme.dineInDropdownYello,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Get.find<AuthController>()
                                      .profileModel!
                                      .restaurants!
                                      .first
                                      .delivery !=
                                  true
                              ? 'Dine In'
                              : kdsController.selectedMainMenu == 0
                                  ? 'Dine In'
                                  : kdsController.selectedMainMenu == 1
                                      ? 'Take Away'
                                      : kdsController.selectedMainMenu == 2
                                          ? 'Delivery'
                                          : kdsController.selectedMainMenu == 4
                                              ? 'Room'
                                              : kdsController
                                                          .selectedMainMenu ==
                                                      5
                                                  ? 'Swiggy-Zommato'
                                                  : 'All',
                          maxLines: 1,
                          style: poppinsMedium.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            if (Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    0 ||
                Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    1 ||
                Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    2)
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    kdsController.setSubMenuIndex(1);
                  },
                  child: SizedBox(
                    height: 50,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: Get.width > 1500
                                ? Get.width * 0.22
                                : Get.width * 0.2,
                            height: 30,
                            // padding: EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: kdsController.selectedSubMenu == 1
                                  ? ColorTheme.appColor
                                  : Color(0xFFF6F6F6),
                            ),
                            child: Center(
                              child: Text(
                                Get.find<AuthController>()
                                        .profileModel!
                                        .role!
                                        .contains('BAR')
                                    ? 'Making'
                                    : 'Cooking',
                                style: poppinsMedium.copyWith(
                                    fontSize: 13,
                                    color: kdsController.selectedSubMenu == 1
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        (kdsController.getStationOrderListResponse == null) ||
                                (kdsController.getStationOrderListResponse!
                                        .statusCounts!.cooking ==
                                    0)
                            ? SizedBox.shrink()
                            : Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    '${kdsController.getStationOrderListResponse!.statusCounts!.cooking}',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorTheme.badgeRed),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            if (Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    0 ||
                Get.find<AuthController>()
                        .profileModel!
                        .restaurants![0]
                        .defOrdStatus ==
                    1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 1,
                  // height: 8,
                  height: 20,
                  color: Color(0xFFE6E6E6),
                ),
              ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  kdsController.setSubMenuIndex(2);
                },
                child: SizedBox(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: kdsController.selectedSubMenu == 2
                          ? ColorTheme.appColor
                          : Color(0xFFF6F6F6),
                    ),
                    child: Center(
                      child: Text(
                        (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .defOrdStatus ==
                                5)
                            ? Get.find<AuthController>()
                                    .profileModel!
                                    .role!
                                    .contains('BAR')
                                ? 'Making'
                                : 'Cooking'
                            : 'Ready',
                        style: poppinsMedium.copyWith(
                            fontSize: 13,
                            color: kdsController.selectedSubMenu == 2
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget showConfigOrderList(
      BuildContext context,
      int orderStatus,
      KdsController kdsController,
      TextEditingController searchController,
      FlutterTts flutterTts) {
    int defOrderStatus = Get.find<AuthController>()
        .profileModel!
        .restaurants!
        .first
        .defOrdStatus!;
    return StaggeredGrid.count(
      crossAxisCount: MediaQuery.of(context).size.width >= 1500 ? 3 : 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children:
          kdsController.getStationOrderListResponse!.orders!.where((order) {
        orderStatus = order.orderDetailsOrder!.fOrderStatus == 3
            ? 3
            : order.orderDetailsOrder!.fOrderStatus == 6
                ? 6:order.orderDetailsOrder!.fOrderStatus == 8?8
                : order.orderDetailsOrder!.stationOrderStatus![
                    '${Get.find<AuthController>().profileModel!.roleName!.toUpperCase()}'];

        // Filter with dine in
        if (kdsController.selectedMainMenu == 0) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if (((order.restaurantTable != null
                        ? order.restaurantTable?.rtype != 'RM'
                        : true) &&
                    (order.orderDetailsOrder?.orderType == 'pos' ||
                        order.orderDetailsOrder?.orderType == 'WalkIn' ||
                        order.orderDetailsOrder?.orderType == 'dinein'))) {
                  return true;
                }
              } else if ((Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('table no') == true &&
                      (order.restaurantTable != null &&
                          order.restaurantTable?.tableNo != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.orderDetailsOrder?.userId != null &&
                          ((order.user?.phone?.length ?? 0) > 2 &&
                              (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true &&
                      (order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase()) ??
                          false))) {
                if (((order.restaurantTable != null
                        ? order.restaurantTable?.rtype != 'RM'
                        : true) &&
                    (order.orderDetailsOrder?.orderType == 'pos' ||
                        order.orderDetailsOrder?.orderType == 'WalkIn' ||
                        order.orderDetailsOrder?.orderType == 'dinein'))) {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if ((order.restaurantTable != null
                        ? order.restaurantTable?.rtype != 'RM'
                        : true) &&
                    (order.orderDetailsOrder?.orderType == 'pos' ||
                        order.orderDetailsOrder?.orderType == 'WalkIn' ||
                        order.orderDetailsOrder?.orderType == 'dinein')) {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            order.restaurantTable?.tableNo != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.orderDetailsOrder?.userId != null &&
                            ((order.user?.phone?.length ?? 0) > 2 &&
                                (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true &&
                        (order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                            false))) {
                  if ((order.restaurantTable != null
                          ? order.restaurantTable?.rtype != 'RM'
                          : true) &&
                      (order.orderDetailsOrder?.orderType == 'pos' ||
                          order.orderDetailsOrder?.orderType == 'WalkIn' ||
                          order.orderDetailsOrder?.orderType == 'dinein')) {
                    return true;
                  }
                }
              }
            }
          }
        }

        //////////// Filter with Take Away
        else if (kdsController.selectedMainMenu == 1) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if (order.orderDetailsOrder?.orderType == 'take_away') {
                  return true;
                }
              } else if ((Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('table no') == true &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.orderDetailsOrder?.userId != null &&
                          ((order.user?.phone?.length ?? 0) > 2 &&
                              (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true &&
                      (order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase()) ??
                          false))) {
                if (order.orderDetailsOrder?.orderType == 'take_away') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (orderStatus == 2 ||
                ((Get.find<AuthController>()
                                .profileModel!
                                .restaurants
                                ?.first
                                .defOrdStatus ==
                            5 ||
                        Get.find<AuthController>()
                                .profileModel!
                                .restaurants
                                ?.first
                                .defOrdStatus ==
                            2)
                    ? (orderStatus == 7 || orderStatus == 5)
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if (order.orderDetailsOrder?.orderType == 'take_away') {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.orderDetailsOrder?.userId != null &&
                            ((order.user?.phone?.length ?? 0) > 2 &&
                                (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true &&
                        (order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                            false))) {
                  if (order.orderDetailsOrder?.orderType == 'take_away') {
                    return true;
                  }
                }
              }
            }
          }
        }
        ///////////    Filter with delivery
        else if (kdsController.selectedMainMenu == 2) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if (order.orderDetailsOrder?.orderType == 'delivery') {
                  return true;
                }
              } else if ((Get.find<AuthController>()
                              .profileModel
                              ?.restaurants
                              ?.first
                              .searchBy
                              ?.contains('table no') ==
                          true &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                      (order.deliveryAddress != null &&
                          (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                              false))) ||
                  // (
                  //     order.userName
                  //         .toUpperCase()
                  //         .contains(searchController.text.toUpperCase())) ||
                  // (order.userId != null &&
                  //     (order.user.fName
                  //             .toUpperCase()
                  //             .contains(searchController.text.toUpperCase()) ||
                  //         order.user.lName
                  //             .toUpperCase()
                  //             .contains(searchController.text.toUpperCase()))) ||

                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.deliveryAddress != null &&
                          ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                              (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') == true &&
                      (order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase()) ??
                          false))) {
                if (order.orderDetailsOrder?.orderType == 'delivery') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if (order.orderDetailsOrder?.orderType == 'delivery') {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('user id') == true &&
                        (order.deliveryAddress != null &&
                            (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                false))) ||
                    // (
                    //     order.userName
                    //         .toUpperCase()
                    //         .contains(searchController.text.toUpperCase())) ||
                    // (order.userId != null &&
                    //     (order.user.fName
                    //             .toUpperCase()
                    //             .contains(searchController.text.toUpperCase()) ||
                    //         order.user.lName
                    //             .toUpperCase()
                    //             .contains(searchController.text.toUpperCase()))) ||

                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.deliveryAddress != null &&
                            ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                                (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel?.restaurants?.first.searchBy?.contains('order id') == true &&
                        (order.orderDetailsOrder?.restaurantOrderId
                                ?.toUpperCase()
                                .contains(searchController.text.toUpperCase()) ??
                            false))) {
                  if (order.orderDetailsOrder?.orderType == 'delivery') {
                    return true;
                  }
                }
              }
            }
          }
        }
        ///////////    Filter with Room
        else if (kdsController.selectedMainMenu == 4) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if (order.restaurantTable != null &&
                    order.restaurantTable?.rtype == 'RM') {
                  return true;
                }
              } else if ((Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('table no') == true &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.orderDetailsOrder?.userId != null &&
                          ((order.user?.phone?.length ?? 0) > 2 &&
                              (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true &&
                      (order.orderDetailsOrder?.restaurantOrderId
                              ?.toUpperCase()
                              .contains(searchController.text.toUpperCase()) ??
                          false))) {
                if (order.restaurantTable != null &&
                    order.restaurantTable?.rtype == 'RM') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if (order.restaurantTable != null &&
                    order.restaurantTable?.rtype == 'RM') {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.orderDetailsOrder?.userId != null &&
                            ((order.user?.phone?.length ?? 0) > 2 &&
                                (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||

                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true &&
                        (order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                            false))) {
                  if (order.restaurantTable != null &&
                      order.restaurantTable?.rtype == 'RM') {
                    return true;
                  }
                }
              }
            }
          }
        }
        ////////////////   Filter with All
        else if (kdsController.selectedMainMenu == 3) {
          if (kdsController.selectedSubMenu == 1) {
            if (defOrderStatus == 2
                ? (orderStatus == 7 || orderStatus == 2)
                : (orderStatus == 1 || orderStatus == 7)) {
              if (searchController.text.isEmpty) {
                if ((order.restaurantTable != null &&
                        order.restaurantTable?.rtype == 'RM') ||
                    order.orderDetailsOrder?.orderType == 'delivery' ||
                    order.orderDetailsOrder?.orderType == 'take_away' ||
                    order.orderDetailsOrder?.orderType == 'pos' ||
                    order.orderDetailsOrder?.orderType == 'WalkIn' ||
                    order.orderDetailsOrder?.orderType == 'dinein') {
                  return true;
                }
              } else if ((Get.find<AuthController>()
                              .profileModel!
                              .restaurants
                              ?.first
                              .searchBy
                              ?.contains('table no') ==
                          true &&
                      (order.restaurantTable != null &&
                          (order.restaurantTable?.tableNo ?? '') != '' &&
                          ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                              (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                      ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                          (order.orderDetailsOrder?.userId != null &&
                              ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                  (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                      false))))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                      (order.deliveryAddress != null &&
                          ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                              (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                  false)))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                      (order.deliveryAddress != null && (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true && (order.orderDetailsOrder?.userId != null && (order.user?.phone?.length ?? 0) > 2 && (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||

                  // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
                  (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true && (order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) {
                if ((order.restaurantTable != null &&
                        order.restaurantTable?.rtype == 'RM') ||
                    order.orderDetailsOrder?.orderType == 'delivery' ||
                    order.orderDetailsOrder?.orderType == 'take_away' ||
                    order.orderDetailsOrder?.orderType == 'pos' ||
                    order.orderDetailsOrder?.orderType == 'WalkIn' ||
                    order.orderDetailsOrder?.orderType == 'dinein') {
                  return true;
                }
              }
            }
          } else if (kdsController.selectedSubMenu == 2) {
            if (((defOrderStatus == 5)
                ? (orderStatus == 7 || orderStatus == 5)
                : defOrderStatus == 2
                    ? orderStatus == 5
                    : orderStatus == 2)) {
              if (searchController.text.isEmpty) {
                if ((order.restaurantTable != null &&
                        order.restaurantTable?.rtype == 'RM') ||
                    order.orderDetailsOrder?.orderType == 'delivery' ||
                    order.orderDetailsOrder?.orderType == 'take_away' ||
                    order.orderDetailsOrder?.orderType == 'pos' ||
                    order.orderDetailsOrder?.orderType == 'WalkIn' ||
                    order.orderDetailsOrder?.orderType == 'dinein') {
                  return true;
                }
              } else {
                if ((Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('table no') == true &&
                        (order.restaurantTable != null &&
                            (order.restaurantTable?.tableNo ?? '') != '' &&
                            ((order.restaurantTable?.tableNo?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                (order.restaurantTable?.title?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                        ((order.orderDetailsOrder?.username?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                            (order.orderDetailsOrder?.userId != null &&
                                ((order.user?.fName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false) ||
                                    (order.user?.lName?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                        false))))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true &&
                        (order.deliveryAddress != null &&
                            ((order.deliveryAddress?.contactPersonNumber?.length ?? 0) > 2 &&
                                (order.deliveryAddress?.contactPersonNumber?.toUpperCase().contains(searchController.text.toUpperCase()) ??
                                    false)))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('user id') == true &&
                        (order.deliveryAddress != null &&
                            (order.deliveryAddress?.contactPersonName?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('phone no') == true && (order.orderDetailsOrder?.userId != null && (order.user?.phone?.length ?? 0) > 2 && (order.user?.phone?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) ||

                    // (order.userId != null && (order.user.phone.toUpperCase().contains(searchController.text.toUpperCase()))) ||
                    (Get.find<AuthController>().profileModel!.restaurants?.first.searchBy?.contains('order id') == true && (order.orderDetailsOrder?.restaurantOrderId?.toUpperCase().contains(searchController.text.toUpperCase()) ?? false))) {
                  if ((order.restaurantTable != null &&
                          order.restaurantTable?.rtype == 'RM') ||
                      order.orderDetailsOrder?.orderType == 'delivery' ||
                      order.orderDetailsOrder?.orderType == 'take_away' ||
                      order.orderDetailsOrder?.orderType == 'pos' ||
                      order.orderDetailsOrder?.orderType == 'WalkIn' ||
                      order.orderDetailsOrder?.orderType == 'dinein') {
                    return true;
                  }
                }
              }
            }
          }
        }
        return false;
      }).map((order) {
        // Now return the widget directly
        return KdsTabletOrderList(
          flutterTts: flutterTts,
          order: order,
          orderStatus: orderStatus,
          isPrintKot: widget.isPrintKot,
        );
      }).toList(),
    );
  }
}
