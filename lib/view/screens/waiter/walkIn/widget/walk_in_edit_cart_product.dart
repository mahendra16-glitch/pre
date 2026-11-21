import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/edit_walkin_order_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/responsive_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkInEditCartProductWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  double? variationTotal;

  WalkInEditCartProductWidget({
    required this.cart,
    required this.cartIndex,
    required this.isAvailable,
    required this.addOns,
    this.variationTotal,
  });

  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    int index0 = 0;
    double addonsTotal = 0;

    List<int> ids = [];
    List<int> qtys = [];
    for (var addOn in cart.addOnIds) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.product.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText =
            '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        addonsTotal = addonsTotal + (addOn.price! * qtys[index0]);

        index0 = index0 + 1;
      }
    }

    String variationText = '';
    double halfVariationPrice = 0;

    if (cart.variation.isNotEmpty) {
      for (int index = 0; index < cart.variation.length; index++) {
        if (cart.variation[index].isNotEmpty &&
            cart.variation[index].contains(true)) {
          variationText +=
              '${variationText.isNotEmpty ? ', ' : ''}${cart.product.variations![index].name} (';

          for (int i = 0; i < cart.variation[index].length; i++) {
            if (cart.variation[index][i]) {
              if (cart.product.variations![index].name!.toUpperCase() ==
                  'HALFNHALF') {
                if (halfVariationPrice <
                    double.parse(cart
                        .product.variations![index].values![i].optionPrice!)) {
                  halfVariationPrice = double.parse(
                      cart.product.variations![index].values![i].optionPrice!);
                }
              } else {
                variationTotal = (variationTotal ?? 0) +
                    double.parse(
                      cart.product.variations![index].values != null &&
                              cart.product.variations![index].values!.length > i
                          ? cart.product.variations![index].values![i]
                                  .optionPrice ??
                              '0'
                          : '0',
                    );
              }
              // print(variationTotal);
              variationText +=
                  '${variationText.endsWith('(') ? '' : ', '}${cart.product.variations![index].values![i].level}';
            }
          }
          variationText += ')';
          variationTotal = variationTotal! + halfVariationPrice;
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_DEFAULT),
      child: InkWell(
        onTap: () {
          // if (cart.product.price == 1 ||
          //     (cart.product.variations != null &&
          //         cart.product.variations.isNotEmpty) ||
          //     (cart.product.addOns != null && cart.product.addOns.isNotEmpty)) {
          //   if (cart.quantity == 1) {
          //     MediaQuery.of(context).size.width > 1600
          //         ? Get.dialog(
          //             Dialog(
          //               child: WallkInEditOrderBottomSheet(
          //                   product: cart.product,
          //                   cartIndex: cartIndex,
          //                   cart: cart),
          //             ),
          //             // backgroundColor: Colors.transparent,
          //             // isScrollControlled: true,
          //             // ignoreSafeArea: false
          //           )
          //         : showModalBottomSheet(
          //             context: context,
          //             isScrollControlled: true,
          //             useSafeArea: true,
          //             backgroundColor: Colors.transparent,
          //             builder: (con) {
          //               return WallkInEditOrderBottomSheet(
          //                   product: cart.product,
          //                   cartIndex: cartIndex,
          //                   cart: cart);
          //             },
          //           );
          //   }
          // }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: ColorTheme.productCard,
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
            ),
            child: Column(
              children: [
                Row(children: [
                  // Image should be removed from web browser

                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cart.product.name!,
                            style: poppinsSemiBold.copyWith(
                                color: Colors.black, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // if (cart.product.description != '')
                          //   const SizedBox(height: 2),
                          // if (cart.product.description != '')
                          //   Text(
                          //     cart.product.description ?? '',
                          //     style: poppinsMedium.copyWith(
                          //         color: ColorTheme.hintText,
                          //         fontSize:
                          //             MediaQuery.of(context).size.shortestSide >
                          //                     570
                          //                 ? 13
                          //                 : 10),
                          //     maxLines: 2,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          const SizedBox(height: 2),

                          // Ratig should be removed from web browser

                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .isComplementry !=
                              'Yes')
                            const SizedBox(height: 5),
                          if (Get.find<AuthController>()
                                  .profileModel!
                                  .restaurants!
                                  .first
                                  .isComplementry !=
                              'Yes')
                            Row(children: [
                              Text(
                                PriceConverter.convertPrice(
                                    cart.product.price! +
                                        variationTotal! +
                                        (Get.find<EditWalkInOrderController>()
                                                    .orderType ==
                                                'take_away'
                                            ? cart.product.takeAwayFoodPrice!
                                            : Get.find<EditWalkInOrderController>()
                                                        .orderType ==
                                                    'delivery'
                                                ? cart
                                                    .product.deliveryFoodPrice!
                                                : 0),
                                    asFixed: 2,
                                    isHideCurrency: true),
                                textDirection: TextDirection.ltr,
                                style: poppinsBold.copyWith(
                                    color: ColorTheme.green, fontSize: 13),
                              ),
                              // const SizedBox(
                              //     width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              // cart.discountedPrice + cart.discountAmount >
                              //         cart.discountedPrice
                              //     ? Text(
                              //         PriceConverter.convertPrice(
                              //             cart.discountedPrice +
                              //                 cart.discountAmount),
                              //         textDirection: TextDirection.ltr,
                              //         style: poppinsMedium.copyWith(
                              //             color:
                              //                 Theme.of(context).disabledColor,
                              //             fontSize: Dimensions.FONT_SIZE_SMALL,
                              //             decoration:
                              //                 TextDecoration.lineThrough),
                              //       )
                              //     : const SizedBox(),
                            ]),
                        ]),
                  ),

                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Get.find<SplashController>()
                        //         .configModel
                        //         .toggleVegNonVeg
                        //     ? Container(
                        //         padding: const EdgeInsets.symmetric(
                        //             vertical:
                        //                 Dimensions.PADDING_SIZE_EXTRA_SMALL,
                        //             horizontal:
                        //                 Dimensions.PADDING_SIZE_SMALL),
                        //         decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(
                        //               Dimensions.RADIUS_SMALL),
                        //           color: Theme.of(context).primaryColor,
                        //         ),
                        //         child: Text(
                        //           cart.product.veg == 0
                        //               ? 'non_veg'.tr
                        //               : 'veg'.tr,
                        //           style: poppinsRegular.copyWith(
                        //               fontSize:
                        //                   Dimensions.FONT_SIZE_EXTRA_SMALL,
                        //               color: Colors.white),
                        //         ),
                        //       )
                        //     : const SizedBox(),
                        // SizedBox(
                        //     height: Get.find<SplashController>()
                        //             .configModel
                        //             .toggleVegNonVeg
                        //         ? Dimensions.PADDING_SIZE_EXTRA_SMALL
                        //         : 0),
                        Container(
                          width: 90,
                          padding: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: ColorTheme.borderGrey)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: QuantityButton(
                                    onTap: () {
                                      if (cart.quantity > 1) {
                                        Get.find<EditWalkInOrderController>()
                                            .setQuantity(false, cart);
                                      } else {
                                        Get.find<EditWalkInOrderController>()
                                            .removeFromCart(cartIndex);
                                        if (Get.find<
                                                EditWalkInOrderController>()
                                            .cartList
                                            .isEmpty) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    isIncrement: false,
                                  ),
                                ),
                                Text(
                                  // cart.quantity.toString(),
                                  cart.quantity % 1 == 0
                                      ? cart.quantity.toInt().toString()
                                      : cart.quantity.toString(),
                                    style:
                                        poppinsMedium.copyWith(fontSize: 14)),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: QuantityButton(
                                    onTap: () {
                                      if (addOnText == '') {
                                        Get.find<EditWalkInOrderController>()
                                            .setQuantity(true, cart);
                                      }
                                    },
                                    isIncrement: true,
                                  ),
                                ),
                              ]),
                        ),
                      ]),

                  !ResponsiveHelper.isMobile(context)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_SMALL),
                          child: IconButton(
                            onPressed: () {
                              Get.find<EditWalkInOrderController>()
                                  .removeFromCart(cartIndex);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        )
                      : const SizedBox(),
                ]),
                (variationText != '' &&
                        cart.product.variations != null &&
                        cart.product.variations!.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Variants: ',
                                  style: poppinsMedium.copyWith(
                                      color: ColorTheme.blue,
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 14
                                          : 10),
                                  textDirection: TextDirection.ltr),
                              Flexible(
                                child: Text(variationText,
                                    style: poppinsMedium.copyWith(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 14
                                            : 10,
                                        color: ColorTheme.green)),
                              ),
                            ]),
                      )
                    : const SizedBox(),
                addOnText.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${'addons'.tr}: ',
                                  style: poppinsMedium.copyWith(
                                      color: ColorTheme.blue,
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 14
                                          : 10)),
                              Flexible(
                                  child: Text(
                                addOnText,
                                textDirection: TextDirection.ltr,
                                style: poppinsMedium.copyWith(
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 14
                                        : 10,
                                    color: Colors.black),
                              )),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    PriceConverter.convertPrice(addonsTotal,
                                        isHideCurrency: true),
                                    textDirection: TextDirection.ltr,
                                    style: poppinsBold.copyWith(
                                        fontSize: 10, color: ColorTheme.green),
                                  ),
                                ),
                              )
                            ]),
                      )
                    : const SizedBox(),
                if (cart.foodNote != '')
                  Padding(
                    padding: const EdgeInsets.only(
                        top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Note: ',
                              style: poppinsMedium.copyWith(
                                  color: ColorTheme.blue,
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              570
                                          ? 14
                                          : 10),
                              textDirection: TextDirection.ltr),
                          Flexible(
                            child: Text(cart.foodNote ?? '',
                                style: poppinsMedium.copyWith(
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 14
                                        : 10,
                                    color: ColorTheme.green)),
                          ),
                        ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
