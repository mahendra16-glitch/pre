import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/responsive_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/product_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaiterProductWidget extends StatelessWidget {
  final Product product;
  final int index;
  final int length;
  final bool isCampaign;
  final bool isAddOn;
  final ScrollController scrollController;
  final TextEditingController? nameController;
  final TextEditingController? emailController;
  final TextEditingController? phoneController;
  final TextEditingController searchController;
  final List<Product> products;

  WaiterProductWidget({
    required this.product,
    required this.index,
    required this.length,
    required this.scrollController,
    this.isCampaign = false,
    this.isAddOn = false,
    this.nameController,
    this.emailController,
    this.phoneController,
    required this.searchController,
    required this.products,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String foodLevelNotes = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.first
            .foodLevelNotes ??
        '';
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        margin: EdgeInsets.only(
            top: index == 0 ? 0 : Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
          color: ColorTheme.productCard,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: poppinsSemiBold.copyWith(fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .isComplementry !=
                      'Yes')
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        (Get.find<TableController>().selectedTable == null ||
                                Get.find<TableController>()
                                        .selectedTable!
                                        .tableNo ==
                                    'Select Table')
                            ? '₹ ${product.price}'
                            : Get.find<TableController>()
                                        .selectedTable!
                                        .tableNo ==
                                    'Take Away'
                                ? '₹ ${product.price! + product.takeAwayFoodPrice!}'
                                : Get.find<TableController>()
                                            .selectedTable!
                                            .tableNo ==
                                        'Delivery'
                                    ? '₹ ${product.price! + product.deliveryFoodPrice!}'
                                    : '₹ ${product.price!}',
                        style: poppinsBold.copyWith(
                            fontSize: 12, color: ColorTheme.green),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          GetBuilder<CartController>(
              id: 'qty',
              builder: (cart) {
                final qty = cart.getProductQty(product.id!);

                return Column(
                  children: [
                    //  if ((product.price != 1 &&
                    //     foodLevelNotes!=
                    //           'Yes' &&
                    //       (product.variations == null || product.variations!.isEmpty) &&
                    //       (product.addOns == null || product.addOns!.isEmpty)) &&
                    //   !product.isAddFirstTime!)

                    qty != 0 && product.price != 1
                        ? Stack(
                            children: [
                              Container(
                                height: 60,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Container(
                                  width: 100,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                          color: ColorTheme.borderGrey)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: QuantityButton(
                                            onTap: () {},
                                            isIncrement: false,
                                          ),
                                        ),
                                      ),
                                      Text(
                                          // '${qty}',
                                          qty % 1 == 0
                                              ? qty.toInt().toString()
                                              : qty.toString(),
                                          style: poppinsMedium.copyWith(
                                              color: Colors.black,
                                              fontSize: 14)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: QuantityButton(
                                          isIncrement: true,
                                          onTap: null,
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
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      cart.decreaseProductQty(product.id!);
                                      Get.find<RestaurantController>().update();
                                    },
                                    child: Container(
                                      width: 45,
                                      height: 60,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      cart.onAddProduct(product);

                                      // if (product.qty! > 0) {
                                      //   CartModel? cart;
                                      //   for (var i = 0;
                                      //       i < Get.find<CartController>().cartList.length;
                                      //       i++) {
                                      //     CartModel _cartModel =
                                      //         Get.find<CartController>().cartList[i];
                                      //     if (_cartModel.quantity == product.qty &&
                                      //         product.id == _cartModel.product.id) {
                                      //       cart = _cartModel;
                                      //       break;
                                      //     }
                                      //   }
                                      //   if (cart != null) {
                                      //     Get.find<CartController>().setQuantity(true, cart);
                                      //     product.qty = product.qty! + 1;
                                      //     Get.find<RestaurantController>().update();
                                      //   }
                                      // } else {
                                      //   CartModel _cartModel = CartModel(
                                      //       adjustPrice: 1,
                                      //       price: product.price!,
                                      //       discountedPrice: product.price!,
                                      //       discountAmount: 0,
                                      //       quantity: 1,
                                      //       addOnIds: [],
                                      //       addOns: [],
                                      //       isCampaign: false,
                                      //       product: product,
                                      //       variation: []);

                                      //   Get.find<CartController>()
                                      //       .addToCart(_cartModel, null);
                                      //   if (product.qty != null) {
                                      //     product.qty = product.qty! + 1;
                                      //   } else {
                                      //     product.qty = 1;
                                      //   }
                                      // }
                                      Get.find<RestaurantController>().update();
                                    },
                                    child: Container(
                                      width: 45,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        // if (product.price == 1 ||
                        //     foodLevelNotes==
                        //         'Yes' ||
                        //     (product.variations != null && product.variations!.isNotEmpty) ||
                        //     (product.addOns != null && product.addOns!.isNotEmpty) ||
                        //     product.isAddFirstTime!)
                        : InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              searchController.clear();
                              cart.onAddProduct(product);

                              swapToTop(index);
                              // if ((product.price != 1 &&
                              //   foodLevelNotes !=
                              //         'Yes' &&
                              //     (product.variations == null ||
                              //         product.variations!.isEmpty) &&
                              //     (product.addOns == null || product.addOns!.isEmpty))) {
                              //   CartModel _cartModel = CartModel(
                              //       adjustPrice: 1,
                              //       price: product.price!,
                              //       discountedPrice: product.price!,
                              //       discountAmount: 0,
                              //       quantity: 1,
                              //       addOnIds: [],
                              //       addOns: [],
                              //       isCampaign: false,
                              //       product: product,
                              //       variation: []);
                              //   product.isAddFirstTime = false;
                              //   // product.qtyController = TextEditingController(text: '1');
                              //   Get.find<CartController>().addToCart(_cartModel, null);
                              //   if (product.qty != null) {
                              //     product.qty = product.qty! + 1;
                              //   } else {
                              //     product.qty = 1;
                              //   }
                              // } else {
                              // Get.find<CartController>().initData(product, null);

                              //   Get.bottomSheet(
                              //       ProductBottomSheet(
                              //           onIncrease: (data) {},
                              //           product: product,
                              //           isCampaign: isCampaign),
                              //       backgroundColor: Colors.transparent,
                              //       isScrollControlled: true,
                              //       ignoreSafeArea: false);
                              // }
                            },
                            child: Container(
                              width: 90,
                              height: 30,
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                  color: ColorTheme.appColor,
                                  borderRadius: BorderRadius.circular(7)),
                              child: Center(
                                child: Text(
                                  'Add',
                                  style: poppinsMedium.copyWith(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),

                    if (product.price == 1 ||
                        (product.variations != null &&
                            product.variations!.isNotEmpty) ||
                        (product.addOns != null && product.addOns!.isNotEmpty))
                      Padding(
                        padding: EdgeInsets.only(
                            top: ((product.price != 1 &&
                                        foodLevelNotes != 'Yes' &&
                                        (product.variations == null ||
                                            product.variations!.isEmpty) &&
                                        (product.addOns == null ||
                                            product.addOns!.isEmpty)) &&
                                    !product.isAddFirstTime!)
                                ? 0
                                : 7),
                        child: Text('Customisable',
                            style: poppinsMedium.copyWith(
                              fontSize: 11,
                              color: Colors.black,
                            )),
                      ),
                  ],
                );
              }),
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
