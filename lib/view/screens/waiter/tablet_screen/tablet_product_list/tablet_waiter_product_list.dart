import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
// import 'package:mygenie_restaurant/data/model/response/get_pos_order_list_response_model.dart';
import 'package:mygenie_restaurant/data/model/response/table_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/pos/beach_billing/billing_view_checkout.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/tablet_product_list/tablet_product_widget.dart';
import 'package:mygenie_restaurant/view/screens/pos/checkout_order_screen.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/widget/product_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../../../controller/product_controller.dart';
import '../../../../../controller/table_controller.dart';
import '../../../../../data/model/response/cart_model.dart';
import '../../../pos/widget/product_bottom_sheet.dart';

class TabletPosScreen extends StatefulWidget {
  final OrderList? editOrder;
  final TableResponseModel? selectedTable;

  TabletPosScreen({this.editOrder, this.selectedTable});
  @override
  State<TabletPosScreen> createState() => _TabletPosScreenState();
}

class _TabletPosScreenState extends State<TabletPosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addNoteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchTableController = TextEditingController();
  String orderUUID = '';

  List<Product> products = [];
  final _tableController = SuperTooltipController();

  @override
  void initState() {
    super.initState();

    initData();
  }

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      orderUUID =
          '${Get.find<AuthController>().profileModel!.restaurants!.first.id}-${Get.find<AuthController>().profileModel!.empId}-${DateTime.now().millisecondsSinceEpoch}';

      // Get.find<CartController>().clearTableList();
      Get.find<TableController>().setTableIndex(
          (widget.selectedTable == null || widget.editOrder == null)
              ? Get.find<TableController>().tableList.first
              : widget.selectedTable);
      Get.find<RestaurantController>().setFoodType('Normal');

      // if (Get.find<AuthController>()
      //             .profileModel!
      //             .restaurants!
      //             .first
      //             .isShowPopularCategory ==
      //         'Yes' &&
      //     Get.find<RestaurantController>().popularCategory.isEmpty)
      //   await Get.find<RestaurantController>().getPopularCategory();
      if (Get.find<RestaurantController>().posFoodCategoryList.isEmpty) {
        Get.find<RestaurantController>().getProductCategoryListFromLocal(
            Get.find<AuthController>().getProductCategoryList());
        // Get.find<RestaurantController>().setCategoryList();
      }
      Get.find<RestaurantController>().setPOSWaiterCategoryIndex(0);
      if (Get.find<RestaurantController>().productList.isEmpty) {
        Get.find<RestaurantController>().getProductListFromLocal(
            Get.find<AuthController>().getProductList());
      }
      Get.find<CartController>().calculationCart();
      // print(Get.find<RestaurantController>().productList.first.qty);
      products = Get.find<AuthController>().getProductList();
      Get.find<RestaurantController>().update();
      // if (Get.find<CartController>().tableList.isEmpty) {
      // await Get.find<CartController>().getTableList();
      // }
      if (widget.editOrder != null && (widget.editOrder?.tableId ?? 0) != 0) {
        Get.find<CartController>().editTableList(TableResponseModel(
          id: widget.editOrder?.tableId ?? 0,
          title: widget.editOrder?.restaurantTable?.title ?? '',
          tableNo: widget.editOrder?.restaurantTable?.tableNo ?? '',
        ));
        for (var i = 0; i < Get.find<CartController>().tableList.length; i++) {
          if ((widget.editOrder?.tableId ?? 0) ==
              Get.find<CartController>().tableList[i].id) {
            Get.find<CartController>()
                .setTableIndex(Get.find<CartController>().tableList[i]);
          }
        }
      }
      _nameController.text = widget.editOrder?.userName ?? '';
      if (widget.editOrder?.user != null) {
        _nameController.text =
            '${widget.editOrder?.user?.fName ?? ''} ${widget.editOrder?.user?.lName ?? ''}';
        _emailController.text = widget.editOrder?.user?.email ?? '';
        _phoneController.text = widget.editOrder?.user?.phone ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isItemCodeSearch = Get.find<AuthController>()
        .profileModel!
        .restaurants!
        .first
        .settings!
        .shortCode;
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              // toolbarHeight: Get.height / 10.72,
              backgroundColor: Colors.white,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: ColorTheme.green,
                  onPressed: () {
                    Get.back();
                  }),
              titleSpacing: 0,
              elevation: 0,
              centerTitle: false,

              title: Text(
                widget.editOrder != null
                    ? widget.editOrder?.restaurantTable == null ||
                            widget.editOrder?.restaurantTable?.tableNo == ''
                        ? widget.editOrder?.orderType == 'delivery'
                            ? 'Delivery'
                            : widget.editOrder?.orderType == 'take_away'
                                ? 'Take Away'
                                : 'WC'
                        : widget.editOrder?.restaurantTable?.title == ''
                            ? '#${widget.editOrder?.restaurantTable?.tableNo ?? ''}'
                            : '#${widget.editOrder?.restaurantTable?.title ?? ''}-${widget.editOrder?.restaurantTable?.tableNo ?? ''}'
                    : 'Add Table',
                style: poppinsSemiBold.copyWith(
                    color: Colors.black, fontSize: 8.sp),
              ),
              actions: [
                if (Get.find<AuthController>()
                        .profileModel!
                        .restaurants!
                        .first
                        .isShowAcNonAcMenu ==
                    'Yes')
                  GetBuilder<RestaurantController>(builder: (restController) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: SizedBox(
                            width: 45,
                            child: CupertinoSwitch(
                              value: restController.isNormal !=
                                  'Normal', // Current state of the switch
                              onChanged: (bool value) {
                                restController
                                    .setFoodType(value ? 'Premium' : 'Normal');
                              },
                            ),
                          ),
                        ),
                        Text(
                          'AC', // Display the current mode
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: Colors.black),
                        ),
                        // Add some space between text and switch
                      ],
                    );
                  }),
                Padding(
                  padding: const EdgeInsets.only(left: 13),
                  child: GetBuilder<CartController>(builder: (posController) {
                    return posController.cartList.isEmpty
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Get.find<CartController>().clearCartList();
                              products =
                                  Get.find<AuthController>().getProductList();

                              // Get.find<RestaurantController>()
                              //     .getWaiterProductList('1', 'all');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(
                                  right: 20, top: 13, bottom: 13),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: ColorTheme.appColor),
                              child: Center(
                                child: Text(
                                  'Clear Cart'.tr,
                                  style: poppinsMedium.copyWith(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          );
                  }),
                ),
              ],
            ),
            body: SafeArea(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: GetBuilder<RestaurantController>(
                      builder: (restController) {
                    return GetBuilder<ProductController>(
                        builder: (productController) {
                      return GetBuilder<CartController>(
                          builder: (posController) {
                        return posController.isLoading ||
                                restController.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  // Divider(),
                                  SizedBox(
                                      height: Dimensions.PADDING_SIZE_DEFAULT),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.PADDING_SIZE_DEFAULT),
                                    child: Row(
                                      children: [
                                        // GetBuilder<TableController>(
                                        //     builder: (tableController) {
                                        //   return tableController
                                        //           .tableList.isEmpty
                                        //       ? SizedBox.shrink()
                                        //       : IgnorePointer(
                                        //           ignoring:
                                        //               widget.editOrder != null,
                                        //           child: Container(
                                        //             height: 50,
                                        //             width: Get.width * 0.3,
                                        //             padding: EdgeInsets.symmetric(
                                        //                 horizontal: Dimensions
                                        //                     .PADDING_SIZE_SMALL),
                                        //             decoration: BoxDecoration(
                                        //               border: Border.all(
                                        //                   color: ColorTheme
                                        //                       .borderGrey),
                                        //               // color: ColorTheme.borderGrey,
                                        //               borderRadius:
                                        //                   BorderRadius.circular(
                                        //                       7),
                                        //             ),
                                        //             child: TypeAheadField(
                                        //               textFieldConfiguration:
                                        //                   TextFieldConfiguration(
                                        //                       controller:
                                        //                           _searchTableController,
                                        //                       textInputAction:
                                        //                           TextInputAction
                                        //                               .search,
                                        //                       textCapitalization:
                                        //                           TextCapitalization
                                        //                               .words,
                                        //                       keyboardType:
                                        //                           TextInputType
                                        //                               .streetAddress,
                                        //                       decoration:
                                        //                           InputDecoration(
                                        //                         // suffixIcon: Icon(
                                        //                         //   Icons.arrow_drop_down,
                                        //                         //   color: ColorTheme
                                        //                         //       .appColor,
                                        //                         // ),
                                        //                         contentPadding:
                                        //                             EdgeInsets.only(
                                        //                                 bottom:
                                        //                                     0,
                                        //                                 left: 0,
                                        //                                 right:
                                        //                                     0),
                                        //                         hintText: tableController
                                        //                                     .selectedTable ==
                                        //                                 null
                                        //                             ? '${tableController.tableList.first.title} ${tableController.tableList.first.tableNo}'
                                        //                             : '${tableController.selectedTable?.title ?? ''} ${tableController.selectedTable?.tableNo ?? ''}',
                                        //                         // labelText: posController
                                        //                         //             .selectedTable ==
                                        //                         //         null
                                        //                         //     ? '${posController.tableList.first.title} ${posController.tableList.first.tableNo}'
                                        //                         //     : '${posController.selectedTable.title} ${posController.selectedTable.tableNo}',
                                        //                         // hintText: posController
                                        //                         //             .selectedTable ==
                                        //                         //         null
                                        //                         //     ? '${posController.tableList.first.title} ${posController.tableList.first.tableNo}'
                                        //                         //     : '${posController.selectedTable.title} ${posController.selectedTable.tableNo}',
                                        //                         border:
                                        //                             OutlineInputBorder(
                                        //                           borderRadius:
                                        //                               BorderRadius
                                        //                                   .circular(
                                        //                                       7),
                                        //                           borderSide: const BorderSide(
                                        //                               style: BorderStyle
                                        //                                   .none,
                                        //                               width: 0),
                                        //                         ),
                                        //                         hintStyle: poppinsMedium
                                        //                             .copyWith(
                                        //                                 fontSize:
                                        //                                     15,
                                        //                                 color: ColorTheme
                                        //                                     .hintText),
                                        //                         filled: true,
                                        //                         fillColor:
                                        //                             Colors
                                        //                                 .white,
                                        //                       ),
                                        //                       style: poppinsMedium
                                        //                           .copyWith(
                                        //                               fontSize:
                                        //                                   15,
                                        //                               color: Colors
                                        //                                   .black)),
                                        //               suggestionsCallback:
                                        //                   (pattern) async {
                                        //                 return await tableController
                                        //                     .searchTable(
                                        //                         context,
                                        //                         pattern);
                                        //               },
                                        //               itemBuilder: (context,
                                        //                   TableResponseModel
                                        //                       suggestion) {
                                        //                 return Column(
                                        //                   children: [
                                        //                     Padding(
                                        //                       padding:
                                        //                           const EdgeInsets
                                        //                               .symmetric(
                                        //                               vertical:
                                        //                                   8,
                                        //                               horizontal:
                                        //                                   3),
                                        //                       child: Text(
                                        //                         '${suggestion.title} ${suggestion.tableNo}',
                                        //                         style: poppinsMedium.copyWith(
                                        //                             fontSize:
                                        //                                 15,
                                        //                             color: suggestion.tableNo ==
                                        //                                         'Delivery' ||
                                        //                                     suggestion.tableNo ==
                                        //                                         'Take Away'
                                        //                                 ? ColorTheme
                                        //                                     .appColor
                                        //                                 : ColorTheme
                                        //                                     .hintText),
                                        //                         maxLines: 1,
                                        //                         overflow:
                                        //                             TextOverflow
                                        //                                 .ellipsis,
                                        //                       ),
                                        //                     ),
                                        //                     Divider(
                                        //                       color: ColorTheme
                                        //                           .hintText,
                                        //                       height: 0,
                                        //                     )
                                        //                   ],
                                        //                 );
                                        //               },
                                        //               onSuggestionSelected:
                                        //                   (TableResponseModel
                                        //                       suggestion) async {
                                        //                 tableController
                                        //                     .setTableIndex(
                                        //                         suggestion);
                                        //                 _searchTableController
                                        //                         .text =
                                        //                     '${suggestion.title} ${suggestion.tableNo}'
                                        //                         .trim();
                                        //               },
                                        //             ),
                                        //           ),
                                        //           //  SuperTooltip(
                                        //           //   borderRadius: 2,
                                        //           //   // bottom: 50,
                                        //           //   hasShadow: false,
                                        //           //   borderColor:
                                        //           //       ColorTheme.borderGrey,
                                        //           //   // shadowColor: Colors.black
                                        //           //   //     .withOpacity(0.1),
                                        //           //   showBarrier: true,
                                        //           //   controller: _tableController,
                                        //           //   borderWidth: 1,
                                        //           //   popupDirection:
                                        //           //       TooltipDirection.down,
                                        //           //   backgroundColor: Colors.white,
                                        //           //   left: 15,
                                        //           //   right: Get.width * 0.6 + 25,
                                        //           //   arrowTipDistance: 20,
                                        //           //   arrowBaseWidth: 0,
                                        //           //   arrowLength: 0,
                                        //           //   // borderWidth: 2.0,
                                        //           //   // showCloseButton:
                                        //           //   //     ShowCloseButton.none,
                                        //           //   touchThroughAreaShape:
                                        //           //       ClipAreaShape.rectangle,
                                        //           //   touchThroughAreaCornerRadius: 5,
                                        //           //   minimumOutsideMargin: 0,
                                        //           //   barrierColor:
                                        //           //       Colors.transparent,

                                        //           //   content: ListView.builder(
                                        //           //       shrinkWrap: true,
                                        //           //       padding: EdgeInsets.zero,
                                        //           //       itemCount: posController
                                        //           //           .tableList.length,
                                        //           //       itemBuilder:
                                        //           //           (BuildContext context,
                                        //           //               int index) {
                                        //           //         return InkWell(
                                        //           //           onTap: () async {
                                        //           //             posController
                                        //           //                 .setTableIndex(
                                        //           //                     posController
                                        //           //                             .tableList[
                                        //           //                         index]);
                                        //           //             await _tableController
                                        //           //                 .hideTooltip();
                                        //           //           },
                                        //           //           child: Column(
                                        //           //             crossAxisAlignment:
                                        //           //                 CrossAxisAlignment
                                        //           //                     .start,
                                        //           //             children: [
                                        //           //               Padding(
                                        //           //                 padding: EdgeInsets.only(
                                        //           //                     left: 20,
                                        //           //                     bottom: posController.tableList.length -
                                        //           //                                 1 ==
                                        //           //                             index
                                        //           //                         ? 10
                                        //           //                         : 0,
                                        //           //                     top:
                                        //           //                         index == 0
                                        //           //                             ? 10
                                        //           //                             : 0),
                                        //           //                 child: Text(
                                        //           //                   '${posController.tableList[index].title} ${posController.tableList[index].tableNo}',
                                        //           //                   style: poppinsMedium.copyWith(
                                        //           //                       fontSize:
                                        //           //                           15,
                                        //           //                       color: posController.tableList[index].tableNo ==
                                        //           //                                   'Delivery' ||
                                        //           //                               posController.tableList[index].tableNo ==
                                        //           //                                   'Take Away'
                                        //           //                           ? ColorTheme
                                        //           //                               .appColor
                                        //           //                           : ColorTheme
                                        //           //                               .hintText),
                                        //           //                 ),
                                        //           //               ),
                                        //           //               if (posController
                                        //           //                           .tableList
                                        //           //                           .length -
                                        //           //                       1 !=
                                        //           //                   index)
                                        //           //                 Padding(
                                        //           //                   padding: EdgeInsets
                                        //           //                       .only(
                                        //           //                           top: 10,
                                        //           //                           bottom:
                                        //           //                               10),
                                        //           //                   child: Divider(
                                        //           //                       height: 1,
                                        //           //                       color: ColorTheme
                                        //           //                           .borderGrey),
                                        //           //                 ),
                                        //           //             ],
                                        //           //           ),
                                        //           //         );
                                        //           //       }),
                                        //           //   child: Container(
                                        //           //     height: 50,
                                        //           //     width: Get.width * 0.3,
                                        //           //     padding: EdgeInsets.symmetric(
                                        //           //         horizontal: Dimensions
                                        //           //             .PADDING_SIZE_SMALL),
                                        //           //     decoration: BoxDecoration(
                                        //           //       border: Border.all(
                                        //           //           color: ColorTheme
                                        //           //               .borderGrey),
                                        //           //       // color: ColorTheme.borderGrey,
                                        //           //       borderRadius:
                                        //           //           BorderRadius.circular(
                                        //           //               7),
                                        //           //     ),
                                        //           //     child: Row(
                                        //           //       children: [
                                        //           //         Expanded(
                                        //           //           child: Text(
                                        //           //             posController
                                        //           //                         .selectedTable ==
                                        //           //                     null
                                        //           //                 ? '${posController.tableList.first.title} ${posController.tableList.first.tableNo}'
                                        //           //                 : '${posController.selectedTable.title} ${posController.selectedTable.tableNo}',
                                        //           //             maxLines: 1,
                                        //           //             style: poppinsMedium
                                        //           //                 .copyWith(
                                        //           //               color: ColorTheme
                                        //           //                   .hintText,
                                        //           //               fontSize: 15,
                                        //           //             ),
                                        //           //           ),
                                        //           //         ),
                                        //           //         Icon(
                                        //           //             Icons
                                        //           //                 .keyboard_arrow_down_rounded,
                                        //           //             color: ColorTheme
                                        //           //                 .appColor)
                                        //           //       ],
                                        //           //     ),
                                        //           //   ),
                                        //           // ),
                                        //         );
                                        // }),
                                        GetBuilder<TableController>(
                                            builder: (tableController) {
                                          return tableController
                                                  .tableList.isEmpty
                                              ? const SizedBox.shrink()
                                              : Expanded(
                                                  child: Container(
                                                    width: Get
                                                        .width, // Bounded width to avoid constraints error
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .PADDING_SIZE_DEFAULT),
                                                    child: IgnorePointer(
                                                      ignoring:
                                                          widget.editOrder !=
                                                              null,
                                                      child: Container(
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: ColorTheme
                                                                  .borderGrey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            // Search Field
                                                            Expanded(
                                                              flex: 5,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                                child: TypeAheadField<
                                                                    TableResponseModel>(
                                                                  textFieldConfiguration:
                                                                      TextFieldConfiguration(
                                                                    controller:
                                                                        _searchTableController,
                                                                    textInputAction:
                                                                        TextInputAction
                                                                            .search,
                                                                    textCapitalization:
                                                                        TextCapitalization
                                                                            .words,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .streetAddress,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              0),
                                                                      hintText: tableController.selectedTable ==
                                                                              null
                                                                          ? 'Search Tables'
                                                                          : '${tableController.selectedTable!.title} ${tableController.selectedTable!.tableNo}',
                                                                      hintStyle: poppinsMedium.copyWith(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              ColorTheme.hintText),
                                                                      border: InputBorder
                                                                          .none,
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                    style: poppinsMedium.copyWith(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  suggestionsCallback:
                                                                      (pattern) async {
                                                                    return await tableController.searchTable(
                                                                        context,
                                                                        pattern);
                                                                  },
                                                                  itemBuilder: (context,
                                                                      TableResponseModel
                                                                          suggestion) {
                                                                    return Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 8,
                                                                              horizontal: 3),
                                                                          child:
                                                                              Text(
                                                                            '${suggestion.title} ${suggestion.tableNo}',
                                                                            style:
                                                                                poppinsMedium.copyWith(
                                                                              fontSize: 15,
                                                                              color: suggestion.tableNo == 'Delivery' || suggestion.tableNo == 'Take Away' ? ColorTheme.appColor : ColorTheme.hintText,
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Divider(
                                                                            color:
                                                                                ColorTheme.hintText,
                                                                            height: 1),
                                                                      ],
                                                                    );
                                                                  },
                                                                  onSuggestionSelected:
                                                                      (TableResponseModel
                                                                          suggestion) {
                                                                    tableController
                                                                        .setTableIndex(
                                                                            suggestion);
                                                                    _searchTableController
                                                                            .text =
                                                                        '${suggestion.title} ${suggestion.tableNo}'
                                                                            .trim();
                                                                    Get.find<
                                                                            CartController>()
                                                                        .calculationCart();
                                                                    Get.find<
                                                                            CartController>()
                                                                        .update();
                                                                  },
                                                                ),
                                                              ),
                                                            ),

                                                            VerticalDivider(
                                                              color: ColorTheme
                                                                  .borderGrey,
                                                            ),
                                                            // Popup Menu Button
                                                            Expanded(
                                                              child: Container(
                                                                width: 50,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0),
                                                                child: PopupMenuButton<
                                                                    TableResponseModel>(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                      color: ColorTheme
                                                                          .appColor),
                                                                  onSelected:
                                                                      (TableResponseModel
                                                                          table) {
                                                                    tableController
                                                                        .setTableIndex(
                                                                            table);
                                                                    _searchTableController
                                                                            .text =
                                                                        '${table.title} ${table.tableNo}'
                                                                            .trim();
                                                                    Get.find<
                                                                            CartController>()
                                                                        .calculationCart();
                                                                    Get.find<
                                                                            CartController>()
                                                                        .update();
                                                                  },
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return tableController
                                                                        .tableList
                                                                        .where((t) =>
                                                                            t.isEngage !=
                                                                            'Yes')
                                                                        .map((TableResponseModel
                                                                            table) {
                                                                      return PopupMenuItem<
                                                                          TableResponseModel>(
                                                                        value:
                                                                            table,
                                                                        child:
                                                                            Text(
                                                                          '${table.title} ${table.tableNo}',
                                                                          style:
                                                                              poppinsMedium.copyWith(
                                                                            fontSize:
                                                                                15,
                                                                            color: table.tableNo == 'Delivery' || table.tableNo == 'Take Away'
                                                                                ? ColorTheme.appColor
                                                                                : ColorTheme.hintText,
                                                                          ),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      );
                                                                    }).toList();
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                        }),
                                        SizedBox(width: 10),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: ColorTheme.borderGrey),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Center(
                                              child: TextField(
                                                controller: _searchController,
                                                textInputAction:
                                                    TextInputAction.search,
                                                autofocus: false,
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                keyboardType:
                                                    TextInputType.name,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 10),
                                                  suffixIcon: Icon(Icons.search,
                                                      color:
                                                          ColorTheme.appColor),
                                                  hintText:
                                                      '${Get.find<AuthController>().profileModel!.restaurants!.first.searchFood}',
                                                  hintStyle:
                                                      poppinsMedium.copyWith(
                                                          fontSize: 15,
                                                          color: ColorTheme
                                                              .hintText),
                                                  filled: true,
                                                  fillColor: Theme.of(context)
                                                      .cardColor,
                                                ),
                                                style: poppinsMedium.copyWith(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                                onChanged: (value) async {
                                                  if (restController
                                                          .categoryIndex !=
                                                      0)
                                                    restController
                                                        .setPOSWaiterCategoryIndex(
                                                            0);
                                                  restController.update();
                                                },
                                                onSubmitted: (value) {
                                                  isItemCodeSearch == 'Yes' ||
                                                          isItemCodeSearch ==
                                                              'Both'
                                                      ? _handleEnterKeyPress(
                                                          restController,
                                                          isItemCodeSearch ??
                                                              'No')
                                                      : null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    child: Divider(
                                      color: Color(0xFFE6E6E6),
                                      height: 1,
                                    ),
                                  ),
                                  // if (restController.popularCategory
                                  //     .where((e) => e.id != 0)
                                  //     .isNotEmpty)
                                  //   Padding(
                                  //     padding: const EdgeInsets.symmetric(
                                  //         horizontal: 15),
                                  //     child: SizedBox(
                                  //       height:
                                  //           MediaQuery.of(context).size.width >
                                  //                   1600
                                  //               ? 45
                                  //               : 33,
                                  //       child: ListView.builder(
                                  //         itemCount: restController
                                  //             .popularCategory
                                  //             .where((e) => e.id != 0)
                                  //             .length,
                                  //         scrollDirection: Axis.horizontal,
                                  //         itemBuilder: (context, index) {
                                  //           final category = restController
                                  //               .popularCategory
                                  //               .where((e) => e.id != 0)
                                  //               .toList()[index];
                                  //           final isSelected =
                                  //               restController.categoryIndex ==
                                  //                   category.id;
                                  //           return InkWell(
                                  //             onTap: () {
                                  //               restController
                                  //                   .setPOSWaiterCategoryIndex(
                                  //                       category.id);
                                  //               FocusManager
                                  //                   .instance.primaryFocus
                                  //                   ?.unfocus();
                                  //               _searchController.clear();
                                  //             },
                                  //             child: Container(
                                  //               margin: EdgeInsets.only(
                                  //                   left: index == 0 ? 0 : 11),
                                  //               padding: EdgeInsets.symmetric(
                                  //                   horizontal: 10),
                                  //               decoration: BoxDecoration(
                                  //                 border: Border.all(
                                  //                     color: isSelected
                                  //                         ? ColorTheme.appColor
                                  //                         : ColorTheme
                                  //                             .borderGrey),
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(7),
                                  //                 color: isSelected
                                  //                     ? ColorTheme.appColor
                                  //                     : Colors.white,
                                  //               ),
                                  //               child: Center(
                                  //                 child: Text(
                                  //                   category.name,
                                  //                   style: poppinsMedium.copyWith(
                                  //                       fontSize: MediaQuery.of(
                                  //                                       context)
                                  //                                   .size
                                  //                                   .width >
                                  //                               1600
                                  //                           ? 20
                                  //                           : 14,
                                  //                       color: isSelected
                                  //                           ? Colors.white
                                  //                           : Colors.grey),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           );
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ),
                                  // if (restController.popularCategory
                                  //         .where((e) => e.id != 0)
                                  //         .isNotEmpty &&
                                  //     productController
                                  //         .popularFoodList.isNotEmpty)
                                  //   SizedBox(height: 10),
                                  if (productController
                                      .popularFoodList.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    1600
                                                ? 45
                                                : 33,
                                        child: ListView.builder(
                                          // scrollDirection: Axis.horizontal,
                                          itemCount: productController
                                              .popularFoodList.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              // onTap: () {
                                              //   FocusManager
                                              //       .instance.primaryFocus
                                              //       ?.unfocus();
                                              //   _searchController.clear();

                                              //   if ((productController
                                              //               .popularFoodList[
                                              //                   index]
                                              //               .price !=
                                              //           1 &&
                                              //       Get.find<AuthController>()
                                              //               .profileModel!
                                              //               .restaurants!
                                              //               .first
                                              //               .foodLevelNotes !=
                                              //           'Yes' &&
                                              //       (productController
                                              //                   .popularFoodList[
                                              //                       index]
                                              //                   .variations ==
                                              //               null ||
                                              //           productController
                                              //               .popularFoodList[
                                              //                   index]
                                              //               .variations!
                                              //               .isEmpty) &&
                                              //       (productController
                                              //                   .popularFoodList[
                                              //                       index]
                                              //                   .addOns ==
                                              //               null ||
                                              //           productController
                                              //               .popularFoodList[
                                              //                   index]
                                              //               .addOns!
                                              //               .isEmpty))) {
                                              //                 print('POPULAR SIMPLE FLOW');
                                              //     CartModel _cartModel =
                                              //         CartModel(
                                              //             adjustPrice: 1,
                                              //             price: productController
                                              //                 .popularFoodList[
                                              //                     index]
                                              //                 .price!,
                                              //             discountedPrice:
                                              //                 productController
                                              //                     .popularFoodList[
                                              //                         index]
                                              //                     .price!,
                                              //             // discountAmount: 0,
                                              //             quantity: 1,
                                              //             addOnIds: [],
                                              //             addOns: [],
                                              //             // isCampaign: false,
                                              //             product: productController
                                              //                     .popularFoodList[
                                              //                 index],
                                              //             variation: []);
                                              //     productController
                                              //         .popularFoodList[index]
                                              //         .isAddFirstTime = false;
                                              //     Get.find<CartController>()
                                              //         .addToCart(
                                              //             _cartModel, null);
                                              //     if (productController
                                              //             .popularFoodList[
                                              //                 index]
                                              //             .qty !=
                                              //         null) {
                                              //       productController
                                              //           .popularFoodList[index]
                                              //           .qty = productController
                                              //               .popularFoodList[
                                              //                   index]
                                              //               .qty! +
                                              //           1;
                                              //     } else {
                                              //       productController
                                              //           .popularFoodList[index]
                                              //           .qty = 1;
                                              //     }
                                              //     // Get.find<RestaurantController>().update();
                                              //   } else {
                                              //     print('POPULAR NOT SIMPLE FLOW');
                                              //     Get.find<CartController>()
                                              //         .initData(
                                              //             productController
                                              //                     .popularFoodList[
                                              //                 index],
                                              //             null);

                                              //     Get.bottomSheet(
                                              //         ProductBottomSheet(
                                              //             onIncrease: (data) {},
                                              //             product: productController
                                              //                     .popularFoodList[
                                              //                 index],
                                              //             isCampaign: false),
                                              //         backgroundColor:
                                              //             Colors.transparent,
                                              //         isScrollControlled: true,
                                              //         ignoreSafeArea: false);
                                              //   }
                                              // },
                                              onTap: () {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                _searchController.clear();

                                                final product =
                                                    productController
                                                        .popularFoodList[index];

                                                Get.find<CartController>()
                                                    .onAddProduct(product);

                                                final productIndex =
                                                     restController.productList.indexWhere(
                                                  (e) => e.id == product.id,
                                                );

                                                if (productIndex != -1) {
                                                  swapToTop(productIndex);
                                                }
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: index == 0 ? 0 : 11),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  color: Colors.white,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    productController
                                                        .popularFoodList[index]
                                                        .name!,
                                                    style: poppinsMedium.copyWith(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                1600
                                                            ? 20
                                                            : 14,
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  if (restController.popularCategory
                                          .where((e) => e.id != 0)
                                          .isNotEmpty ||
                                      productController
                                          .popularFoodList.isNotEmpty)
                                    SizedBox(height: 20),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  Dimensions.PADDING_SIZE_LARGE,
                                              left: Dimensions
                                                  .PADDING_SIZE_DEFAULT),
                                          height: Get.height,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  1600
                                              ? Get.width * 0.15
                                              : Get.width * 0.25,
                                          decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  248, 248, 248, 1.0),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions
                                                          .RADIUS_DEFAULT)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL,
                                              horizontal: Dimensions
                                                  .PADDING_SIZE_SMALL),
                                          child: ListView.builder(
                                            // scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: restController
                                                .posFoodCategoryList.length,

                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () {
                                                  restController
                                                      .setPOSWaiterCategoryIndex(
                                                          restController
                                                              .posFoodCategoryList[
                                                                  index]
                                                              .id);
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                  _searchController.clear();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .PADDING_SIZE_EXTRA_SMALL,
                                                      vertical: 10),
                                                  margin: EdgeInsets.only(
                                                    top: Dimensions
                                                        .PADDING_SIZE_DEFAULT,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(Dimensions
                                                            .RADIUS_DEFAULT),
                                                    color: restController
                                                                .posFoodCategoryList[
                                                                    index]
                                                                .id ==
                                                            restController
                                                                .categoryIndex
                                                        ? ColorTheme.appColor
                                                        : Colors.white,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      restController
                                                          .posFoodCategoryList[
                                                              index]
                                                          .name,
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width >
                                                                  1600
                                                              ? 20
                                                              : 14,
                                                          color: restController
                                                                      .posFoodCategoryList[
                                                                          index]
                                                                      .id ==
                                                                  restController
                                                                      .categoryIndex
                                                              ? Colors.white
                                                              : Color.fromRGBO(
                                                                  152,
                                                                  152,
                                                                  152,
                                                                  1.0)),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        MediaQuery.of(context).size.width > 1600
                                            ? Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15),
                                                  child: SingleChildScrollView(
                                                      child: _searchController
                                                              .text.isNotEmpty
                                                          ? searchProductList(
                                                              restController,
                                                              isItemCodeSearch ??
                                                                  'No')
                                                          : productList(
                                                              restController)),
                                                ),
                                              )
                                            : SizedBox(
                                                width: Get.width * 0.7,
                                                child: ListView.builder(
                                                  key: UniqueKey(),
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      restController.productList.length ?? 0,
                                                  padding: EdgeInsets.all(
                                                      Dimensions
                                                          .PADDING_SIZE_SMALL),
                                                  itemBuilder:
                                                      (context, index) {
                                                    // print(products[index]
                                                    //     .itemCode);
                                                    // print(products[index].name);
                                                    return restController.productList[index]
                                                                .name!
                                                                .toUpperCase() ==
                                                            'CHECK IN'
                                                        ? SizedBox.shrink()
                                                        : (DateConverter.isAvailable(
                                                                    restController.productList[index]
                                                                        .availableTimeStarts!,
                                                                   restController.productList[index]
                                                                        .availableTimeEnds!) 
                                                                //         &&
                                                                // restController
                                                                //         .isNormal ==
                                                                //    restController.productList[index]
                                                                //         .foodFor
                                                                        )
                                                            ? (isItemCodeSearch ==
                                                                        'Yes'
                                                                    ? (restController.productList[index].itemCode !=
                                                                            null &&
                                                                        (_searchController.text.isEmpty ||
                                                                            restController.productList[index].itemCode!.toLowerCase() ==
                                                                                _searchController.text
                                                                                    .toLowerCase()))
                                                                    : isItemCodeSearch ==
                                                                            'No'
                                                                        ? (restController.productList[index]
                                                                            .name!
                                                                            .toLowerCase()
                                                                            .contains(_searchController.text.toLowerCase()))
                                                                        : (restController.productList[index].itemCode != null && (_searchController.text.isEmpty || restController.productList[index].itemCode!.toLowerCase() == _searchController.text.toLowerCase())) || (restController.productList[index].name!.toLowerCase().contains(_searchController.text.toLowerCase())))
                                                                ? restController.posFoodCategoryList.isEmpty
                                                                    ? WaiterProductWidget(
                                                                        products:
                                                                            restController.productList,
                                                                        scrollController:
                                                                            _scrollController,
                                                                        emailController:
                                                                            _emailController,
                                                                        nameController:
                                                                            _nameController,
                                                                        phoneController:
                                                                            _phoneController,
                                                                        searchController:
                                                                            _searchController,
                                                                        product:
                                                                           restController.productList[index],
                                                                        index:
                                                                            index,
                                                                        length:
                                                                            restController.productList.length,
                                                                        isCampaign:
                                                                            false,
                                                                      )
                                                                    : restController.categoryIndex == 0
                                                                        ? WaiterProductWidget(
                                                                            products:
                                                                                restController.productList,
                                                                            scrollController:
                                                                                _scrollController,
                                                                            emailController:
                                                                                _emailController,
                                                                            nameController:
                                                                                _nameController,
                                                                            phoneController:
                                                                                _phoneController,
                                                                            searchController:
                                                                                _searchController,
                                                                            product:
                                                                                restController.productList[index],
                                                                            index:
                                                                                index,
                                                                            length:
                                                                                restController.productList.length,
                                                                            isCampaign:
                                                                                false,
                                                                          )
                                                                        : restController.productList[index].mainCategoryId!.contains(restController.categoryIndex.toString())
                                                                            ? WaiterProductWidget(
                                                                                products: restController.productList,
                                                                                scrollController: _scrollController,
                                                                                emailController: _emailController,
                                                                                nameController: _nameController,
                                                                                phoneController: _phoneController,
                                                                                searchController: _searchController,
                                                                                product:restController.productList[index],
                                                                                index: index,
                                                                                length: restController.productList.length,
                                                                                isCampaign: false,
                                                                              )
                                                                            : const SizedBox.shrink()
                                                                : SizedBox.shrink()
                                                            : SizedBox.shrink();
                                                  },
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                      });
                    });
                  })),
            ),
            bottomNavigationBar:
                GetBuilder<CartController>(builder: (cartController) {
              return cartController.cartList.isNotEmpty
                  ? SafeArea(
                      child: Container(
                      height: 90,
                      width: Get.width,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions
                            .PADDING_SIZE_LARGE, /* vertical: Dimensions.PADDING_SIZE_SMALL*/
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF2A2A2A).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5))
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${'item'.tr}: ${cartController.cartList.length}',
                                      style:
                                          poppinsMedium.copyWith(fontSize: 16)),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isComplementry !=
                                      'Yes')
                                    const SizedBox(
                                        height: Dimensions
                                            .PADDING_SIZE_EXTRA_SMALL),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isComplementry !=
                                      'Yes')
                                    Text(
                                      '${'Total'.tr}: ${PriceConverter.convertPrice(cartController.calculationCart())}',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 18,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                ]),
                            InkWell(
                              onTap: () async {
                                Get.find<CartController>().update();
                                _searchController.clear();
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .billingUserView ==
                                    'Yes') {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BillingViewCheckout()));
                                } else {
                                  print('windows/tablet prodcut list screen');
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => POSCartScreen(
                                              phoneNumber:
                                                  _phoneController.text.isEmpty
                                                      ? ''
                                                      : _phoneController.text,
                                              orderUUID: orderUUID,
                                              editOrder: widget.editOrder,
                                              // name: _nameController.text.isEmpty
                                              //     ? ''
                                              //     : _nameController.text,
                                              notes: _addNoteController
                                                      .text.isEmpty
                                                  ? ''
                                                  : _addNoteController.text)));
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                    vertical: Dimensions.PADDING_SIZE_SMALL),
                                decoration: BoxDecoration(
                                    color: ColorTheme.appColor,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_DEFAULT)),
                                child: Text(
                                  'Review Order',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                    ))
                  : const SizedBox();
            })),
      ),
    );
  }

  Widget productList(RestaurantController restController) {
    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      spacing: 15,
      runSpacing: 15,
      children: restController.productList
          .where((e) => (e.name!.toUpperCase() != 'CHECK In' &&
              (DateConverter.isAvailable(
                      e.availableTimeStarts!, e.availableTimeEnds!) &&
                  (restController.categoryIndex == 0 ||
                      e.mainCategoryId!
                          .contains(restController.categoryIndex.toString())))))
          .map((product) {
        return TVWaiterProductWidget(
          products: products,
          scrollController: _scrollController,
          emailController: _emailController,
          nameController: _nameController,
          phoneController: _phoneController,
          searchController: _searchController,
          product: product,
          index: restController.productList.indexOf(product),
          length: restController.productList.length,
          isCampaign: false,
        );
      }).toList(),
    );
  }

  Widget searchProductList(
      RestaurantController restController, String isItemCodeSearch) {
    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      spacing: 15,
      runSpacing: 15,
      children: restController.productList
          .where((e) => (e.name!.toUpperCase() != 'CHECK In' &&
              (DateConverter.isAvailable(
                      e.availableTimeStarts!, e.availableTimeEnds!) &&
                  (isItemCodeSearch == "Yes"
                      ? (e.itemCode != null &&
                          e.itemCode!.toLowerCase() ==
                              _searchController.text.toLowerCase())
                      : isItemCodeSearch == "No"
                          ? e.name!
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase())
                          : (e.itemCode != null &&
                                  e.itemCode!.toLowerCase() ==
                                      _searchController.text.toLowerCase()) ||
                              e.name!.toLowerCase().contains(
                                  _searchController.text.toLowerCase())))))
          .map((product) {
        return TVWaiterProductWidget(
          products: products,
          scrollController: _scrollController,
          emailController: _emailController,
          nameController: _nameController,
          phoneController: _phoneController,
          searchController: _searchController,
          product: product,
          index: restController.productList.indexOf(product),
          length: restController.productList.length,
          isCampaign: false,
        );
      }).toList(),
    );
  }

  void swapToTop(int index) {
     final restController =Get.find<RestaurantController>();
    if (index < 0 || index >= restController.productList.length) {
      print('Index out of range');
      return;
    }

    Product productToMove = restController.productList.removeAt(index);
    restController.productList.insert(0, productToMove);
    Get.find<RestaurantController>().update();
  }

  void _handleEnterKeyPress(
      RestaurantController restController, String isItemCodeSearch) {
    if (_searchController.text.trim().isEmpty) {
      return;
    }

    // Get filtered products based on search text and current filters
    final filteredProducts =  restController.productList.where((product) {
      // Skip CHECK IN products
      if (product.name!.toUpperCase() == 'CHECK IN') {
        return false;
      }

      // Check availability
      if (!DateConverter.isAvailable(
          product.availableTimeStarts!, product.availableTimeEnds!)) {
        return false;
      }

      // Check food type (Normal/Premium)
      // if (restController.isNormal != product.foodFor) {
      //   return false;
      // }

      // Check category filter
      if (restController.posFoodCategoryList.isNotEmpty &&
          restController.categoryIndex != 0 &&
          !product.mainCategoryId!
              .contains(restController.categoryIndex.toString())) {
        return false;
      }

      // Check search match (name or itemCode)
      final searchText = _searchController.text.toLowerCase().trim();
      final nameMatch = product.name!.toLowerCase().contains(searchText);
      final itemCodeMatch = product.itemCode != null &&
          product.itemCode!.toLowerCase() == searchText;

      return isItemCodeSearch == 'Yes'
          ? itemCodeMatch
          : isItemCodeSearch == 'No'
              ? nameMatch
              : itemCodeMatch || nameMatch;
    }).toList();

    // If exactly one product matches, add it to cart
    if (filteredProducts.length == 1) {
      final product = filteredProducts.first;
      FocusManager.instance.primaryFocus?.unfocus();
      Get.find<CartController>().onAddProduct(product);
      // Find the index in the original products list and swap to top
      final productIndex = restController.productList.indexOf(product);
      if (productIndex != -1) {
        // Check if product exists in list
        swapToTop(productIndex);
      }
      _searchController.clear();
      restController.update();
    } else if (filteredProducts.isEmpty) {
      // No products found - could show a message or just do nothing
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      // Multiple products match - could show a message or add the first one
      // For now, we'll add the first matching product
      final product = filteredProducts.first;
      FocusManager.instance.primaryFocus?.unfocus();
      Get.find<CartController>().onAddProduct(product);

      // Find the index in the original products list and swap to top
      final productIndex = restController.productList.indexOf(product);
      swapToTop(productIndex);

      _searchController.clear();
      restController.update();
    }
  }
}
