import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/edit_walkin_order_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/responsive_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_button.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controller/restaurant_controller.dart';

class WallkInEditOrderBottomSheet extends StatelessWidget {
  bool isTapButton = false;

  final Product product;
  final bool isCampaign;
  final CartModel? cart;
  final int? cartIndex;
  final String orderType;

  // Function onIncrease;
  WallkInEditOrderBottomSheet(
      {required this.product,
      this.isCampaign = false,
      this.cart,
      this.cartIndex,
      required this.orderType});

  TextEditingController adjustPriceController =
      TextEditingController(text: '1');
  TextEditingController updateFoodName = TextEditingController(text: '');
  TextEditingController foodNotes = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool fromCart = cart != null;
    // Get.find<EditWalkInOrderController>().initData(product, cart);
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.only(
              left: Dimensions.PADDING_SIZE_DEFAULT,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: ResponsiveHelper.isMobile(context)
                ? BorderRadius.vertical(
                    top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE))
                : BorderRadius.all(
                    Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
          ),
          child:
              GetBuilder<EditWalkInOrderController>(builder: (posController) {
            double _startingPrice = 0;
            double _endingPrice = 0;
            double variationPrice = 0;
            double halfVariationPrice = 0;
            if (product.variations != null &&
                posController.selectedVariations != null) {
              for (int index = 0; index < product.variations!.length; index++) {
                for (int i = 0;
                    i < (product.variations![index].values?.length ?? 0);
                    i++) {
                  if (posController.selectedVariations != null &&
                      posController.selectedVariations!.isNotEmpty &&
                      posController.selectedVariations?[index] != null &&
                      posController.selectedVariations![index].isNotEmpty &&
                      posController.selectedVariations![index][i]) {
                    if (product.variations![index].name!.toUpperCase() ==
                        'HALFNHALF') {
                      if (halfVariationPrice <
                          double.parse(product
                              .variations![index].values![i].optionPrice!)) {
                        halfVariationPrice = double.parse(
                            product.variations![index].values![i].optionPrice!);
                      }
                    } else {
                      variationPrice += double.parse(
                          product.variations![index].values![i].optionPrice!);
                    }
                  }
                }

                variationPrice = variationPrice + halfVariationPrice;
              }
            }
            double price = (product.price ?? 0) > 1
                ? (product.price ?? 0)
                : (product.price ?? 0) == 0
                    ? (product.price ?? 0)
                    : double.parse(adjustPriceController.text.isEmpty
                        ? '0'
                        : adjustPriceController.text);

            double _discount =
                (isCampaign || (product.restaurantDiscount ?? 0) == 0)
                    ? (product.discount ?? 0)
                    : (product.restaurantDiscount ?? 0);
            String _discountType =
                (isCampaign || (product.restaurantDiscount ?? 0) == 0)
                    ? (product.discountType ?? 'percent')
                    : 'percent';
            double priceWithDiscount =
                PriceConverter.convertWithDiscount(price, 0, _discountType);
            double addonsCost = 0;
            List<AddOn> _addOnIdList = [];
            List<AddOns> _addOnsList = [];
            for (int index = 0;
                index < (product.addOns?.length ?? 0);
                index++) {
              if (posController.addOnActiveList[index]) {
                addonsCost = addonsCost +
                    ((product.addOns?[index].price ?? 0) *
                        (posController.addOnQtyList[index] ?? 0));
                _addOnIdList.add(AddOn(
                    id: product.addOns?[index].id ?? 0,
                    name: product.addOns?[index].name ?? '',
                    price: product.addOns?[index].price ?? 0,
                    quantity: posController.addOnQtyList[index] ?? 0));
                _addOnsList.add(product.addOns?[index] ?? AddOns());
              }
            }
            // double priceWithAddons = priceWithQuantity + addonsCost;
            double priceWithAddonsVariation = addonsCost +
                (PriceConverter.convertWithDiscount(
                        variationPrice + price, 0, 'percent') *
                    posController.quantity);
            // bool _isRestAvailable = DateConverter.isAvailable(
            //     product.restaurantOpeningTime, product.restaurantClosingTime);
            // bool _isFoodAvailable = DateConverter.isAvailable(
            //     product.availableTimeStarts, product.availableTimeEnds);
            // bool _isAvailable = _isRestAvailable && _isFoodAvailable;
            double priceWithVariation = price + variationPrice;
            return SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: Dimensions.PADDING_SIZE_DEFAULT,
                        top: ResponsiveHelper.isDesktop(context)
                            ? 0
                            : Dimensions.PADDING_SIZE_DEFAULT,
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Product
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name ?? '',
                                          style: poppinsMedium.copyWith(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1600
                                                  ? 25
                                                  : MediaQuery.of(context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 19
                                                      : 18),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: InkWell(
                                            onTap: () => Get.back(),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 15,
                                              ),
                                              child: Icon(Icons.close,
                                                  color: ColorTheme.appColor),
                                            )),
                                      ),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Divider(
                                      color: ColorTheme.borderGrey,
                                    ),
                                  ),
                                  // if (product.description != '' &&
                                  //     product.description.toUpperCase() != 'NONE')
                                  //   SizedBox(height: 5),
                                  // if (product.description != '' &&
                                  //     product.description.toUpperCase() != 'NONE')
                                  //   Text(
                                  //     product.description,
                                  //     style: poppinsRegular.copyWith(
                                  //         fontSize:
                                  //             MediaQuery.of(context).size.width > 1600
                                  //                 ? 21
                                  //                 : MediaQuery.of(context)
                                  //                             .size
                                  //                             .shortestSide >
                                  //                         570
                                  //                     ? 16
                                  //                     : 14),
                                  //     maxLines: 2,
                                  //     overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // SizedBox(height: 10),
                                  // Text(
                                  //   '${PriceConverter.convertPrice(_startingPrice, discount: _discount, discountType: _discountType)}'
                                  //   '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(_endingPrice, discount: _discount, discountType: _discountType)}' : ''}',
                                  //   style: poppinsMedium.copyWith(
                                  //       fontSize:
                                  //           Dimensions.FONT_SIZE_LARGE),
                                  // ),
                                  // SizedBox(height: 5),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isComplementry !=
                                      'Yes')
                                    price > priceWithDiscount
                                        ? Text(
                                            '${PriceConverter.convertPrice(_startingPrice)}'
                                            '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(_endingPrice)}' : ''}',
                                            style: poppinsMedium.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          )
                                        : SizedBox(),
                                ]),

                            // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                            if (product.name!
                                    .toLowerCase()
                                    .contains('out of') &&
                                product.price == 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Food name:  ',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 15)),
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    1600
                                                ? 50
                                                : MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 40
                                                    : 30,
                                        child: TextField(
                                          controller: updateFoodName,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          onChanged: (v) {
                                            posController.update();
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 0,
                                                horizontal: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 8
                                                    : Dimensions
                                                        .PADDING_SIZE_EXTRA_SMALL),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            hintStyle: poppinsRegular.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 21
                                                    : MediaQuery.of(context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 15,
                                                color: ColorTheme.hintText),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          style: poppinsRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    1600
                                                ? 21
                                                : MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Variation
                            product.variations != null
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: product.variations?.length ?? 0,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      product.variations![index]
                                                          .name!,
                                                      style: poppinsSemiBold
                                                          .copyWith(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >
                                                                      1600
                                                                  ? 23
                                                                  : MediaQuery.of(context)
                                                                              .size
                                                                              .shortestSide >
                                                                          570
                                                                      ? 18
                                                                      : 15)),
                                                  Text(
                                                    ' (${product.variations![index].required == 'on' ? 'required'.tr : 'optional'.tr})',
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            color:
                                                                ColorTheme.blue,
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >
                                                                    1600
                                                                ? 20
                                                                : MediaQuery.of(context)
                                                                            .size
                                                                            .shortestSide >
                                                                        570
                                                                    ? 14
                                                                    : 10),
                                                  ),
                                                ]),
                                            if (isTapButton &&
                                                product.variations![index]
                                                        .type !=
                                                    'multi' &&
                                                product.variations![index]
                                                        .required ==
                                                    'on' &&
                                                !posController
                                                    .selectedVariations![index]
                                                    .contains(true))
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                    '${'Choose a variation from'.tr} ${product.variations![index].name}',
                                                    style:
                                                        poppinsRegular.copyWith(
                                                            color: Colors.red,
                                                            fontSize: 10),
                                                  ),
                                                ),
                                              ),

                                            if (isTapButton &&
                                                (product.variations![index]
                                                            .type ==
                                                        'multi' &&
                                                    (product.variations![index]
                                                                .required ==
                                                            'on' ||
                                                        posController
                                                            .selectedVariations![
                                                                index]
                                                            .contains(true)) &&
                                                    int.parse(product
                                                            .variations![index]
                                                            .min!) >
                                                        posController
                                                            .selectedVariationLength(
                                                                posController
                                                                    .selectedVariations!,
                                                                index)))
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                    '${'You need to select minimum'.tr} ${product.variations![index].min} '
                                                    '${'to maximum'.tr} ${product.variations![index].max} ${'options from'.tr} ${product.variations![index].name} ${'variation'.tr}',
                                                    style:
                                                        poppinsRegular.copyWith(
                                                            color: Colors.red,
                                                            fontSize: 10),
                                                  ),
                                                ),
                                              ),

                                            const SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_EXTRA_SMALL),
                                            // Row(children: [
                                            //   product.variations[index].type ==
                                            //           'multi'
                                            //       ? Text(
                                            //           '${'you_need_to_select_minimum'.tr} ${'${product.variations[index].min}'
                                            //               ' ${'to_maximum'.tr} ${product.variations[index].max} ${'options'.tr}'}',
                                            //           style: poppinsMedium.copyWith(
                                            //               fontSize: Dimensions
                                            //                   .FONT_SIZE_EXTRA_SMALL,
                                            //               color: Theme.of(context)
                                            //                   .disabledColor),
                                            //         )
                                            //       : const SizedBox(),
                                            // ]),

                                            SizedBox(
                                                height: product
                                                            .variations![index]
                                                            .type ==
                                                        'multi'
                                                    ? Dimensions
                                                        .PADDING_SIZE_EXTRA_SMALL
                                                    : 0),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemCount: product
                                                  .variations![index]
                                                  .values!
                                                  .length,
                                              itemBuilder: (context, i) {
                                                return InkWell(
                                                  onTap: () {
                                                    posController
                                                        .setCartVariationIndex(
                                                            index,
                                                            i,
                                                            product,
                                                            product
                                                                    .variations![
                                                                        index]
                                                                    .type ==
                                                                'multi');
                                                  },
                                                  child: Row(children: [
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          product
                                                                      .variations![
                                                                          index]
                                                                      .type ==
                                                                  'multi'
                                                              ? SizedBox(
                                                                  width: 20,
                                                                  child:
                                                                      Checkbox(
                                                                    value: posController
                                                                            .selectedVariations![
                                                                                index]
                                                                            .isNotEmpty &&
                                                                        posController.selectedVariations![index]
                                                                            [i],
                                                                    activeColor:
                                                                        Theme.of(context)
                                                                            .primaryColor,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                                                                    onChanged:
                                                                        (bool?
                                                                            newValue) {
                                                                      posController
                                                                          .setCartVariationIndex(
                                                                        index,
                                                                        i,
                                                                        product,
                                                                        product.variations![index].type ==
                                                                            'multi',
                                                                      );
                                                                    },
                                                                    visualDensity: const VisualDensity(
                                                                        horizontal:
                                                                            -3,
                                                                        vertical:
                                                                            -3),
                                                                  ),
                                                                )
                                                              : SizedBox(
                                                                  width: 20,
                                                                  child: Radio(
                                                                    value: i,
                                                                    groupValue: posController
                                                                            .selectedVariations!
                                                                            .isEmpty
                                                                        ? null
                                                                        : posController
                                                                            .selectedVariations?[index]
                                                                            .indexOf(true),
                                                                    onChanged:
                                                                        (dynamic
                                                                            value) {
                                                                      posController
                                                                          .setCartVariationIndex(
                                                                        index,
                                                                        i,
                                                                        product,
                                                                        product.variations![index].type ==
                                                                            'multi',
                                                                      );
                                                                    },
                                                                    activeColor:
                                                                        ColorTheme
                                                                            .appColor,
                                                                    toggleable:
                                                                        false,
                                                                    visualDensity: const VisualDensity(
                                                                        horizontal:
                                                                            -3,
                                                                        vertical:
                                                                            -3),
                                                                  ),
                                                                ),
                                                          SizedBox(width: 12),
                                                          Text(
                                                            product
                                                                .variations![
                                                                    index]
                                                                .values![i]
                                                                .level!
                                                                .trim(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: (posController
                                                                            .selectedVariations !=
                                                                        null &&
                                                                    posController
                                                                        .selectedVariations!
                                                                        .isNotEmpty &&
                                                                    posController
                                                                        .selectedVariations![
                                                                            index]
                                                                        .isNotEmpty &&
                                                                    posController
                                                                            .selectedVariations![
                                                                        index][i])
                                                                ? poppinsMedium.copyWith(
                                                                    fontSize: MediaQuery.of(context).size.width > 1600
                                                                        ? 19
                                                                        : MediaQuery.of(context).size.shortestSide > 570
                                                                            ? 16
                                                                            : 12)
                                                                : poppinsMedium.copyWith(
                                                                    fontSize: MediaQuery.of(context).size.width > 1600
                                                                        ? 19
                                                                        : MediaQuery.of(context).size.shortestSide > 570
                                                                            ? 16
                                                                            : 12),
                                                          ),
                                                        ]),
                                                    const Spacer(),
                                                    if (Get.find<
                                                                AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .isComplementry !=
                                                        'Yes')
                                                      Text(
                                                        '+${PriceConverter.convertPrice(double.parse(product.variations![index].values![i].optionPrice!))}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textDirection:
                                                            TextDirection.ltr,
                                                        style: (posController
                                                                        .selectedVariations !=
                                                                    null &&
                                                                posController
                                                                    .selectedVariations!
                                                                    .isNotEmpty &&
                                                                posController
                                                                    .selectedVariations![
                                                                        index]
                                                                    .isNotEmpty &&
                                                                posController
                                                                        .selectedVariations![
                                                                    index][i])
                                                            ? poppinsBold
                                                                .copyWith(
                                                                    color: ColorTheme
                                                                        .green,
                                                                    fontSize: MediaQuery.of(context).size.width >
                                                                            1600
                                                                        ? 19
                                                                        : MediaQuery.of(context).size.shortestSide >
                                                                                570
                                                                            ? 13
                                                                            : 12)
                                                            : poppinsBold.copyWith(
                                                                fontSize: MediaQuery.of(context).size.width > 1600
                                                                    ? 19
                                                                    : MediaQuery.of(context).size.shortestSide > 570
                                                                        ? 13
                                                                        : 12,
                                                                color: ColorTheme.green),
                                                      ),
                                                  ]),
                                                );
                                              },
                                            ),
                                            SizedBox(
                                                height: index !=
                                                        product.variations!
                                                                .length -
                                                            1
                                                    ? Dimensions
                                                        .PADDING_SIZE_LARGE
                                                    : 0),
                                          ]);
                                    },
                                  )
                                : const SizedBox(),
                            SizedBox(
                                height: (product.variations != null &&
                                        product.variations!.isNotEmpty)
                                    ? Dimensions.PADDING_SIZE_LARGE
                                    : 0),

                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .foodLevelNotes ==
                                'Yes')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Notes:  ',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: 15)),
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    1600
                                                ? 50
                                                : MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 40
                                                    : 30,
                                        child: TextField(
                                          controller: foodNotes,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 0,
                                                horizontal: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 8
                                                    : Dimensions
                                                        .PADDING_SIZE_EXTRA_SMALL),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            hintStyle: poppinsRegular.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 21
                                                    : 15,
                                                color: ColorTheme.hintText),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          style: poppinsRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    1600
                                                ? 21
                                                : MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 15
                                                    : 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Quantity
                            Row(children: [
                              Text('quantity'.tr,
                                  style: poppinsSemiBold.copyWith(
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  1600
                                              ? 21
                                              : MediaQuery.of(context)
                                                          .size
                                                          .shortestSide >
                                                      570
                                                  ? 16
                                                  : 15)),
                              Expanded(child: SizedBox()),
                              Container(
                                width: 90,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: ColorTheme.borderGrey)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: QuantityButton(
                                          onTap: () {
                                            if (posController.quantity > 1) {
                                              posController
                                                  .setProductQuantity(false);
                                            }
                                          },
                                          isIncrement: false,
                                        ),
                                      ),
                                      Text(posController.quantity.toString(),
                                          style: poppinsMedium.copyWith(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1600
                                                  ? 24
                                                  : MediaQuery.of(context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 19
                                                      : 14)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: QuantityButton(
                                          onTap: () {
                                            if (product.variations != null) {
                                              for (int index = 0;
                                                  index <
                                                      product
                                                          .variations!.length;
                                                  index++) {
                                                for (int i = 0;
                                                    i <
                                                        product
                                                            .variations![index]
                                                            .values!
                                                            .length;
                                                    i++) {
                                                  if (posController
                                                          .selectedVariations[
                                                              index]
                                                          .isNotEmpty &&
                                                      posController
                                                              .selectedVariations[
                                                          index][i]) {
                                                    variationPrice +=
                                                        double.parse(product
                                                            .variations![index]
                                                            .values![i]
                                                            .optionPrice!);
                                                  }
                                                }
                                              }
                                            }
                                            if (_addOnsList.isEmpty) {
                                              posController
                                                  .setProductQuantity(true);
                                            }
                                          },
                                          isIncrement: true,
                                        ),
                                      ),
                                    ]),
                              ),
                            ]),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            // Addons
                            product.addOns != null && product.addOns!.length > 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        Text('Addon',
                                            style: poppinsSemiBold.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 21
                                                    : MediaQuery.of(context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 16
                                                        : 15)),
                                        SizedBox(
                                            height: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                        product.addOns!.length > 0
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                    Text('Addon',
                                                        style: poppinsSemiBold
                                                            .copyWith(
                                                                fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width >
                                                                        1600
                                                                    ? 21
                                                                    : MediaQuery.of(context).size.shortestSide >
                                                                            570
                                                                        ? 16
                                                                        : 15)),
                                                    SizedBox(
                                                        height: Dimensions
                                                            .PADDING_SIZE_EXTRA_SMALL),
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      padding: EdgeInsets.zero,
                                                      itemCount: product
                                                          .addOns!.length,
                                                      itemBuilder:
                                                          (context, i) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 10),
                                                          child: InkWell(
                                                            onTap: () {},
                                                            child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (posController.quantity ==
                                                                            1) {
                                                                          // if (!posController
                                                                          //     .addOnActiveList[i]) {
                                                                          posController.addAddOn(
                                                                              posController.addOnActiveList[i] ? false : true,
                                                                              i);
                                                                          if (posController.addOnActiveList[i] &&
                                                                              posController.addOnQtyList[i] == 0) {
                                                                            posController.setAddOnQuantity(true,
                                                                                i);
                                                                          }
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            36,
                                                                        width: Get.width *
                                                                            0.6,
                                                                        padding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                1,
                                                                            horizontal:
                                                                                10),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(7),
                                                                            border: Border.all(color: ColorTheme.borderGrey)),
                                                                        child: Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 20,
                                                                                child: Checkbox(
                                                                                  value: posController.addOnActiveList[i],
                                                                                  activeColor: ColorTheme.appColor,
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                                                                                  onChanged: (bool? newValue) {
                                                                                    if (posController.quantity == 1) {
                                                                                      posController.addAddOn(posController.addOnActiveList[i] ? false : true, i);
                                                                                      if (posController.addOnActiveList[i] && posController.addOnQtyList[i] == 0) {
                                                                                        posController.setAddOnQuantity(true, i);
                                                                                      }
                                                                                    }
                                                                                  },
                                                                                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 12),
                                                                              Expanded(
                                                                                child: Row(children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      product.addOns![i].name!,
                                                                                      style: poppinsMedium.copyWith(fontSize: 11, color: ColorTheme.hintText),
                                                                                      maxLines: 2,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                  if (Get.find<AuthController>().profileModel!.restaurants!.first.isComplementry != 'Yes') Text('  @Rs. ${product.addOns![i].price}', style: poppinsMedium.copyWith(fontSize: 11, color: ColorTheme.hintText))
                                                                                ]),
                                                                              ),
                                                                            ]),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  // const Spacer(),
                                                                  Container(
                                                                    width: 90,
                                                                    height: 36,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                7),
                                                                        border: Border.all(
                                                                            color:
                                                                                ColorTheme.borderGrey)),
                                                                    child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 8),
                                                                            child:
                                                                                QuantityButton(
                                                                              onTap: () {
                                                                                // if (posController.quantity > 1) {
                                                                                //   posController.setProductQuantity(false);
                                                                                // }
                                                                                if (posController.quantity == 1) {
                                                                                  if (posController.addOnQtyList[i] > 0) {
                                                                                    posController.setAddOnQuantity(false, i);
                                                                                    if (posController.addOnQtyList[i] == 0) {
                                                                                      posController.addAddOn(false, i);
                                                                                    }
                                                                                  } else {
                                                                                    posController.addAddOn(false, i);
                                                                                  }
                                                                                }
                                                                              },
                                                                              isIncrement: false,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                              posController.addOnQtyList[i].toString(),
                                                                              style: poppinsMedium.copyWith(fontSize: 14)),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 8),
                                                                            child:
                                                                                QuantityButton(
                                                                              onTap: () {
                                                                                if (posController.quantity == 1) {
                                                                                  if (posController.addOnQtyList[i] == 0) {
                                                                                    posController.addAddOn(true, i);
                                                                                  }
                                                                                  posController.setAddOnQuantity(true, i);
                                                                                }
                                                                              },
                                                                              isIncrement: true,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                ]),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    SizedBox(
                                                        height: Dimensions
                                                            .PADDING_SIZE_EXTRA_SMALL),
                                                  ])
                                            : SizedBox(),

                                        // GridView.builder(
                                        //   gridDelegate:
                                        //       SliverGridDelegateWithFixedCrossAxisCount(
                                        //     crossAxisCount: MediaQuery.of(context)
                                        //                 .size
                                        //                 .shortestSide >
                                        //             570
                                        //         ? 6
                                        //         : 4,
                                        //     crossAxisSpacing: 20,
                                        //     mainAxisSpacing: 10,
                                        //     childAspectRatio: (1 / 1.25),
                                        //   ),
                                        //   shrinkWrap: true,
                                        //   physics: NeverScrollableScrollPhysics(),
                                        //   itemCount: product.addOns.length,
                                        //   itemBuilder: (context, index) {
                                        //     return InkWell(
                                        //       onTap: () {
                                        //         if (posController.quantity == 1) {
                                        //           if (!posController
                                        //               .addOnActiveList[index]) {
                                        //             posController.addAddOn(
                                        //                 true, index);
                                        //           } else if (posController
                                        //                   .addOnQtyList[index] ==
                                        //               1) {
                                        //             posController.addAddOn(
                                        //                 false, index);
                                        //           }
                                        //         }
                                        //       },
                                        //       child: Container(
                                        //         alignment: Alignment.center,
                                        //         margin: EdgeInsets.only(
                                        //             bottom: posController
                                        //                     .addOnActiveList[index]
                                        //                 ? 2
                                        //                 : 20),
                                        //         decoration: BoxDecoration(
                                        //           color: posController
                                        //                   .addOnActiveList[index]
                                        //               ? Theme.of(context).primaryColor
                                        //               : Theme.of(context)
                                        //                   .backgroundColor,
                                        //           borderRadius: BorderRadius.circular(
                                        //               Dimensions.RADIUS_SMALL),
                                        //           border: posController
                                        //                   .addOnActiveList[index]
                                        //               ? null
                                        //               : Border.all(
                                        //                   color: Theme.of(context)
                                        //                       .disabledColor,
                                        //                   width: 2),
                                        //           boxShadow: posController
                                        //                   .addOnActiveList[index]
                                        //               ? [
                                        //                   BoxShadow(
                                        //                       color: Colors.grey[
                                        //                           Get.isDarkMode
                                        //                               ? 700
                                        //                               : 300],
                                        //                       blurRadius: 5,
                                        //                       spreadRadius: 1)
                                        //                 ]
                                        //               : null,
                                        //         ),
                                        //         child: Column(children: [
                                        //           Expanded(
                                        //             child: Column(
                                        //                 mainAxisAlignment:
                                        //                     MainAxisAlignment.center,
                                        //                 children: [
                                        //                   Text(
                                        //                     product
                                        //                         .addOns[index].name,
                                        //                     maxLines: 2,
                                        //                     overflow:
                                        //                         TextOverflow.ellipsis,
                                        //                     textAlign:
                                        //                         TextAlign.center,
                                        //                     style: poppinsMedium
                                        //                         .copyWith(
                                        //                       color: posController
                                        //                                   .addOnActiveList[
                                        //                               index]
                                        //                           ? Colors.white
                                        //                           : Colors.black,
                                        //                       fontSize: MediaQuery.of(
                                        //                                       context)
                                        //                                   .size
                                        //                                   .width >
                                        //                               1600
                                        //                           ? 21
                                        //                           : MediaQuery.of(context)
                                        //                                       .size
                                        //                                       .shortestSide >
                                        //                                   570
                                        //                               ? 15
                                        //                               : Dimensions
                                        //                                   .FONT_SIZE_SMALL,
                                        //                     ),
                                        //                   ),
                                        //                   SizedBox(height: 5),
                                        //                   Text(
                                        //                     PriceConverter
                                        //                         .convertPrice(product
                                        //                             .addOns[index]
                                        //                             .price),
                                        //                     maxLines: 1,
                                        //                     overflow:
                                        //                         TextOverflow.ellipsis,
                                        //                     style: poppinsRegular
                                        //                         .copyWith(
                                        //                       color: posController
                                        //                                   .addOnActiveList[
                                        //                               index]
                                        //                           ? Colors.white
                                        //                           : Colors.black,
                                        //                       fontSize: MediaQuery.of(
                                        //                                       context)
                                        //                                   .size
                                        //                                   .width >
                                        //                               1600
                                        //                           ? 19
                                        //                           : MediaQuery.of(context)
                                        //                                       .size
                                        //                                       .shortestSide >
                                        //                                   570
                                        //                               ? 15
                                        //                               : Dimensions
                                        //                                   .FONT_SIZE_EXTRA_SMALL,
                                        //                     ),
                                        //                   ),
                                        //                 ]),
                                        //           ),
                                        //           posController.addOnActiveList[index]
                                        //               ? Container(
                                        //                   height: 25,
                                        //                   decoration: BoxDecoration(
                                        //                       borderRadius: BorderRadius
                                        //                           .circular(Dimensions
                                        //                               .RADIUS_SMALL),
                                        //                       color: Theme.of(context)
                                        //                           .cardColor),
                                        //                   child: Row(
                                        //                       mainAxisAlignment:
                                        //                           MainAxisAlignment
                                        //                               .center,
                                        //                       children: [
                                        //                         Expanded(
                                        //                           child: InkWell(
                                        //                             onTap: () {
                                        //                               if (posController
                                        //                                           .addOnQtyList[
                                        //                                       index] >
                                        //                                   1) {
                                        //                                 posController
                                        //                                     .setAddOnQuantity(
                                        //                                         false,
                                        //                                         index);
                                        //                               } else {
                                        //                                 posController
                                        //                                     .addAddOn(
                                        //                                         false,
                                        //                                         index);
                                        //                               }
                                        //                             },
                                        //                             child: Center(
                                        //                                 child: Icon(
                                        //                                     Icons
                                        //                                         .remove,
                                        //                                     size:
                                        //                                         15)),
                                        //                           ),
                                        //                         ),
                                        //                         Text(
                                        //                           posController
                                        //                               .addOnQtyList[
                                        //                                   index]
                                        //                               .toString(),
                                        //                           style: poppinsMedium
                                        //                               .copyWith(
                                        //                                   fontSize: MediaQuery.of(context).size.width >
                                        //                                           1600
                                        //                                       ? 20
                                        //                                       : MediaQuery.of(context).size.shortestSide >
                                        //                                               570
                                        //                                           ? 15
                                        //                                           : Dimensions.FONT_SIZE_SMALL),
                                        //                         ),
                                        //                         Expanded(
                                        //                           child: InkWell(
                                        //                             onTap: () =>
                                        //                                 posController
                                        //                                     .setAddOnQuantity(
                                        //                                         true,
                                        //                                         index),
                                        //                             child: Center(
                                        //                                 child: Icon(
                                        //                                     Icons.add,
                                        //                                     size:
                                        //                                         15)),
                                        //                           ),
                                        //                         ),
                                        //                       ]),
                                        //                 )
                                        //               : SizedBox(),
                                        //         ]),
                                        //       ),
                                        //     );
                                        //   },
                                        // ),

                                        SizedBox(
                                            height: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                      ])
                                : SizedBox(),

                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .isComplementry !=
                                'Yes')
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${'total_amount'.tr}:',
                                        style: poppinsSemiBold.copyWith(
                                            color: ColorTheme.appColor,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    1600
                                                ? 21
                                                : MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 16
                                                    : 15)),
                                    Text(
                                        'Rs. ' +
                                            PriceConverter.convertPrice(
                                                priceWithAddonsVariation +
                                                    (orderType == 'take_away'
                                                        ? (product
                                                                .takeAwayFoodPrice! *
                                                            posController
                                                                .quantity)
                                                        : orderType ==
                                                                'delivery'
                                                            ? (product
                                                                    .deliveryFoodPrice! *
                                                                posController
                                                                    .quantity)
                                                            : 0),
                                                isHideCurrency: true),
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    1600
                                                ? 21
                                                : MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 16
                                                    : 14,
                                            color: ColorTheme.appColor)),
                                    if (product.price == 1) Spacer(),
                                    if (product.price == 1)
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Price: ',
                                              style: poppinsSemiBold.copyWith(
                                                  fontSize: 15)),
                                          const SizedBox(
                                              height: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    1600
                                                ? 50
                                                : MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 40
                                                    : 30,
                                            width: Get.width * 0.15,
                                            child: TextField(
                                              controller: adjustPriceController,
                                              autofocus: false,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              onChanged: (v) {
                                                posController.update();
                                              },
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 8
                                                        : Dimensions
                                                            .PADDING_SIZE_EXTRA_SMALL),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .RADIUS_SMALL),
                                                  borderSide: BorderSide(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .RADIUS_SMALL),
                                                  borderSide: BorderSide(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                ),
                                                disabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .RADIUS_SMALL),
                                                  borderSide: BorderSide(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .RADIUS_SMALL),
                                                  borderSide: BorderSide(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                ),
                                                hintStyle:
                                                    poppinsSemiBold.copyWith(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                1600
                                                            ? 21
                                                            : MediaQuery.of(context)
                                                                        .size
                                                                        .shortestSide >
                                                                    570
                                                                ? 15
                                                                : 15,
                                                        color: ColorTheme
                                                            .hintText),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              style: poppinsSemiBold.copyWith(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1600
                                                    ? 21
                                                    : MediaQuery.of(context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ]),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            //Add to cart Button

                            CustomButton(
                              color: ColorTheme.appColor,
                              height: 40,
                              width: ResponsiveHelper.isDesktop(context)
                                  ? size.width / 2.0
                                  : null,
                              buttonText: isCampaign
                                  ? 'order_now'.tr
                                  : fromCart
                                      ? 'update'.tr
                                      : 'add'.tr,
                              onPressed: () async {
                                //   if (product.variations != null) {
                                //     for (int index = 0;
                                //         index < product.variations.length;
                                //         index++) {
                                //       if (product.variations[index].type !=
                                //               'multi' &&
                                //           product.variations[index].required ==
                                //               'on' &&
                                //           !posController
                                //               .selectedVariations[index]
                                //               .contains(true)) {
                                //         showCustomSnackBar(
                                //             '${'Choose a variation from'.tr} ${product.variations[index].name}',
                                //             isCart: true);
                                //         return;
                                //       } else if (product.variations[index].type ==
                                //               'multi' &&
                                //           (product.variations[index].required ==
                                //                   'on' ||
                                //               posController
                                //                   .selectedVariations[index]
                                //                   .contains(true)) &&
                                //           int.parse(product.variations[index].min) >
                                //               posController
                                //                   .selectedVariationLength(
                                //                       posController
                                //                           .selectedVariations,
                                //                       index)) {
                                //         showCustomSnackBar(
                                //             '${'You need to select minimum'.tr} ${product.variations[index].min} '
                                //             '${'to maximum'.tr} ${product.variations[index].max} ${'options from'.tr} ${product.variations[index].name} ${'variation'.tr}',
                                //             isCart: true);
                                //         return;
                                //       }
                                //     }
                                //   }
                                //   product.price = adjustPriceController
                                //               .text.isEmpty ||
                                //           adjustPriceController.text == '1'
                                //       ? product.price
                                //       : double.parse(
                                //           adjustPriceController.text);
                                //   CartModel _cartModel = CartModel(
                                //                                               foodNote: foodNotes?.text ?? '',

                                //       adjustPrice: adjustPriceController
                                //               .text.isEmpty
                                //           ? 1
                                //           : double.parse(
                                //               adjustPriceController.text),
                                //       price: priceWithVariation,
                                //       discountedPrice: priceWithDiscount,
                                //       discountAmount: (price -
                                //           PriceConverter
                                //               .convertWithDiscount(
                                //                   price,
                                //                   _discount,
                                //                   _discountType)),
                                //       quantity: posController.quantity,
                                //       addOnIds: _addOnIdList,
                                //       addOns: _addOnsList,
                                //       isCampaign: false,
                                //       product: product,
                                //       variation:
                                //           posController.selectedVariations);
                                //   Get.back();
                                //   if (isCampaign) {
                                //   } else {
                                //     Get.find<EditWalkInOrderController>()
                                //         .addToCart(_cartModel, cartIndex);
                                //   }
                                isTapButton = true;
                                // onIncrease(true);
                                Get.find<EditWalkInOrderController>().update();
                                if (product.variations != null) {
                                  for (int index = 0;
                                      index < product.variations!.length;
                                      index++) {
                                    if (product.variations![index].type !=
                                            'multi' &&
                                        product.variations![index].required ==
                                            'on' &&
                                        !posController.selectedVariations[index]
                                            .contains(true)) {
                                      // showCustomSnackBar(
                                      //     '${'Choose a variation from'.tr} ${product.variations[index].name}',
                                      //     isCart: true);
                                      return;
                                    } else if (product
                                                .variations![index].type ==
                                            'multi' &&
                                        (product.variations![index].required ==
                                                'on' ||
                                            posController
                                                .selectedVariations[index]
                                                .contains(true)) &&
                                        int.parse(product.variations![index].min!) >
                                            posController
                                                .selectedVariationLength(
                                                    posController
                                                        .selectedVariations,
                                                    index)) {
                                      // showCustomSnackBar(
                                      //     '${'You need to select minimum'.tr} ${product.variations[index].min} '
                                      //     '${'to maximum'.tr} ${product.variations[index].max} ${'options from'.tr} ${product.variations[index].name} ${'variation'.tr}',
                                      //     isCart: true);
                                      return;
                                    }
                                  }
                                }
                                Product? updateProduct;
                                if (product.name!
                                        .toLowerCase()
                                        .contains('out of') &&
                                    product.price == 1 &&
                                    updateFoodName.text.isNotEmpty &&
                                    adjustPriceController.text.isNotEmpty) {
                                  updateProduct =
                                      await Get.find<RestaurantController>()
                                          .addProduct(
                                              name: updateFoodName.text,
                                              price: adjustPriceController.text,
                                              foodFor: product.foodFor,
                                              categoryId: product.categoryId
                                                  .toString());
                                }
                                CartModel _cartModel = CartModel(
                                    // updateFoodName: updateFoodName?.text ?? '',
                                    foodNote: foodNotes.text ?? '',
                                    adjustPrice:
                                        adjustPriceController.text.isEmpty
                                            ? 1
                                            : double.parse(
                                                adjustPriceController.text),
                                    price: updateProduct == null
                                        ? priceWithVariation
                                        : updateProduct.price!,
                                    discountedPrice: priceWithDiscount,
                                    // discountAmount: (price -
                                    //     PriceConverter.convertWithDiscount(
                                    //         price, _discount, _discountType)),
                                    quantity: posController.quantity.toDouble(),
                                    addOnIds: _addOnIdList,
                                    addOns: _addOnsList,
                                    // isCampaign: false,
                                    product: updateProduct ?? product,
                                    variation: posController.selectedVariations
                                    //     widget.isCampaign,
                                    //     widget.product,
                                    //     productController.selectedVariations,
                                    );
                                Get.back();

                                Get.find<EditWalkInOrderController>()
                                    .addToCart(_cartModel, cartIndex);
                                // print(Get.find<CartController>()
                                //     .cartList[0]
                                //     .product
                                //     .);
                                // if (fromCart) {
                                //   showCustomSnackBar('item_updated'.tr,
                                //       isError: false);
                                // }
                              },
                            ),
                          ]),
                    ),
                  ]),
            );
          }),
        ),
      ),
    );
  }
}
