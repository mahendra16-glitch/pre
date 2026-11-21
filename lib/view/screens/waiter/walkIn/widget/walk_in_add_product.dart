import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/edit_walkin_order_controller.dart';
import 'package:mygenie_restaurant/controller/localization_controller.dart';
import 'package:mygenie_restaurant/controller/product_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/enums.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/src/super_tooltip_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/waiter/walkIn/walkin_edit_order.dart';
import 'package:mygenie_restaurant/view/screens/waiter/walkIn/widget/walk_in_product_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mygenie_restaurant/data/model/response/product_model.dart' as p;

import '../../../../../controller/cart_controller.dart';
import '../../../pos/widget/product_bottom_sheet.dart';

class WalkInAddProduct extends StatefulWidget {
  final OrderList editOrder;

  WalkInAddProduct({required this.editOrder});
  @override
  State<WalkInAddProduct> createState() => _WalkInAddProductState();
}

class _WalkInAddProductState extends State<WalkInAddProduct> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<Product> products = [];
  final _controller = SuperTooltipController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Get.find<EditWalkInOrderController>()
          .setOrderType(widget.editOrder.orderType ?? '');
      if (Get.find<RestaurantController>().posFoodCategoryList.isEmpty) {
        Get.find<RestaurantController>().getProductCategoryListFromLocal(
            Get.find<AuthController>().getProductCategoryList());
        Get.find<RestaurantController>().setCategoryList();
      }
      // if (Get.find<AuthController>()
      //             .profileModel!
      //             .restaurants!
      //             .first
      //             .isShowPopularCategory ==
      //         'Yes' &&
      //     Get.find<RestaurantController>().popularCategory.isEmpty)
      //   await Get.find<RestaurantController>().getPopularCategory();

      Get.find<RestaurantController>().setPOSWaiterCategoryIndex(0);
      if (Get.find<RestaurantController>().productList.isEmpty) {
        Get.find<RestaurantController>().getProductListFromLocal(
            Get.find<AuthController>().getProductList());
      }
      products = Get.find<AuthController>().getProductList();

      Get.find<EditWalkInOrderController>().clearCartList();

      for (var i = 0; i < widget.editOrder.orderDetails!.length; i++) {
        OrderDetails order = widget.editOrder.orderDetails![i];
        FoodDetails food = widget.editOrder.orderDetails![i].foodDetails!;
        List<p.AddOns> addonList = [];
        for (var e in food.addOns!) {
          addonList.add(
              p.AddOns(id: e.id, name: e.name, price: e.price, qty: e.qty));
        }
        double variationPrice = 0;
        Product product = Product(
          tax: double.parse('${food.tax??0}'),
          taxType: food.taxType,

            addOns: addonList,
            name: food.name,
            id: food.id,
            deliveryFoodPrice: food.deliveredFoodPrice,
            takeAwayFoodPrice: food.takeAwayFoodPrice,
            restaurantDiscount: 0,
            variations: food.variations,
            availableTimeStarts: food.availableTimeStarts,
            availableTimeEnds: food.availableTimeEnds,
            categoryId: food.categoryId,
            description: food.description,
            discount: 0,
            qty: order.quantity,
            price: double.parse(food.price!),
            stationName: order.station);
        // double _startingPrice;
        // double _endingPrice;
        Get.find<EditWalkInOrderController>().initData(product, null);

        if (product.variations != null) {
          for (int index = 0;
              index < (product.variations?.length ?? 0);
              index++) {
            final variation = product.variations![index];
            for (int i = 0; i < (variation.values?.length ?? 0); i++) {
              final variationValue = variation.values![i];
              for (int j = 0; j < (order.variation?.length ?? 0); j++) {
                final orderVariation = order.variation![j];
                for (int k = 0; k < (orderVariation.values?.length ?? 0); k++) {
                  final orderVariationValue = orderVariation.values![k];
                  if (variation.name == orderVariation.name) {
                    if (variationValue.level == orderVariationValue.level) {
                      Get.find<EditWalkInOrderController>()
                          .setCartVariationIndex(
                        index,
                        i,
                        product,
                        variation.type == 'multi',
                      );
                      variationPrice +=
                          double.parse(variationValue.optionPrice ?? '0');
                    }
                  }
                }
              }
            }
          }
        }

        // double addonsCost = 0;
        List<AddOn> _addOnIdList = [];
        List<p.AddOns> _addOnsList = [];
        for (var i = 0; i < (product.addOns?.length ?? 0); i++) {
          final prodAddOn = product.addOns![i];
          for (int index = 0; index < (order.addOns?.length ?? 0); index++) {
            final ordAddOn = order.addOns![index];
            if (ordAddOn.id == prodAddOn.id) {
              _addOnIdList
                  .add(AddOn(id: prodAddOn.id!, quantity: ordAddOn.qty ?? 0,price: ordAddOn.price,name: ordAddOn.name));
              _addOnsList.add(prodAddOn);
            }
          }
        }

        double priceWithVariation =
            double.parse(food.price ?? '0') + variationPrice;

        CartModel _cartModel = CartModel(
            adjustPrice: 1,
            price: priceWithVariation,

            discountedPrice: 0,
            // discountAmount: 0,
            // discountAmount: (price -
            //     PriceConverter.convertWithDiscount(
            //         price, _discount, _discountType)),
            quantity: widget.editOrder.orderDetails![i].quantity ?? 0,
            addOnIds: _addOnIdList,
            addOns: _addOnsList,
            // isCampaign: false,
            product: product,
            variation:
                Get.find<EditWalkInOrderController>().selectedVariations);
        Get.find<EditWalkInOrderController>().addToCart(_cartModel, null);
      }
      Get.find<EditWalkInOrderController>().calculationCart();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                widget.editOrder != null ? 'Edit Table' : 'Add Table',
                style:
                    poppinsSemiBold.copyWith(color: Colors.black, fontSize: 16),
              ),
              actions: [
                GetBuilder<EditWalkInOrderController>(builder: (posController) {
                  return posController.cartList.isEmpty
                      ? const SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Get.find<EditWalkInOrderController>()
                                .clearCartList();
                            // Get.find<RestaurantController>()
                            //     .getWaiterProductList('1', 'all');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin:
                                EdgeInsets.only(top: 10, bottom: 10, right: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
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
              ],
            ),
            body: SafeArea(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: GetBuilder<RestaurantController>(
                      builder: (restController) {
                    return restController.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : GetBuilder<ProductController>(
                            builder: (productController) {
                            return GetBuilder<EditWalkInOrderController>(
                                builder: (posController) {
                              return posController.isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : Column(
                                      children: [
                                        // Divider(),
                                        SizedBox(
                                            height: Dimensions
                                                .PADDING_SIZE_DEFAULT),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .PADDING_SIZE_DEFAULT),
                                          child: Container(
                                            height: 40,
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
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _searchController,
                                                    textInputAction:
                                                        TextInputAction.search,
                                                    autofocus: false,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    keyboardType:
                                                        TextInputType.name,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 5),
                                                      suffixIcon: Icon(
                                                          Icons.search,
                                                          color: ColorTheme
                                                              .appColor),
                                                      hintText:
                                                          '${Get.find<AuthController>().profileModel!.restaurants!.first.searchFood}',
                                                      hintStyle: poppinsMedium
                                                          .copyWith(
                                                              fontSize: 13,
                                                              color: ColorTheme
                                                                  .hintText),
                                                      filled: true,
                                                      fillColor:
                                                          Theme.of(context)
                                                              .cardColor,
                                                    ),
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 13,
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
                                                Container(
                                                    height: 50,
                                                    width: 1,
                                                    color: Colors.grey),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      await _controller
                                                          .showTooltip();
                                                    },
                                                    child: SuperTooltip(
                                                      borderRadius: 2,
                                                      // bottom: 50,
                                                      hasShadow: false,
                                                      borderColor:
                                                          ColorTheme.borderGrey,
                                                      // shadowColor: Colors.black
                                                      //     .withOpacity(0.1),
                                                      showBarrier: true,
                                                      controller: _controller,
                                                      borderWidth: 1,
                                                      popupDirection:
                                                          TooltipDirection.down,
                                                      backgroundColor:
                                                          Colors.white,
                                                      right: 15,
                                                      left:
                                                          Get.width * 0.3 + 25,
                                                      arrowTipDistance: 20,
                                                      arrowBaseWidth: 0,
                                                      arrowLength: 0,
                                                      // borderWidth: 2.0,
                                                      // showCloseButton:
                                                      //     ShowCloseButton.none,
                                                      touchThroughAreaShape:
                                                          ClipAreaShape
                                                              .rectangle,
                                                      touchThroughAreaCornerRadius:
                                                          5,
                                                      minimumOutsideMargin: 0,
                                                      barrierColor:
                                                          Colors.transparent,
                                                      content: ListView.builder(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          shrinkWrap: true,
                                                          itemCount: restController
                                                              .posFoodCategoryList
                                                              .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return InkWell(
                                                              onTap: () async {
                                                                restController.setPOSWaiterCategoryIndex(
                                                                    restController
                                                                        .posFoodCategoryList[
                                                                            index]
                                                                        .id);
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                                _searchController
                                                                    .clear();
                                                                await _controller
                                                                    .hideTooltip();
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: 20,
                                                                        top: index == 0 ? 10 : 0,
                                                                        bottom: restController.posFoodCategoryList.length - 1 == index
                                                                            ? restController.posFoodCategoryList.length > 14
                                                                                ? 50
                                                                                : 15
                                                                            : 0

                                                                        //  restController.posFoodCategoryList.length>14&&
                                                                        ),
                                                                    child: Text(
                                                                      restController
                                                                          .posFoodCategoryList[
                                                                              index]
                                                                          .name,
                                                                      style: poppinsMedium.copyWith(
                                                                          fontSize:
                                                                              13,
                                                                          color: restController.posFoodCategoryList[index].id == restController.categoryIndex
                                                                              ? ColorTheme.appColor
                                                                              : ColorTheme.hintText),
                                                                    ),
                                                                  ),
                                                                  if (restController
                                                                              .posFoodCategoryList
                                                                              .length -
                                                                          1 !=
                                                                      index)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                      child: Divider(
                                                                          height:
                                                                              1,
                                                                          color:
                                                                              ColorTheme.borderGrey),
                                                                    ),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                      child: Icon(
                                                          Icons
                                                              .keyboard_arrow_down_outlined,
                                                          color: ColorTheme
                                                              .appColor),
                                                    ),
                                                  ),
                                                  // Icon(
                                                  //     Icons
                                                  //         .keyboard_arrow_down_outlined,
                                                  //     color: ColorTheme.appColor),
                                                )
                                              ],
                                            ),
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
                                        //       height: 33,
                                        //       child: ListView.builder(
                                        //         itemCount: restController
                                        //             .popularCategory
                                        //             .where((e) => e.id != 0)
                                        //             .length,
                                        //         scrollDirection:
                                        //             Axis.horizontal,
                                        //         itemBuilder: (context, index) {
                                        //           final category =
                                        //               restController
                                        //                   .popularCategory
                                        //                   .where(
                                        //                       (e) => e.id != 0)
                                        //                   .toList()[index];
                                        //           final isSelected =
                                        //               restController
                                        //                       .categoryIndex ==
                                        //                   category.id;
                                        //           return InkWell(
                                        //             onTap: () {
                                        //               restController
                                        //                   .setPOSWaiterCategoryIndex(
                                        //                       category.id);
                                        //               FocusManager.instance
                                        //                   .primaryFocus
                                        //                   ?.unfocus();
                                        //               _searchController.clear();
                                        //             },
                                        //             child: Container(
                                        //               margin: EdgeInsets.only(
                                        //                   left: index == 0
                                        //                       ? 0
                                        //                       : 11),
                                        //               padding:
                                        //                   EdgeInsets.symmetric(
                                        //                       horizontal: 10),
                                        //               decoration: BoxDecoration(
                                        //                 border: Border.all(
                                        //                     color: isSelected
                                        //                         ? ColorTheme
                                        //                             .appColor
                                        //                         : ColorTheme
                                        //                             .borderGrey),
                                        //                 borderRadius:
                                        //                     BorderRadius
                                        //                         .circular(7),
                                        //                 color: isSelected
                                        //                     ? ColorTheme
                                        //                         .appColor
                                        //                     : Colors.white,
                                        //               ),
                                        //               child: Center(
                                        //                 child: Text(
                                        //                   category.name,
                                        //                   style: poppinsMedium
                                        //                       .copyWith(
                                        //                           fontSize: 14,
                                        //                           color: isSelected
                                        //                               ? Colors
                                        //                                   .white
                                        //                               : Colors
                                        //                                   .grey),
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
                                              height: 33,
                                              child: ListView.builder(
                                                // scrollDirection: Axis.horizontal,
                                                itemCount: productController
                                                    .popularFoodList.length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                      _searchController.clear();

                                                      if ((productController
                                                                  .popularFoodList[
                                                                      index]
                                                                  .price !=
                                                              1 &&
                                                          Get.find<AuthController>()
                                                                  .profileModel!
                                                                  .restaurants!
                                                                  .first
                                                                  .foodLevelNotes !=
                                                              'Yes' &&
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
                                                        CartModel _cartModel =
                                                            CartModel(
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
                                                                // discountAmount: 0,
                                                                quantity: 1,
                                                                addOnIds: [],
                                                                addOns: [],
                                                                // isCampaign:
                                                                //     false,
                                                                product:
                                                                    productController
                                                                            .popularFoodList[
                                                                        index],
                                                                variation: []);
                                                        productController
                                                                .popularFoodList[
                                                                    index]
                                                                .isAddFirstTime =
                                                            false;
                                                        Get.find<
                                                                CartController>()
                                                            .addToCart(
                                                                _cartModel,
                                                                null);
                                                        if (productController
                                                                .popularFoodList[
                                                                    index]
                                                                .qty !=
                                                            null) {
                                                          productController
                                                              .popularFoodList[
                                                                  index]
                                                              .qty = productController
                                                                  .popularFoodList[
                                                                      index]
                                                                  .qty! +
                                                              1;
                                                        } else {
                                                          productController
                                                              .popularFoodList[
                                                                  index]
                                                              .qty = 1;
                                                        }
                                                        // Get.find<RestaurantController>().update();
                                                      } else {
                                                        Get.find<
                                                                CartController>()
                                                            .initData(
                                                                productController
                                                                        .popularFoodList[
                                                                    index],
                                                                null);

                                                        Get.bottomSheet(
                                                            ProductBottomSheet(
                                                                onIncrease:
                                                                    (data) {},
                                                                product:
                                                                    productController
                                                                            .popularFoodList[
                                                                        index],
                                                                isCampaign:
                                                                    false),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isScrollControlled:
                                                                true,
                                                            ignoreSafeArea:
                                                                false);
                                                      }
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: index == 0
                                                              ? 0
                                                              : 11),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: ColorTheme
                                                                .borderGrey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        color: Colors.white,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          productController
                                                              .popularFoodList[
                                                                  index]
                                                              .name!,
                                                          style: poppinsMedium
                                                              .copyWith(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey),
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
                                          // width: Get.width * 0.7,
                                          child: ListView.builder(
                                            // key: UniqueKey(),
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 20),
                                            itemCount: products.length,
                                            itemBuilder: (context, index) {
                                              return products[index].name!.toUpperCase() ==
                                                      'CHECK IN'
                                                  ? SizedBox.shrink()
                                                  : DateConverter.isAvailable(
                                                          products[index]
                                                              .availableTimeStarts!,
                                                          products[index]
                                                              .availableTimeEnds!)
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
                                                              ? WalkInProductWidget(
                                                                  orderType: widget
                                                                          .editOrder
                                                                          .orderType ??
                                                                      '',
                                                                  products:
                                                                      products,
                                                                  product:
                                                                      products[
                                                                          index],
                                                                  index: index,
                                                                  length: products
                                                                      .length,
                                                                  isCampaign:
                                                                      false,
                                                                )
                                                              : restController
                                                                          .categoryIndex ==
                                                                      0
                                                                  ? WalkInProductWidget(
                                                                      orderType:
                                                                          widget.editOrder.orderType ??
                                                                              '',
                                                                      products:
                                                                          products,
                                                                      product:
                                                                          products[
                                                                              index],
                                                                      index:
                                                                          index,
                                                                      length: products
                                                                          .length,
                                                                      isCampaign:
                                                                          false,
                                                                    )
                                                                  : products[index]
                                                                          .mainCategoryId!
                                                                          .contains(restController
                                                                              .categoryIndex
                                                                              .toString())
                                                                      ? WalkInProductWidget(
                                                                          orderType:
                                                                              widget.editOrder.orderType ?? '',
                                                                          products:
                                                                              products,
                                                                          product:
                                                                              products[index],
                                                                          index:
                                                                              index,
                                                                          length:
                                                                              products.length,
                                                                          isCampaign:
                                                                              false,
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink()
                                                          : SizedBox.shrink()
                                                      : SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                        // Expanded(
                                        //   child: Row(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     mainAxisAlignment: MainAxisAlignment.start,
                                        //     children: [
                                        //       Container(
                                        //         margin: EdgeInsets.only(
                                        //             bottom:
                                        //                 Dimensions.PADDING_SIZE_LARGE,
                                        //             left: Dimensions
                                        //                 .PADDING_SIZE_DEFAULT),
                                        //         height: Get.height,
                                        //         width: Get.width * 0.25,
                                        //         decoration: BoxDecoration(
                                        //             color: Color.fromRGBO(
                                        //                 248, 248, 248, 1.0),
                                        //             borderRadius: BorderRadius.circular(
                                        //                 Dimensions.RADIUS_DEFAULT)),
                                        //         padding: const EdgeInsets.symmetric(
                                        //             vertical: Dimensions
                                        //                 .PADDING_SIZE_EXTRA_SMALL,
                                        //             horizontal:
                                        //                 Dimensions.PADDING_SIZE_SMALL),
                                        //         child: ListView.builder(
                                        //           // scrollDirection: Axis.horizontal,
                                        //           shrinkWrap: true,
                                        //           itemCount: restController
                                        //               .posFoodCategoryList.length,

                                        //           physics:
                                        //               const BouncingScrollPhysics(),
                                        //           itemBuilder: (context, index) {
                                        //             return InkWell(
                                        //               onTap: () {
                                        //                 restController
                                        //                     .setPOSWaiterCategoryIndex(
                                        //                         index);
                                        //                 FocusManager
                                        //                     .instance.primaryFocus
                                        //                     ?.unfocus();
                                        //                 _searchController.clear();
                                        //               },
                                        //               child: Container(
                                        //                 padding: EdgeInsets.symmetric(
                                        //                     horizontal: Dimensions
                                        //                         .PADDING_SIZE_EXTRA_SMALL,
                                        //                     vertical: Dimensions
                                        //                         .PADDING_SIZE_EXTRA_SMALL),
                                        //                 margin: EdgeInsets.only(
                                        //                   top: Dimensions
                                        //                       .PADDING_SIZE_DEFAULT,
                                        //                 ),
                                        //                 decoration: BoxDecoration(
                                        //                   borderRadius:
                                        //                       BorderRadius.circular(
                                        //                           Dimensions
                                        //                               .RADIUS_DEFAULT),
                                        //                   color: index ==
                                        //                           restController
                                        //                               .categoryIndex
                                        //                       ? ColorTheme.appColor
                                        //                       : Colors.white,
                                        //                 ),
                                        //                 child: Center(
                                        //                   child: Text(
                                        //                     restController
                                        //                         .posFoodCategoryList[
                                        //                             index]
                                        //                         .name,
                                        //                     style: poppinsRegular.copyWith(
                                        //                         fontSize: MediaQuery.of(
                                        //                                         context)
                                        //                                     .size
                                        //                                     .shortestSide >
                                        //                                 570
                                        //                             ? 14
                                        //                             : 11,
                                        //                         color: index ==
                                        //                                 restController
                                        //                                     .categoryIndex
                                        //                             ? Colors.white
                                        //                             : Color.fromRGBO(
                                        //                                 152,
                                        //                                 152,
                                        //                                 152,
                                        //                                 1.0)),
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             );
                                        //           },
                                        //         ),
                                        //       ),
                                        //       SizedBox(
                                        //         width: Get.width * 0.7,
                                        //         child: ListView.builder(
                                        //           key: UniqueKey(),
                                        //           physics: BouncingScrollPhysics(),
                                        //           shrinkWrap: true,
                                        //           itemCount:
                                        //               restController.productList.length,
                                        //           padding: EdgeInsets.all(
                                        //               Dimensions.PADDING_SIZE_SMALL),
                                        //           itemBuilder: (context, index) {
                                        //             return DateConverter.isAvailable(
                                        //                     restController
                                        //                         .productList[index]
                                        //                         .availableTimeStarts,
                                        //                     restController
                                        //                         .productList[index]
                                        //                         .availableTimeEnds)
                                        //                 ? restController
                                        //                         .productList[index].name
                                        //                         .toLowerCase()
                                        //                         .contains(
                                        //                             _searchController.text
                                        //                                 .toLowerCase())
                                        //                     ? restController
                                        //                             .posFoodCategoryList
                                        //                             .isEmpty
                                        //                         ? WalkInProductWidget(
                                        //                             product: restController
                                        //                                     .productList[
                                        //                                 index],
                                        //                             index: index,
                                        //                             length:
                                        //                                 restController
                                        //                                     .productList
                                        //                                     .length,
                                        //                             isCampaign: false,
                                        //                           )
                                        //                         : restController
                                        //                                     .posFoodCategoryList[
                                        //                                         restController
                                        //                                             .categoryIndex]
                                        //                                     .id ==
                                        //                                 0
                                        //                             ? WalkInProductWidget(
                                        //                                 product:
                                        //                                     restController
                                        //                                             .productList[
                                        //                                         index],
                                        //                                 index: index,
                                        //                                 length: restController
                                        //                                     .productList
                                        //                                     .length,
                                        //                                 isCampaign:
                                        //                                     false,
                                        //                               )
                                        //                             : restController
                                        //                                     .productList[
                                        //                                         index]
                                        //                                     .mainCategoryId
                                        //                                     .contains(restController
                                        //                                         .posFoodCategoryList[
                                        //                                             restController.categoryIndex]
                                        //                                         .id
                                        //                                         .toString())
                                        //                                 ? WalkInProductWidget(
                                        //                                     product: restController
                                        //                                             .productList[
                                        //                                         index],
                                        //                                     index:
                                        //                                         index,
                                        //                                     length: restController
                                        //                                         .productList
                                        //                                         .length,
                                        //                                     isCampaign:
                                        //                                         false,
                                        //                                   )
                                        //                                 : const SizedBox.shrink()
                                        //                     : SizedBox.shrink()
                                        //                 : SizedBox.shrink();
                                        //           },
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    );
                            });
                          });
                  })),
            ),
            bottomNavigationBar: GetBuilder<EditWalkInOrderController>(
                builder: (cartController) {
              return cartController.cartList.isNotEmpty
                  ? SafeArea(
                      child: Container(
                      height: 70,
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
                                      style: poppinsMedium.copyWith(
                                          color: ColorTheme.blue,
                                          fontSize: 11)),
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
                                      'Rs. ${PriceConverter.convertPrice(cartController.calculationCart(), isHideCurrency: true)}',
                                      style: poppinsSemiBold.copyWith(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                ]),
                            InkWell(
                              onTap: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WalkInEditOrder(
                                            editOrder: widget.editOrder)));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                    vertical: 6),
                                decoration: BoxDecoration(
                                    color: ColorTheme.appColor,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  'Review Order',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                    ))
                  : const SizedBox();
            })

            //             bottomNavigationBar: GetBuilder<EditWalkInOrderController>(
            //     builder: (cartController) {
            //   return cartController.cartList.isNotEmpty
            //       ? SafeArea(
            //           child: Container(
            //           height: 70,
            //           width: Get.width,
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: Dimensions
            //                 .PADDING_SIZE_LARGE, /* vertical: Dimensions.PADDING_SIZE_SMALL*/
            //           ),
            //           decoration: BoxDecoration(
            //             color: Theme.of(context).cardColor,
            //             boxShadow: [
            //               BoxShadow(
            //                   color: const Color(0xFF2A2A2A).withOpacity(0.1),
            //                   blurRadius: 10,
            //                   offset: const Offset(0, -5))
            //             ],
            //           ),
            //           child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       Text(
            //                           '${'item'.tr}: ${cartController.cartList.length}',
            //                           style: poppinsMedium.copyWith(
            //                               fontSize: MediaQuery.of(context)
            //                                           .size
            //                                           .shortestSide >
            //                                       570
            //                                   ? 16
            //                                   : Dimensions.FONT_SIZE_DEFAULT)),
            //                       const SizedBox(
            //                           height:
            //                               Dimensions.PADDING_SIZE_EXTRA_SMALL),
            //                       Text(
            //                         '${'Total'.tr}: ${PriceConverter.convertPrice(cartController.calculationCart())}',
            //                         style: poppinsMedium.copyWith(
            //                             fontSize: MediaQuery.of(context)
            //                                         .size
            //                                         .shortestSide >
            //                                     570
            //                                 ? 18
            //                                 : Dimensions.FONT_SIZE_LARGE,
            //                             color: Theme.of(context).primaryColor),
            //                       ),
            //                     ]),
            //                 InkWell(
            //                   onTap: () async {
            //                     // Get.toNamed(RouteHelper.getWalkInEditOrderRoute(
            //                     //     widget.editOrder));
            //                     Navigator.push(
            //                         context,
            //                         MaterialPageRoute(
            //                             builder: (context) => WalkInEditOrder(
            //                                 editOrder: widget.editOrder)));
            //                   },
            //                   child: Container(
            //                     padding: EdgeInsets.symmetric(
            //                         horizontal: Dimensions.PADDING_SIZE_DEFAULT,
            //                         vertical: Dimensions.PADDING_SIZE_SMALL),
            //                     decoration: BoxDecoration(
            //                         color: ColorTheme.appColor,
            //                         borderRadius: BorderRadius.circular(
            //                             Dimensions.RADIUS_DEFAULT)),
            //                     child: Text(
            //                       'Review Order',
            //                       style: poppinsMedium.copyWith(
            //                           fontSize: MediaQuery.of(context)
            //                                       .size
            //                                       .shortestSide >
            //                                   570
            //                               ? 18
            //                               : Dimensions.FONT_SIZE_LARGE,
            //                           color: Colors.white),
            //                     ),
            //                   ),
            //                 ),
            //               ]),
            //         ))
            //       : const SizedBox();
            // })
            ),
      ),
    );
  }
}
