import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/edit_walkin_order_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/responsive_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:mygenie_restaurant/view/screens/waiter/walkIn/widget/walk_in_edit_order_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkInProductWidget extends StatelessWidget {
  final Product product;
  final int index;
  final String orderType;
  final int length;
  final bool isCampaign;
  final bool isAddOn;
  List<Product> products;

  WalkInProductWidget(
      {required this.product,
      required this.index,
      required this.orderType,
      required this.length,
      this.isCampaign = false,
      this.isAddOn = false,
      required this.products});

  @override
  Widget build(BuildContext context) {
    //   // BaseUrls _baseUrls = Get.find<SplashController>().configModel.baseUrls;
    //   bool _desktop = ResponsiveHelper.isDesktop(context);
    //   double _discount;
    //   String _discountType;
    //   bool _isAvailable;
    //   _discount = (product.restaurantDiscount == 0 || isCampaign)
    //       ? product.discount
    //       : product.restaurantDiscount;
    //   _discountType = (product.restaurantDiscount == 0 || isCampaign)
    //       ? product.discountType
    //       : 'percent';
    //   _isAvailable = DateConverter.isAvailable(
    //           product.availableTimeStarts, product.availableTimeEnds) &&
    //       DateConverter.isAvailable(
    //           product.restaurantOpeningTime, product.restaurantClosingTime);

    //   return InkWell(
    //     onTap: () {},
    //     child: Container(
    //       padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
    //       margin: EdgeInsets.only(
    //           top: index == 0 ? 0 : Dimensions.PADDING_SIZE_DEFAULT),
    //       // padding: ResponsiveHelper.isDesktop(context)
    //       //     ? EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL)
    //       //     : null,
    //       decoration: BoxDecoration(
    //         color: ColorTheme.productCard,
    //         borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
    //         boxShadow: ResponsiveHelper.isDesktop(context)
    //             ? [
    //                 BoxShadow(
    //                   color: Colors.grey[Get.isDarkMode ? 700 : 300],
    //                   spreadRadius: 1,
    //                   blurRadius: 5,
    //                 )
    //               ]
    //             : null,
    //       ),
    //       child: Row(children: [
    //         Expanded(
    //           child: Padding(
    //             padding: EdgeInsets.symmetric(vertical: 7),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   product.name,
    //                   style: poppinsSemiBold.copyWith(fontSize: 15),
    //                   maxLines: _desktop ? 2 : 2,
    //                   overflow: TextOverflow.ellipsis,
    //                 ),
    //                 if (Get.find<AuthController>()
    //                         .profileModel
    //                         .restaurants
    //                         .first
    //                         .isComplementry !=
    //                     'Yes')
    //                   Padding(
    //                     padding: const EdgeInsets.only(top: 7),
    //                     child: Text(
    //                       '₹ ${product.price}',
    //                       style: poppinsBold.copyWith(
    //                           fontSize: 12, color: ColorTheme.green),
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                   ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         if ((product.price != 1 &&
    //                 (product.variations == null || product.variations.isEmpty) &&
    //                 (product.addOns == null || product.addOns.isEmpty)) &&
    //             !product.isAddFirstTime)
    //           Stack(
    //             children: [
    //               Container(
    //                 height: 60,
    //                 padding: EdgeInsets.symmetric(vertical: 15),
    //                 child: Container(
    //                   width: 90,
    //                   height: 30,
    //                   padding: EdgeInsets.symmetric(vertical: 5),
    //                   decoration: BoxDecoration(
    //                       borderRadius: BorderRadius.circular(7),
    //                       border: Border.all(color: ColorTheme.borderGrey)),
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       QuantityButton(
    //                         onTap: () {
    //                           // CartModel cart;
    //                           // int cartIndex;
    //                           // for (var i = 0;
    //                           //     i <
    //                           //         Get.find<EditWalkInOrderController>()
    //                           //             .cartList
    //                           //             .length;
    //                           //     i++) {
    //                           //   CartModel _cartModel =
    //                           //       Get.find<EditWalkInOrderController>().cartList[i];
    //                           //   if (_cartModel.quantity == product.qty &&
    //                           //       product.id == _cartModel.product.id) {
    //                           //     cart = _cartModel;
    //                           //     cartIndex = i;
    //                           //     break;
    //                           //   }
    //                           // }
    //                           // if (product.qty > 1) {
    //                           //   // CartModel cart = CartModel(
    //                           //   //     adjustPrice: 1,
    //                           //   //     price: product.price,
    //                           //   //     discountedPrice: product.price,
    //                           //   //     discountAmount: 0,
    //                           //   //     // discountAmount: (product.price -
    //                           //   //     //     PriceConverter.convertWithDiscount(
    //                           //   //     //         product.price, _discount, _discountType)),
    //                           //   //     quantity: product.qty,
    //                           //   //     addOnIds: [],
    //                           //   //     addOns: [],
    //                           //   //     isCampaign: false,
    //                           //   //     product: product,
    //                           //   //     variation: []);
    //                           //   if (cart != null) {
    //                           //     Get.find<EditWalkInOrderController>()
    //                           //         .setQuantity(false, cart);
    //                           //     product.qty = product.qty - 1;
    //                           //     Get.find<RestaurantController>().update();
    //                           //   }
    //                           // } else {
    //                           //   if (cartIndex != null) {
    //                           //     Get.find<EditWalkInOrderController>()
    //                           //         .removeFromCart(cartIndex);
    //                           //     product.qty = product.qty - 1;
    //                           //     Get.find<RestaurantController>().update();
    //                           //   }
    //                           // }
    //                         },
    //                         isIncrement: false,
    //                       ),
    //                       Text('${product.qty}',
    //                           style: poppinsMedium.copyWith(
    //                               color: Colors.black, fontSize: 14)),
    //                       QuantityButton(
    //                         isIncrement: true,
    //                         onTap: () {
    //                           // if (product.qty > 0) {
    //                           //   CartModel cart;
    //                           //   for (var i = 0;
    //                           //       i <
    //                           //           Get.find<EditWalkInOrderController>()
    //                           //               .cartList
    //                           //               .length;
    //                           //       i++) {
    //                           //     CartModel _cartModel =
    //                           //         Get.find<EditWalkInOrderController>()
    //                           //             .cartList[i];
    //                           //     if (_cartModel.quantity == product.qty &&
    //                           //         product.id == _cartModel.product.id) {
    //                           //       cart = _cartModel;
    //                           //       break;
    //                           //     }
    //                           //   }
    //                           //   if (cart != null) {
    //                           //     Get.find<EditWalkInOrderController>()
    //                           //         .setQuantity(true, cart);
    //                           //     product.qty = product.qty + 1;
    //                           //     Get.find<RestaurantController>().update();
    //                           //   }
    //                           // } else {
    //                           //   CartModel _cartModel = CartModel(
    //                           //       adjustPrice: 1,
    //                           //       price: product.price,
    //                           //       discountedPrice: product.price,
    //                           //       discountAmount: 0,
    //                           //       quantity: 1,
    //                           //       addOnIds: [],
    //                           //       addOns: [],
    //                           //       isCampaign: false,
    //                           //       product: product,
    //                           //       variation: []);

    //                           //   Get.find<EditWalkInOrderController>()
    //                           //       .addToCart(_cartModel, null);
    //                           //   product.qty++;
    //                           //   Get.find<RestaurantController>().update();
    //                           // }
    //                         },
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               Row(
    //                 children: [
    //                   InkWell(
    //                     onTap: () {
    //                       CartModel cart;
    //                       int cartIndex;
    //                       for (var i = 0;
    //                           i <
    //                               Get.find<EditWalkInOrderController>()
    //                                   .cartList
    //                                   .length;
    //                           i++) {
    //                         CartModel _cartModel =
    //                             Get.find<EditWalkInOrderController>().cartList[i];
    //                         if (_cartModel.quantity == product.qty &&
    //                             product.id == _cartModel.product.id) {
    //                           cart = _cartModel;
    //                           cartIndex = i;
    //                           break;
    //                         }
    //                       }
    //                       if (product.qty > 1) {
    //                         if (cart != null) {
    //                           Get.find<EditWalkInOrderController>()
    //                               .setQuantity(false, cart);
    //                           product.qty = product.qty - 1;
    //                           Get.find<RestaurantController>().update();
    //                         }
    //                       } else {
    //                         if (cartIndex != null) {
    //                           Get.find<EditWalkInOrderController>()
    //                               .removeFromCart(cartIndex);
    //                           product.qty = product.qty - 1;
    //                           Get.find<RestaurantController>().update();
    //                         }
    //                       }
    //                     },
    //                     child: Container(
    //                       width: 45,
    //                       height: 60,
    //                       // color: Colors.transparent,
    //                     ),
    //                   ),
    //                   InkWell(
    //                     onTap: () {
    //                       if (product.qty > 0) {
    //                         CartModel cart;
    //                         for (var i = 0;
    //                             i <
    //                                 Get.find<EditWalkInOrderController>()
    //                                     .cartList
    //                                     .length;
    //                             i++) {
    //                           CartModel _cartModel =
    //                               Get.find<EditWalkInOrderController>()
    //                                   .cartList[i];
    //                           if (_cartModel.quantity == product.qty &&
    //                               product.id == _cartModel.product.id) {
    //                             cart = _cartModel;
    //                             break;
    //                           }
    //                         }
    //                         if (cart != null) {
    //                           Get.find<EditWalkInOrderController>()
    //                               .setQuantity(true, cart);
    //                           product.qty = product.qty + 1;
    //                           Get.find<RestaurantController>().update();
    //                         }
    //                       } else {
    //                         CartModel _cartModel = CartModel(
    //                             adjustPrice: 1,
    //                             price: product.price,
    //                             discountedPrice: product.price,
    //                             discountAmount: 0,
    //                             quantity: 1,
    //                             addOnIds: [],
    //                             addOns: [],
    //                             isCampaign: false,
    //                             product: product,
    //                             variation: []);

    //                         Get.find<EditWalkInOrderController>()
    //                             .addToCart(_cartModel, null);
    //                         product.qty++;
    //                         Get.find<RestaurantController>().update();
    //                       }
    //                     },
    //                     child: Container(
    //                       width: 45,
    //                       height: 60,
    //                       // color: Colors.transparent,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),

    //         // Text(
    //         //   PriceConverter.convertPrice(product.price,
    //         //       isHideCurrency: true,
    //         //       asFixed: 2,
    //         //       discount: _discount,
    //         //       discountType: _discountType),
    //         //   style: poppinsMedium.copyWith(
    //         //       color: Color.fromRGBO(128, 76, 25, 1.0), fontSize: 11),
    //         // ),

    //         if (product.price == 1 ||
    //             (product.variations != null && product.variations.isNotEmpty) ||
    //             (product.addOns != null && product.addOns.isNotEmpty) ||
    //             product.isAddFirstTime)
    //           InkWell(
    //             onTap: () async {
    //               FocusManager.instance.primaryFocus?.unfocus();
    //               // print(product?.addOns);
    //               FocusManager.instance.primaryFocus?.unfocus();
    //               // searchController.clear();
    //               // print(product?.addOns);
    //               if ((product.price != 1 &&
    //                   (product.variations == null ||
    //                       product.variations.isEmpty) &&
    //                   (product.addOns == null || product.addOns.isEmpty))) {
    //                 CartModel _cartModel = CartModel(
    //                     adjustPrice: 1,
    //                     price: product.price,
    //                     discountedPrice: product.price,
    //                     discountAmount: 0,
    //                     quantity: 1,
    //                     addOnIds: [],
    //                     addOns: [],
    //                     isCampaign: false,
    //                     product: product,
    //                     variation: []);
    //                 product.isAddFirstTime = false;
    //                 Get.find<EditWalkInOrderController>()
    //                     .addToCart(_cartModel, null);
    //                 product.qty++;
    //                 Get.find<RestaurantController>().update();
    //               } else {
    //                 Get.bottomSheet(
    //                     WallkInEditOrderBottomSheet(
    //                         product: product, isCampaign: isCampaign),
    //                     backgroundColor: Colors.transparent,
    //                     isScrollControlled: true,
    //                     ignoreSafeArea: false);
    //               }
    //               // Get.bottomSheet(
    //               //     WallkInEditOrderBottomSheet(
    //               //         product: product, isCampaign: isCampaign),
    //               //     backgroundColor: Colors.transparent,
    //               //     isScrollControlled: true,
    //               //     ignoreSafeArea: false);
    //             },
    //             child: Container(
    //               width: 90,
    //               padding: EdgeInsets.symmetric(vertical: 6),
    //               margin: EdgeInsets.only(left: 4),
    //               decoration: BoxDecoration(
    //                   color: ColorTheme.appColor,
    //                   borderRadius: BorderRadius.circular(7)),
    //               child: Center(
    //                 child: Text(
    //                   'add'.tr,
    //                   style: poppinsMedium.copyWith(
    //                       color: Colors.white, fontSize: 14),
    //                 ),
    //               ),
    //             ),
    //           ),
    //       ]),
    //     ),
    //   );
    // }

    // BaseUrls _baseUrls = Get.find<SplashController>().configModel.baseUrls;
    // bool _desktop = ResponsiveHelper.isDesktop(context);
    // double _discount;
    // String _discountType;
    bool _isAvailable;
    // _discount = (product.restaurantDiscount == 0 || isCampaign)
    //     ? product.discount
    //     : product.restaurantDiscount;
    // _discountType = (product.restaurantDiscount == 0 || isCampaign)
    //     ? product.discountType
    //     : 'percent';
    _isAvailable = DateConverter.isAvailable(
        product.availableTimeStarts!, product.availableTimeEnds!);

    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        margin: EdgeInsets.only(
            top: index == 0 ? 0 : Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
          color: ColorTheme.productCard,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
          boxShadow: ResponsiveHelper.isDesktop(context)
              ? [
                  BoxShadow(
                    color:
                        Colors.grey[Get.isDarkMode ? 700 : 300] ?? Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 5,
                  )
                ]
              : null,
        ),
        child: Row(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name!,
                    style: poppinsSemiBold.copyWith(fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      orderType == 'take_away'
                          ? '₹ ${product.takeAwayFoodPrice! + product.price!}'
                          : orderType == 'delivery'
                              ? '₹ ${product.deliveryFoodPrice! + product.price!}'
                              : '₹ ${product.price}',
                      style: poppinsBold.copyWith(
                          fontSize: 12, color: ColorTheme.green),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if ((product.price != 1 &&
                  Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .foodLevelNotes !=
                      'Yes' &&
                  (product.variations == null || product.variations!.isEmpty) &&
                  (product.addOns == null || product.addOns!.isEmpty)) &&
              !product.isAddFirstTime!)
            Stack(
              children: [
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Container(
                    width: 90,
                    height: 30,
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
                                color: Colors.black, fontSize: 14)),
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
                        CartModel? cart;
                        int cartIndex = -1;
                        for (var i = 0;
                            i <
                                Get.find<EditWalkInOrderController>()
                                    .cartList
                                    .length;
                            i++) {
                          CartModel _cartModel =
                              Get.find<EditWalkInOrderController>().cartList[i];
                          if (_cartModel.quantity == product.qty &&
                              product.id == _cartModel.product.id) {
                            cart = _cartModel;
                            cartIndex = i;
                            break;
                          }
                        }
                        if ((product.qty ?? 0) > 1) {
                          Get.find<EditWalkInOrderController>()
                              .setQuantity(false, cart);
                          product.qty = (product.qty ?? 1) - 1;
                          Get.find<RestaurantController>().update();
                        } else {
                          if (cartIndex != -1) {
                            Get.find<EditWalkInOrderController>()
                                .removeFromCart(cartIndex);
                          }
                          product.qty = (product.qty ?? 1) - 1;
                          Get.find<RestaurantController>().update();
                        }
                      },
                      child: Container(
                        width: 45,
                        height: 60,
                        // color: Colors.transparent,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (product.qty! > 0) {
                          CartModel? cart;
                          for (var i = 0;
                              i <
                                  Get.find<EditWalkInOrderController>()
                                      .cartList
                                      .length;
                              i++) {
                            CartModel _cartModel =
                                Get.find<EditWalkInOrderController>()
                                    .cartList[i];
                            if (_cartModel.quantity == product.qty &&
                                product.id == _cartModel.product.id) {
                              cart = _cartModel;
                              break;
                            }
                          }
                          if (cart != null) {
                            Get.find<EditWalkInOrderController>()
                                .setQuantity(true, cart);
                            product.qty = (product.qty ?? 0) + 1;
                            Get.find<RestaurantController>().update();
                          }
                        } else {
                          CartModel _cartModel = CartModel(
                              adjustPrice: 1,
                              price: product.price!,
                              discountedPrice: product.price!,
                              // discountAmount: 0,
                              quantity: 1,
                              addOnIds: [],
                              addOns: [],
                              // isCampaign: false,
                              product: product,
                              variation: []);

                          Get.find<EditWalkInOrderController>()
                              .addToCart(_cartModel, null);
                          product.qty = (product.qty ?? 0) + 1;
                          Get.find<RestaurantController>().update();
                        }
                      },
                      child: Container(
                        width: 45,
                        height: 60,
                        // color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (product.price == 1 ||
              Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .foodLevelNotes ==
                  'Yes' ||
              (product.variations != null && product.variations!.isNotEmpty) ||
              (product.addOns != null && product.addOns!.isNotEmpty) ||
              product.isAddFirstTime!)
            InkWell(
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                // searchController.clear();
                swapToTop(index);
                // print(product?.addOns);
                if ((product.price != 1 &&
                    Get.find<AuthController>()
                            .profileModel!
                            .restaurants!
                            .first
                            .foodLevelNotes !=
                        'Yes' &&
                    (product.variations == null ||
                        product.variations!.isEmpty) &&
                    (product.addOns == null || product.addOns!.isEmpty))) {
                  CartModel _cartModel = CartModel(
                      adjustPrice: 1,
                      price: product.price!,
                      discountedPrice: product.price!,
                      // discountAmount: 0,
                      quantity: 1,
                      addOnIds: [],
                      addOns: [],
                      // isCampaign: false,
                      product: product,
                      variation: []);
                  product.isAddFirstTime = false;
                  Get.find<EditWalkInOrderController>()
                      .addToCart(_cartModel, null);
                  product.qty = (product.qty ?? 0) + 1;
                  Get.find<RestaurantController>().update();
                } else {
                  Get.find<EditWalkInOrderController>().initData(product, null);

                  Get.bottomSheet(
                      WallkInEditOrderBottomSheet(
                          orderType: orderType,
                          product: product,
                          isCampaign: isCampaign),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      ignoreSafeArea: false);
                }
              },
              child: Container(
                width: 90,
                height: 30,
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
