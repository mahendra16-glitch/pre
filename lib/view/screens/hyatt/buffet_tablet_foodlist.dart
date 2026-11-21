import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/product_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip_controller.dart';
import 'package:mygenie_restaurant/data/model/response/buffet_order_response.dart'
    show OrderList;
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/table_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/app_constants.dart' as ResponsiveHelper;
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_toast.dart';
import 'package:mygenie_restaurant/view/screens/pos/checkout_order_screen.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/product_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/widget/product_widget.dart';

class BuffetTabletPosScreen extends StatefulWidget {
  final OrderList? editOrder;

  BuffetTabletPosScreen({this.editOrder});
  @override
  State<BuffetTabletPosScreen> createState() => _BuffetTabletPosScreenState();
}

class _BuffetTabletPosScreenState extends State<BuffetTabletPosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addNoteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  TextEditingController _searchTableController = TextEditingController();

  List<Product> products = [];
  final _tableController = SuperTooltipController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .restaurantType !=
          'Restaurant buffet') Get.find<CartController>().clearTableList();
      Get.find<CartController>().setTableIndex(null);
      if (Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .isShowPopularCategory ==
              'Yes' &&
          Get.find<ProductController>().popularFoodList.isEmpty)
        await Get.find<ProductController>().getPopularFoodList();
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
      // }
      if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .restaurantType !=
          'Restaurant buffet') {
        await Get.find<CartController>().getTableList();
      } else {
        if (Get.find<CartController>().tableList.isEmpty)
          await Get.find<CartController>().getTableList();
      }
      if (widget.editOrder != null) {
        if (widget.editOrder!.tableId != 0) {
          Get.find<CartController>().editTableList(TableResponseModel(
            id: widget.editOrder!.tableId!,
            title: widget.editOrder!.restaurantTable!.title!,
            tableNo: widget.editOrder!.restaurantTable!.tableNo!,
          ));
          for (var i = 0;
              i < Get.find<CartController>().tableList.length;
              i++) {
            if (widget.editOrder!.tableId ==
                Get.find<CartController>().tableList[i].id) {
              Get.find<CartController>()
                  .setTableIndex(Get.find<CartController>().tableList[i]);
            }
          }
        }
        _nameController.text = '${widget.editOrder?.userName ?? ''}';
        if (widget.editOrder!.user != null) {
          _nameController.text =
              '${widget.editOrder?.user?.fName ?? ''} ${widget.editOrder?.user?.lName ?? ''}';
          _emailController.text = '${widget.editOrder?.user?.email ?? ''}';
          _phoneController.text = '${widget.editOrder?.user?.phone ?? ''}';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
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
                    ? widget.editOrder!.restaurantTable == null ||
                            widget.editOrder!.restaurantTable!.tableNo == ''
                        ? widget.editOrder?.orderType == 'delivery'
                            ? 'Delivery'
                            : widget.editOrder?.orderType == 'take_away'
                                ? 'Take Away'
                                : 'WC'
                        : widget.editOrder!.restaurantTable!.title == ''
                            ? '#${widget.editOrder!.restaurantTable!.tableNo}'
                            : '#${widget.editOrder!.restaurantTable!.title}-${widget.editOrder!.restaurantTable!.tableNo}'
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
                  child: SizedBox(
                    height: 10,
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
                                height: 10,
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
                                        posController.tableList.isNotEmpty
                                            ? Container(
                                                height: 50,
                                                width: Get.width * 0.3,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .PADDING_SIZE_SMALL),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                  // color: ColorTheme.borderGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: TypeAheadField(
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
                                                            // suffixIcon: Icon(
                                                            //   Icons.arrow_drop_down,
                                                            //   color: ColorTheme
                                                            //       .appColor,
                                                            // ),
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    right: 0),
                                                            hintText: posController
                                                                        .selectedTable ==
                                                                    null
                                                                ? '${posController.tableList.first.title} ${posController.tableList.first.tableNo}'
                                                                : '${posController.selectedTable!.title} ${posController.selectedTable!.tableNo}',
                                                            // labelText: posController
                                                            //             .selectedTable ==
                                                            //         null
                                                            //     ? '${posController.tableList.first.title} ${posController.tableList.first.tableNo}'
                                                            //     : '${posController.selectedTable.title} ${posController.selectedTable.tableNo}',
                                                            // hintText: posController
                                                            //             .selectedTable ==
                                                            //         null
                                                            //     ? '${posController.tableList.first.title} ${posController.tableList.first.tableNo}'
                                                            //     : '${posController.selectedTable.title} ${posController.selectedTable.tableNo}',
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      style: BorderStyle
                                                                          .none,
                                                                      width: 0),
                                                            ),
                                                            hintStyle: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        15,
                                                                    color: ColorTheme
                                                                        .hintText),
                                                            filled: true,
                                                            fillColor:
                                                                Colors.white,
                                                          ),
                                                          style: poppinsMedium
                                                              .copyWith(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black)),
                                                  suggestionsCallback:
                                                      (pattern) async {
                                                    return await posController
                                                        .searchTable(
                                                            context, pattern);
                                                  },
                                                  itemBuilder: (context,
                                                      TableResponseModel
                                                          suggestion) {
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      3),
                                                          child: Text(
                                                            '${suggestion.title} ${suggestion.tableNo}',
                                                            style: poppinsMedium.copyWith(
                                                                fontSize: 15,
                                                                color: suggestion
                                                                            .id ==
                                                                        0
                                                                    ? ColorTheme
                                                                        .appColor
                                                                    : ColorTheme
                                                                        .hintText),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: ColorTheme
                                                              .hintText,
                                                          height: 0,
                                                        )
                                                      ],
                                                    );
                                                  },
                                                  onSuggestionSelected:
                                                      (TableResponseModel
                                                          suggestion) async {
                                                    posController.setTableIndex(
                                                        suggestion);
                                                    _searchTableController
                                                            .text =
                                                        '${suggestion.title} ${suggestion.tableNo}'
                                                            .trim();
                                                  },
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        SizedBox(width: 10),
                                        Expanded(
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
                                                  hintText: 'Search food',
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
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isShowPopularCategory ==
                                      'Yes')
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
                                              onTap: () {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                _searchController.clear();
                                                swapToTop(index);
                                                // print(product?.addOns);
                                                if ((productController
                                                            .popularFoodList[
                                                                index]
                                                            .price !=
                                                        1 &&
                                                    (productController
                                                                .popularFoodList[
                                                                    index]
                                                                .variations ==
                                                            null ||
                                                        productController
                                                            .popularFoodList[
                                                                index]
                                                            .variations!
                                                            .isEmpty) &&
                                                    (productController
                                                                .popularFoodList[
                                                                    index]
                                                                .addOns ==
                                                            null ||
                                                        productController
                                                            .popularFoodList[
                                                                index]
                                                            .addOns!
                                                            .isEmpty))) {
                                                  CartModel _cartModel = CartModel(
                                                      adjustPrice: 1,
                                                      price: productController
                                                          .popularFoodList[
                                                              index]
                                                          .price!,
                                                      discountedPrice:
                                                          productController
                                                              .popularFoodList[
                                                                  index]
                                                              .price!,
                                                      quantity: 1,
                                                      addOnIds: [],
                                                      addOns: [],
                                                      product: productController
                                                              .popularFoodList[
                                                          index],
                                                      variation: []);
                                                  productController
                                                      .popularFoodList[index]
                                                      .isAddFirstTime = false;
                                                  Get.find<CartController>()
                                                      .addToCart(
                                                          _cartModel, null);
                                                  productController
                                                      .popularFoodList[index]
                                                      .qty = (productController
                                                              .popularFoodList[
                                                                  index]
                                                              .qty ??
                                                          0) +
                                                      1;

                                                  // Get.find<RestaurantController>().update();
                                                } else {
                                                  Get.bottomSheet(
                                                      ProductBottomSheet(
                                                        onIncrease: (data) {},
                                                        product: productController
                                                                .popularFoodList[
                                                            index],
                                                      ),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      ignoreSafeArea: false);
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
                                                            .popularFoodList[
                                                                index]
                                                            .name ??
                                                        '',
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
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isShowPopularCategory ==
                                      'Yes')
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
                                                              restController)
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
                                                      products?.length ?? 0,
                                                  padding: EdgeInsets.all(
                                                      Dimensions
                                                          .PADDING_SIZE_SMALL),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return products[index]
                                                                .name!
                                                                .toUpperCase() ==
                                                            'CHECK IN'
                                                        ? SizedBox.shrink()
                                                        : (DateConverter.isAvailable(
                                                                    products[index]
                                                                        .availableTimeStarts!,
                                                                    products[index]
                                                                        .availableTimeEnds!) &&
                                                                restController
                                                                        .isNormal ==
                                                                    products[index]
                                                                        .foodFor)
                                                            ? products[index]
                                                                    .name!
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        _searchController
                                                                            .text
                                                                            .toLowerCase())
                                                                ? restController
                                                                        .posFoodCategoryList
                                                                        .isEmpty
                                                                    ? WaiterProductWidget(
                                                                        products:
                                                                            products,
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
                                                                            products[index],
                                                                        index:
                                                                            index,
                                                                        length:
                                                                            products.length,
                                                                        isCampaign:
                                                                            false,
                                                                      )
                                                                    : restController.categoryIndex ==
                                                                            0
                                                                        ? WaiterProductWidget(
                                                                            products:
                                                                                products,
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
                                                                                products[index],
                                                                            index:
                                                                                index,
                                                                            length:
                                                                                products.length,
                                                                            isCampaign:
                                                                                false,
                                                                          )
                                                                        : products[index].mainCategoryId!.contains(restController.categoryIndex.toString())
                                                                            ? WaiterProductWidget(
                                                                                products: products,
                                                                                scrollController: _scrollController,
                                                                                emailController: _emailController,
                                                                                nameController: _nameController,
                                                                                phoneController: _phoneController,
                                                                                searchController: _searchController,
                                                                                product: products[index],
                                                                                index: index,
                                                                                length: products.length,
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
                                if (Get.find<CartController>().selectedTable ==
                                        null ||
                                    Get.find<CartController>()
                                            .selectedTable!
                                            .id ==
                                        0) {
                                  showErrorToast('Please Select Table');
                                } else {
                                  _searchController.clear();
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => POSCartScreen(
                                              phoneNumber:
                                                  _phoneController.text.isEmpty
                                                      ? ''
                                                      : _phoneController.text,
                                              editOrder: null,
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
      children: products
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
          index: products.indexOf(product),
          length: products.length,
          isCampaign: false,
        );
      }).toList(),
    );
  }

  Widget searchProductList(RestaurantController restController) {
    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      spacing: 15,
      runSpacing: 15,
      children: products
          .where((e) => (e.name!.toUpperCase() != 'CHECK In' &&
              (DateConverter.isAvailable(
                      e.availableTimeStarts!, e.availableTimeEnds!) &&
                  (e.name!
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())))))
          .map((product) {
        return TVWaiterProductWidget(
          products: products,
          scrollController: _scrollController,
          emailController: _emailController,
          nameController: _nameController,
          phoneController: _phoneController,
          searchController: _searchController,
          product: product,
          index: products.indexOf(product),
          length: products.length,
          isCampaign: false,
        );
      }).toList(),
    );
  }

  void swapToTop(int index) {
    if (index < 0 || index >= products.length) {
      print('Index out of range');
      return;
    }

    Product productToMove = products.removeAt(index);
    products.insert(0, productToMove);
    Get.find<RestaurantController>().update();
  }
}

class TVWaiterProductWidget extends StatelessWidget {
  final Product product;
  final int index;
  final int length;
  final bool isCampaign;
  final bool isAddOn;
  ScrollController scrollController;
  TextEditingController nameController;
  TextEditingController emailController;
  TextEditingController phoneController;
  TextEditingController searchController;
  List<Product> products;

  TVWaiterProductWidget({
    required this.product,
    required this.index,
    required this.length,
    required this.scrollController,
    this.isCampaign = false,
    this.isAddOn = false,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.searchController,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    // bool _desktop = ResponsiveHelper.isDesktop(context);
    bool _isAvailable = DateConverter.isAvailable(
        product.availableTimeStarts!, product.availableTimeEnds!);

    return InkWell(
      onTap: () {},
      child: Container(
        width: Get.width * 0.26,
        height: 100,
        padding: EdgeInsets.symmetric(
            vertical: 5, horizontal: Dimensions.PADDING_SIZE_SMALL),
        decoration: BoxDecoration(
          color: Color.fromRGBO(248, 248, 248, 1.0),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
          boxShadow: ResponsiveHelper.isDesktop(context)
              ? [
                  BoxShadow(
                    color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                    spreadRadius: 1,
                    blurRadius: 5,
                  )
                ]
              : null,
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name ?? '',
                  style: poppinsSemiBold.copyWith(fontSize: 17),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    '₹ ${product.price}',
                    style: poppinsBold.copyWith(
                        fontSize: 14, color: ColorTheme.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if ((product.price != 1 &&
                  (product.variations == null || product.variations!.isEmpty) &&
                  (product.addOns == null || product.addOns!.isEmpty)) &&
              !product.isAddFirstTime!)
            Stack(
              children: [
                Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Container(
                    width: 120,
                    // height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: ColorTheme.borderGrey)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: QuantityButton(
                              onTap: () {},
                              isIncrement: false,
                            ),
                          ),
                        ),
                        Text('${product.qty}',
                            style: poppinsMedium.copyWith(
                                color: Colors.black, fontSize: 16)),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: QuantityButton(
                            isIncrement: true,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();

                        CartModel? cart;
                        int? cartIndex;
                        for (var i = 0;
                            i < Get.find<CartController>().cartList.length;
                            i++) {
                          CartModel? _cartModel =
                              Get.find<CartController>().cartList[i];
                          if (_cartModel.quantity == product.qty &&
                              product.id == _cartModel.product.id) {
                            cart = _cartModel;
                            cartIndex = i;
                            break;
                          }
                        }
                        if (product.qty! > 1) {
                          if (cart != null) {
                            Get.find<CartController>().setQuantity(false, cart);
                            product.qty = product.qty! - 1;
                            Get.find<RestaurantController>().update();
                          }
                        } else {
                          if (cartIndex != null) {
                            Get.find<CartController>()
                                .removeFromCart(cartIndex);
                            product.qty = product.qty! - 1;
                            Get.find<RestaurantController>().update();
                          }
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 80,
                        // color: Colors.transparent,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();

                        if (product.qty! > 0) {
                          CartModel? cart;
                          for (var i = 0;
                              i < Get.find<CartController>().cartList.length;
                              i++) {
                            CartModel? _cartModel =
                                Get.find<CartController>().cartList[i];
                            if (_cartModel.quantity == product.qty &&
                                product.id == _cartModel.product.id) {
                              cart = _cartModel;
                              break;
                            }
                          }
                          if (cart != null) {
                            final cartController = Get.find<CartController>();

                            cartController.setQuantity(true, cart);
                            product.qty = (product.qty ?? 0) + 1;

                            Get.find<RestaurantController>().update();
                          }
                        } else {
                          CartModel _cartModel = CartModel(
                              adjustPrice: 1,
                              price: product.price!,
                              discountedPrice: product.price!,
                              quantity: 1,
                              addOnIds: [],
                              addOns: [],
                              product: product,
                              variation: []);

                          Get.find<CartController>()
                              .addToCart(_cartModel, null);
                          if (product.qty != null) {
                            product.qty = product.qty! + 1;
                          }

                          Get.find<RestaurantController>().update();
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 80,
                        // color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (product.price == 1 ||
              (product.variations != null && product.variations!.isNotEmpty) ||
              (product.addOns != null && product.addOns!.isNotEmpty) ||
              product.isAddFirstTime!)
            InkWell(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                searchController?.clear();
                swapToTop(index);
                // print(product?.addOns);
                if ((product.price != 1 &&
                    (product.variations == null ||
                        product.variations!.isEmpty) &&
                    (product.addOns == null || product.addOns!.isEmpty))) {
                  CartModel _cartModel = CartModel(
                      adjustPrice: 1,
                      price: product.price!,
                      discountedPrice: product.price!,
                      quantity: 1,
                      addOnIds: [],
                      addOns: [],
                      product: product,
                      variation: []);
                  product.isAddFirstTime = false;
                  Get.find<CartController>().addToCart(_cartModel, null);
                  if (product.qty != null) {
                    product.qty = product.qty! + 1;
                  }

                  // Get.find<RestaurantController>().update();
                } else {
                  Get.bottomSheet(
                      ProductBottomSheet(
                        onIncrease: (data) {},
                        product: product,
                      ),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      ignoreSafeArea: false);
                }
              },
              child: Container(
                width: 120,
                height: 60,
                margin: EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                    color: ColorTheme.appColor,
                    borderRadius: BorderRadius.circular(7)),
                child: Center(
                  child: Text(
                    'add'.tr,
                    style: poppinsMedium.copyWith(
                        color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  void swapToTop(int index) {
    if (index < 0 || index >= products.length) {
      print('Index out of range');
      return;
    }

    Product productToMove = products.removeAt(index);
    products.insert(0, productToMove);
    Get.find<RestaurantController>().update();
  }
}
