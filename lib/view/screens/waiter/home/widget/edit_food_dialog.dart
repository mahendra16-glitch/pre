import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controller/auth_controller.dart';
import '../../../../../controller/cart_controller.dart';
import '../../../../../data/model/response/cart_model.dart';
import '../../../../../data/model/response/get_waiter_order_list_response.dart';
import '../../../../../helper/price_converter.dart';

class EditFoodOrderDialog extends StatelessWidget {
  final String orderId;
  final String foodId;
  final String foodName;
  final List<Variations> variation;
  final List<AddOns> addons;
  final String variationText;
  final String addonText;
  final Product product;
  final OrderList order;

  EditFoodOrderDialog({
    Key? key,
    required this.orderId,
    required this.foodId,
    required this.foodName,
    required this.variationText,
    required this.addonText,
    required this.variation,
    required this.addons,
    required this.product,
    required this.order,
  }) : super(key: key);

  final TextEditingController cancelReason = TextEditingController();
  int selectedQty = 1;
  String selectedDiscountType = 'Percent';
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            top: false,
            child: GetBuilder<CartController>(builder: (posController) {
              CartModel cart = posController.cartList.first;

              String addOnText = '';
              double addonsTotal = 0;
              double halfVariationPrice = 0;
              double variationTotal = 0;
              int index0 = 0;
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

              if (cart.variation.isNotEmpty) {
                for (int index = 0; index < cart.variation.length; index++) {
                  if (cart.variation[index].isNotEmpty &&
                      cart.variation[index].contains(true)) {
                    variationText +=
                        '${variationText.isNotEmpty ? ', ' : ''}${cart.product.variations![index].name} (';

                    for (int i = 0; i < cart.variation[index].length; i++) {
                      if (cart.variation[index][i]) {
                        if (cart.product.variations![index].name!
                                .toUpperCase() ==
                            'HALFNHALF') {
                          if (halfVariationPrice <
                              double.parse(cart.product.variations![index]
                                  .values![i].optionPrice!)) {
                            halfVariationPrice = double.parse(cart.product
                                .variations![index].values![i].optionPrice!);
                          }
                        } else {
                          variationTotal += double.parse(cart.product
                              .variations![index].values![i].optionPrice!);
                        }
                        variationText +=
                            '${variationText.endsWith('(') ? '' : ', '}${cart.product.variations![index].values![i].level}';
                      }
                    }
                    variationText += ')';
                    variationTotal = variationTotal + halfVariationPrice;
                  }
                }
              }
              return SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Add Qty',
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
                      child: Divider(color: ColorTheme.borderGrey)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .foodWithVariance ==
                                'Yes')
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${foodName ?? ''}',
                                      style: poppinsMedium.copyWith(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: variationText == ''
                                          ? ''
                                          : ' ($variationText)',
                                      style: poppinsMedium.copyWith(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 11,
                                        color: ColorTheme.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .foodWithVariance !=
                                'Yes')
                              Text(
                                '${foodName ?? ''}',
                                style: poppinsSemiBold.copyWith(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            addOnText == ''
                                ? SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Add-Ons :',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 11,
                                                color:
                                                    ColorTheme.kdsLeftMenuBlue),
                                          ),
                                          TextSpan(
                                            text: ' $addOnText',
                                            style: poppinsMedium.copyWith(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 11,
                                              color: ColorTheme.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            if (Get.find<AuthController>()
                                    .profileModel!
                                    .restaurants!
                                    .first
                                    .foodWithVariance !=
                                'Yes')
                              variationText == ''
                                  ? SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Variants  :',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 11,
                                                  color: ColorTheme.blue),
                                            ),
                                            TextSpan(
                                              text: ' $variationText',
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 11,
                                                  color: ColorTheme.green),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
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
                                    if (posController.cartList.first.quantity >
                                        1) {
                                      Get.find<CartController>().setQuantity(
                                          false, posController.cartList.first);
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
                                  style: poppinsMedium.copyWith(
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  1600
                                              ? 24
                                              : MediaQuery.of(context)
                                                          .size
                                                          .shortestSide >
                                                      570
                                                  ? 19
                                                  : 14)),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: QuantityButton(
                                  onTap: () {
                                    if (addOnText == '') {
                                      Get.find<CartController>().setQuantity(
                                          true, posController.cartList.first);
                                    }
                                  },
                                  isIncrement: true,
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${'Total Amount'}:',
                              style: poppinsSemiBold.copyWith(
                                  color: ColorTheme.appColor,
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1600
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
                                      posController.subTotal,
                                      isHideCurrency: true),
                              style: poppinsSemiBold.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1600
                                          ? 21
                                          : MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 16
                                              : 14,
                                  color: ColorTheme.appColor)),
                        ]),
                  ),
                  posController.isLoading
                      ? CircularProgressIndicator()
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () async {
                              print(
                                '${(posController.subTotal) + double.parse(order.orderAmount!)}',
                              );
                              // Get.find<CartController>().placeOrder(
                              //     0,
                              //     null,
                              //     (order.user?.phone ?? ''),
                              //     (order.userName ?? ''),
                              //     (order.user?.dob ?? ''),
                              //     (order.user?.anniversary ?? ''),
                              //     (order.user?.userRestaurant?.membershipId ??
                              //         ''),
                              //     '',
                              //     (posController.subTotal) +
                              //         double.parse(order.orderAmount!),
                              //     'pos', (bool isSuccess, String message,
                              //         String orderID) {
                              //   if (isSuccess) {
                              //     if (Get.isBottomSheetOpen ?? false)
                              //       Get.back();

                              //     showErrorToast(message, isError: false);
                              //   } else {
                              //     if (Get.isBottomSheetOpen ?? false)
                              //       Get.back();

                              //     showErrorToast(message);
                              //   }
                              // },
                              //     isUpdate: true,
                              //     addressId: '',
                              //     audioFile: '',
                              //     isPrintKot: order.isPrintKot == 'Yes',
                              //     orderId: orderId);

                              placeOrderCallFunction(Get.find<PosController>());
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 25),
                              height: 35,
                              width: 110,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.transparent),
                                  color: ColorTheme.appColor,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(
                                  'Submit',
                                  style: poppinsMedium.copyWith(
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  1600
                                              ? 18
                                              : 14,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          )),
                ]),
              );
            }),
          ),
        ));
  }

  double coummunityDiscount = 0;
  double coummunityDiscountPercentage = 0;
  double gstAmount = 0;
  double gstTaxPercentage = 0;
  double orderDiscount = 0;
  double showServiceChargeValue = 0;
  double serviceChargePercentage = 0;
  double orderItemTotal = 0;
  double orderSubTotal = 0;
  // double tipTaxAmount = 0;
  double gstServiceChargeTax = 0;
  double discountedOrderSubTotal = 0;
  double vatAmount = 0;
  List<Map<String, dynamic>> jsonCartList = [];

  discountCalculator() {
    orderItemTotal = 0;
    orderSubTotal = 0;
    gstServiceChargeTax = 0;
    discountedOrderSubTotal = 0;
    orderDiscount = 0;
    gstAmount = 0;
    vatAmount = 0;
    showServiceChargeValue = 0;
    jsonCartList = [];
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;

    for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
      CartModel cart = Get.find<CartController>().cartList[i];

      double variationTotal = 0;
      double addonsTotal = 0;
      double foodAmount = 0;
      double apiFoodAmount = 0;
      double complementFoodTotal = 0;
      double halfVariationPrice = 0;
      double foodGstAmount = 0;
      double foodVatAmount = 0;
      double discountFood = 0;
      // List<int> ids = [];
      // List<int> qtys = [];
      // int index0 = 0;

      for (var addOn in cart.addOnIds) {
        if (addOn.quantity != 0) {
          addonsTotal = addonsTotal +
              (((addOn.price ?? 0) * addOn.quantity) * cart.quantity);
          // index0 = index0 + 1;
        }
      }
      if (cart.variation.isNotEmpty) {
        for (int index = 0; index < cart.variation.length; index++) {
          if (cart.variation[index].isNotEmpty &&
              cart.variation[index].contains(true)) {
            for (int i = 0; i < cart.variation[index].length; i++) {
              if (cart.variation[index][i]) {
                final variations = cart.product.variations;
                if (variations != null &&
                    index < variations.length &&
                    variations[index].values != null &&
                    i < variations[index].values!.length) {
                  if ((variations[index].name ?? '').toUpperCase() ==
                      'HALFNHALF') {
                    final optionPrice =
                        variations[index].values![i].optionPrice ?? '0';
                    if (halfVariationPrice <
                        double.parse(optionPrice) * cart.quantity) {
                      halfVariationPrice =
                          double.parse(optionPrice) * cart.quantity;
                    }
                  } else {
                    final optionPrice =
                        variations[index].values![i].optionPrice ?? '0';
                    variationTotal += double.parse(optionPrice) * cart.quantity;
                  }
                }
              }
            }
            variationTotal = variationTotal + halfVariationPrice;
          }
        }
      }
      if (order.orderType == 'dinein' ||
          order.orderType == 'WalkIn' ||
          order.orderType == 'pos') {
        orderItemTotal = twoDecimal(orderItemTotal +
            (cart.isComplementry
                ? 0
                : ((cart.product.price == 1
                            ? cart.discountedPrice
                            : cart.product.price)! *
                        cart.quantity +
                    variationTotal +
                    addonsTotal)));
        foodAmount = twoDecimal(cart.isComplementry
            ? 0
            : ((cart.product.price == 1
                        ? cart.discountedPrice
                        : cart.product.price)! *
                    cart.quantity +
                variationTotal +
                addonsTotal));
        apiFoodAmount = twoDecimal(cart.isComplementry
            ? 0
            : ((cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity));
        if (cart.isComplementry)
          complementFoodTotal = twoDecimal(((cart.product.price == 1
                  ? cart.discountedPrice
                  : cart.product.price)! *
              cart.quantity));
      } else if (order.orderType == 'take_away') {
        orderItemTotal = twoDecimal(orderItemTotal +
            (cart.isComplementry
                ? 0
                : ((cart.product.price == 1
                            ? cart.discountedPrice
                            : (cart.product.price! +
                                cart.product.takeAwayFoodPrice!)) *
                        cart.quantity +
                    variationTotal +
                    addonsTotal)));
        foodAmount = twoDecimal(cart.isComplementry
            ? 0
            : ((cart.product.price == 1
                        ? cart.discountedPrice
                        : (cart.product.price! +
                            cart.product.takeAwayFoodPrice!)) *
                    cart.quantity +
                variationTotal +
                addonsTotal));
        apiFoodAmount = twoDecimal(cart.isComplementry
            ? 0
            : ((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.takeAwayFoodPrice!)) *
                cart.quantity));
        if (cart.isComplementry)
          complementFoodTotal = twoDecimal(((cart.product.price == 1
                  ? cart.discountedPrice
                  : (cart.product.price! + cart.product.takeAwayFoodPrice!)) *
              cart.quantity));
      } else if (order.orderType == 'delivery') {
        orderItemTotal = twoDecimal(orderItemTotal +
            (cart.isComplementry
                ? 0
                : ((cart.product.price == 1
                            ? cart.discountedPrice
                            : (cart.product.price! +
                                cart.product.deliveryFoodPrice!)) *
                        cart.quantity +
                    variationTotal +
                    addonsTotal)));
        foodAmount = twoDecimal(cart.isComplementry
            ? 0
            : ((cart.product.price == 1
                        ? cart.discountedPrice
                        : (cart.product.price! +
                            cart.product.deliveryFoodPrice!)) *
                    cart.quantity +
                variationTotal +
                addonsTotal));
        apiFoodAmount = twoDecimal(cart.isComplementry
            ? 0
            : ((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.deliveryFoodPrice!)) *
                cart.quantity));
        if (cart.isComplementry)
          complementFoodTotal = twoDecimal(((cart.product.price == 1
                  ? cart.discountedPrice
                  : (cart.product.price! + cart.product.deliveryFoodPrice!)) *
              cart.quantity));
      } else {
        if (!cart.isComplementry)
          orderItemTotal = twoDecimal(orderItemTotal +
              (cart.product.price == 1
                      ? cart.discountedPrice
                      : cart.product.price)! *
                  cart.quantity +
              variationTotal +
              addonsTotal);
        if (!cart.isComplementry)
          foodAmount = twoDecimal((cart.product.price == 1
                  ? cart.discountedPrice
                  : (cart.product.price)! * cart.quantity) +
              variationTotal +
              addonsTotal);
        if (!cart.isComplementry)
          apiFoodAmount = twoDecimal((cart.product.price == 1
                  ? cart.discountedPrice
                  : cart.product.price)! *
              cart.quantity);
        if (cart.isComplementry) {
          complementFoodTotal = twoDecimal((cart.product.price == 1
                  ? cart.discountedPrice
                  : cart.product.price)! *
              cart.quantity);
        }
      }

      if (selectedDiscountType == 'Percent' || selectedDiscountType == 'No') {
        double tempDiscountPercent = 0;
        // double tempDiscountPercent = selectedDiscountType == 'No'
        //     ? 0
        //     : _discountController.text.isEmpty
        //         ? 0
        //         : double.parse(_discountController.text);
        double tempAmount = 0;
        if (cart.product.giveDiscount.toString() == 'Yes') {
          tempAmount = twoDecimal(foodAmount -
              (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100));
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

          orderDiscount = twoDecimal(orderDiscount +
              (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100));
          // couponDiscount = twoDecimal(
          //     couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
          discountFood = twoDecimal((foodAmount *
              (coummunityDiscountPercentage + tempDiscountPercent) /
              100));
        } else {
          tempAmount = twoDecimal(foodAmount);
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
        }
        if (cart.product.taxType.toString() == 'GST') {
          if (restaurant.gstStatus == 'true') {
            //   gstAmount = gstAmount +
            //       ((tempAmount * double.parse(cart.product.tax.toString())) /
            //           100);
            // }
            if (order.serviceCharge != 0) {
              gstAmount = twoDecimal(gstAmount +
                  (((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100));
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
              foodGstAmount = twoDecimal(
                  (((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100));
            } else {
              gstAmount = twoDecimal(gstAmount +
                  ((tempAmount * double.parse(cart.product.tax.toString())) /
                      100));
              foodGstAmount = twoDecimal(
                  (tempAmount * double.parse(cart.product.tax.toString())) /
                      100);
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        } else if (cart.product.taxType.toString() == 'VAT') {
          if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
              'true') {
            // vatAmount = vatAmount +
            //     ((tempAmount * double.parse(cart.product.tax.toString())) /
            //         100);

            if (order.serviceCharge != 0) {
              vatAmount = twoDecimal(vatAmount +
                  (((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100));
              foodVatAmount = twoDecimal(
                  (((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100));
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            } else {
              vatAmount = twoDecimal(vatAmount +
                  ((tempAmount * double.parse(cart.product.tax.toString())) /
                      100));
              foodVatAmount = twoDecimal(
                  (tempAmount * double.parse(cart.product.tax.toString())) /
                      100);
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        }
        var jsonData = {
          // "food_id": cart.product.id,
          // "quantity": cart.quantity,
          "food_amount": cart.isComplementry ? 0 : apiFoodAmount,
          "variation_amount": cart.isComplementry ? 0 : variationTotal,
          "addon_amount": cart.isComplementry ? 0 : addonsTotal,
          "gst_amount":
              cart.isComplementry ? 0 : foodGstAmount.toStringAsFixed(2),
          "vat_amount":
              cart.isComplementry ? 0 : foodVatAmount.toStringAsFixed(2),
          "discount_amount":
              cart.isComplementry ? 0 : discountFood.toStringAsFixed(2),
          'complementary_price':
              complementFoodTotal + addonsTotal + variationTotal,
          'is_complementary': cart.isComplementry == true ? 'Yes' : 'No',

          // "service_charge": foodServiceCharge.toStringAsFixed(2),
        };
        jsonCartList.add(jsonData);
      }
      // else {
      //   if (cart.product.taxType.toString() == 'GST') {
      //     gstTypeFood = gstTypeFood + foodAmount;
      //   } else if (cart.product.taxType.toString() == 'VAT') {
      //     vatTypeFood = vatTypeFood + foodAmount;
      //   }
      // }
    }

    if (selectedDiscountType == 'Fixed') {
      for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
        CartModel cart = Get.find<CartController>().cartList[i];

        double variationTotal = 0;
        double addonsTotal = 0;
        double foodAmount = 0;
        double apiFoodAmount = 0;
        double halfVariationPrice = 0;
        double foodGstAmount = 0;
        double foodVatAmount = 0;
        double discountFood = 0;
        double complementFoodTotal = 0;
        // double foodServiceCharge = 0;
        for (var addOn in cart.addOnIds) {
          if (addOn.quantity != 0) {
            addonsTotal = addonsTotal +
                (((addOn.price ?? 0) * addOn.quantity) * cart.quantity);
            // index0 = index0 + 1;
          }
        }
        // if (cart.product.addOns != null) {
        //   for (var addOn in cart.product.addOns!) {
        //     if (ids.contains(addOn.id)) {
        //       addonsTotal = addonsTotal + ((addOn.price ?? 0) * qtys[index0]);
        //       index0 = index0 + 1;
        //     }
        //   }
        // }
        if (cart.variation.isNotEmpty) {
          for (int index = 0; index < cart.variation.length; index++) {
            if (cart.variation[index].isNotEmpty &&
                cart.variation[index].contains(true)) {
              for (int i = 0; i < cart.variation[index].length; i++) {
                if (cart.variation[index][i]) {
                  final variations = cart.product.variations;
                  if (variations != null &&
                      index < variations.length &&
                      variations[index].values != null &&
                      i < variations[index].values!.length) {
                    if ((variations[index].name ?? '').toUpperCase() ==
                        'HALFNHALF') {
                      final optionPrice =
                          variations[index].values![i].optionPrice ?? '0';
                      if (halfVariationPrice <
                          double.parse(optionPrice) * cart.quantity) {
                        halfVariationPrice =
                            double.parse(optionPrice) * cart.quantity;
                      }
                    } else {
                      final optionPrice =
                          variations[index].values![i].optionPrice ?? '0';
                      variationTotal +=
                          double.parse(optionPrice) * cart.quantity;
                    }
                  }
                }
              }
              variationTotal = variationTotal + halfVariationPrice;
            }
          }
        }
        if (order.orderType == 'dinein' ||
            order.orderType == 'WalkIn' ||
            order.orderType == 'pos') {
          if (!cart.isComplementry) {
            foodAmount = twoDecimal((cart.product.price == 1
                        ? cart.discountedPrice
                        : cart.product.price)! *
                    cart.quantity +
                variationTotal +
                addonsTotal);
            apiFoodAmount = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity);
          }
          if (cart.isComplementry) {
            complementFoodTotal = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity);
          }
        } else if (order.orderType == 'take_away') {
          // orderSubTotal = orderSubTotal +
          //     (cart.product.price == 1
          //             ? cart.discountedPrice
          //             : (cart.product.price! +
          //                 cart.product.takeAwayFoodPrice!)) *
          //         cart.quantity +
          //     variationTotal +
          //     addonsTotal;

          if (!cart.isComplementry) {
            foodAmount = twoDecimal((cart.product.price == 1
                        ? cart.discountedPrice
                        : (cart.product.price! +
                            cart.product.takeAwayFoodPrice!)) *
                    cart.quantity +
                variationTotal +
                addonsTotal);
            apiFoodAmount = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.takeAwayFoodPrice!)) *
                cart.quantity);
          }
          if (cart.isComplementry) {
            complementFoodTotal = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.takeAwayFoodPrice!)) *
                cart.quantity);
          }
        } else if (order.orderType == 'delivery') {
          // orderSubTotal = orderSubTotal +
          //     (cart.product.price == 1
          //             ? cart.discountedPrice
          //             : (cart.product.price! +
          //                 cart.product.deliveryFoodPrice!)) *
          //         cart.quantity +
          //     variationTotal +
          //     addonsTotal;
          if (!cart.isComplementry) {
            foodAmount = twoDecimal((cart.product.price == 1
                        ? cart.discountedPrice
                        : (cart.product.price! +
                            cart.product.deliveryFoodPrice!)) *
                    cart.quantity +
                variationTotal +
                addonsTotal);
            apiFoodAmount = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.deliveryFoodPrice!)) *
                cart.quantity);
          }
          if (cart.isComplementry) {
            complementFoodTotal = twoDecimal((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.deliveryFoodPrice!)) *
                cart.quantity);
          }
        } else {
          // orderSubTotal = orderSubTotal +
          //     (cart.product.price == 1
          //             ? cart.discountedPrice
          //             : cart.product.price)! *
          //         cart.quantity +
          //     variationTotal +
          //     addonsTotal;
          if (!cart.isComplementry) {
            foodAmount = twoDecimal((cart.product.price == 1
                        ? cart.discountedPrice
                        : cart.product.price)! *
                    cart.quantity +
                variationTotal +
                addonsTotal);
            apiFoodAmount = twoDecimal((cart.product.price == 1
                ? cart.discountedPrice
                : (cart.product.price)! * cart.quantity));
          }
          if (cart.isComplementry) {
            complementFoodTotal = twoDecimal((cart.product.price == 1
                ? cart.discountedPrice
                : (cart.product.price)! * cart.quantity));
          }
        }

        double tempDiscountPercent = 0;
        // double tempDiscountPercent = _discountController.text.isEmpty
        //     ? 0
        //     : double.parse(
        //         ((double.parse(_discountController.text) / orderItemTotal) *
        //                 100)
        //             .toStringAsFixed(2));
        double tempAmount = 0;
        if (cart.product.giveDiscount.toString() == 'Yes') {
          tempAmount = twoDecimal(foodAmount -
              (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100));
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

          orderDiscount = 0;
          // orderDiscount =_discountController.text.isEmpty?0: twoDecimal(double.parse(_discountController.text));
          // couponDiscount = twoDecimal(
          //     couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
          discountFood = twoDecimal((foodAmount *
              (coummunityDiscountPercentage + tempDiscountPercent) /
              100));
        } else {
          tempAmount = twoDecimal(foodAmount);
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
        }
        if (cart.product.taxType.toString() == 'GST') {
          if (restaurant.gstStatus == 'true') {
            //   gstAmount = gstAmount +
            //       ((tempAmount * double.parse(cart.product.tax.toString())) /
            //           100);
            // }
            if (order.serviceCharge != 0) {
              gstAmount = twoDecimal(gstAmount +
                  (((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100));
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
              foodGstAmount = twoDecimal(
                  ((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100);
            } else {
              gstAmount = twoDecimal(gstAmount +
                  ((tempAmount * double.parse(cart.product.tax.toString())) /
                      100));
              foodGstAmount = twoDecimal(
                  (tempAmount * double.parse(cart.product.tax.toString())) /
                      100);
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        } else if (cart.product.taxType.toString() == 'VAT') {
          if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
              'true') {
            // vatAmount = vatAmount +
            //     ((tempAmount * double.parse(cart.product.tax.toString())) /
            //         100);

            if (order.serviceCharge != 0) {
              vatAmount = twoDecimal(vatAmount +
                  (((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100));
              foodVatAmount = twoDecimal(
                  ((tempAmount) * double.parse(cart.product.tax.toString())) /
                      100);
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            } else {
              vatAmount = twoDecimal(vatAmount +
                  ((tempAmount * double.parse(cart.product.tax.toString())) /
                      100));
              foodVatAmount = twoDecimal(
                  (tempAmount * double.parse(cart.product.tax.toString())) /
                      100);
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        }

        // else {
        //   if (cart.product.taxType.toString() == 'GST') {
        //     gstTypeFood = gstTypeFood + foodAmount;
        //   } else if (cart.product.taxType.toString() == 'VAT') {
        //     vatTypeFood = vatTypeFood + foodAmount;
        //   }
        // }
        var jsonData = {
          // "food_id": cart.product.id,
          // "quantity": cart.quantity,
          "food_amount": cart.isComplementry ? 0 : apiFoodAmount,
          "addon_amount": cart.isComplementry ? 0 : addonsTotal,
          "variation_amount": cart.isComplementry ? 0 : variationTotal,
          "gst_amount":
              cart.isComplementry ? 0 : foodGstAmount.toStringAsFixed(2),
          "vat_amount":
              cart.isComplementry ? 0 : foodVatAmount.toStringAsFixed(2),
          "discount_amount":
              cart.isComplementry ? 0 : discountFood.toStringAsFixed(2),
          'is_complementary': cart.isComplementry == true ? 'Yes' : 'No',
          'complementary_price': complementFoodTotal +
              addonsTotal +
              variationTotal // "service_charge": foodServiceCharge.toStringAsFixed(2),
        };
        jsonCartList.add(jsonData);
      }
    }

    if (discountedOrderSubTotal >= 0) {
      // if (_addTips.text.isNotEmpty) {
      //   tipTaxAmount = twoDecimal(
      //       (double.parse(_addTips.text) * restaurant.tipTaxPercent!) / 100);
      // }

      if (order.serviceCharge != 0) {
        gstServiceChargeTax = twoDecimal(
            (showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
                100);
      }
      // if (order.deliveryCharge != 0 && restaurant.settings!.gstDeliveryCharge != 0)
      //   gstAmount = twoDecimal(gstAmount +
      //       ((order.deliveryCharge! * restaurant.settings!.gstDeliveryCharge!) /
      //           100));

      double addOrderAmount = discountedOrderSubTotal +
          showServiceChargeValue +
          gstAmount +
          vatAmount +
          gstServiceChargeTax;

      //// wallet used
      double tempWalletUsed = 0;
      double payable = twoDecimal(addOrderAmount);

      // Round to 2 decimals if you'd like
      payable = double.parse(payable.toStringAsFixed(2));
      // walletUsed = double.parse(tempWalletUsed.toStringAsFixed(2));

      // Get.find<PosController>().setcollectItemPrice(
      //     twoDecimal(payable)); // existing method you already call
      editAmountCalculation();
    } else {
      showErrorToast('Please enter valid discount');
    }
  }

  editAmountCalculation() {
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;

    for (var i = 0; i < order.orderDetails!.length; i++) {
      OrderDetails food = order.orderDetails![i];

      double variationTotal = 0;
      double addonsTotal = 0;
      double foodAmount = 0;
      double halfVariationPrice = 0;

      if (food.variation != null && food.variation!.isNotEmpty) {
        for (int j = 0; j < food.variation!.length; j++) {
          final variation = food.variation![j];
          if (variation.values != null) {
            for (var element in variation.values!) {
              if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
                if (halfVariationPrice <
                    double.parse(element.optionPrice ?? '0') *
                        (food.quantity ?? 0)) {
                  halfVariationPrice =
                      double.parse(element.optionPrice ?? '0') *
                          (food.quantity ?? 0);
                }
              } else {
                variationTotal = variationTotal +
                    double.parse(element.optionPrice ?? '0') *
                        (food.quantity ?? 0);
              }
            }
          }
          variationTotal = variationTotal + halfVariationPrice;
        }
      }

      if (food.addOns != null) {
        for (var i = 0; i < food.addOns!.length; i++) {
          final addOn = food.addOns![i];
          addonsTotal = addonsTotal +
              (((addOn.price ?? 0) * (addOn.qty ?? 0)) * (food.quantity ?? 0));
        }
      }
      if (food.foodDetails!.name.toString().toLowerCase() != 'check in' &&
          food.foodStatus != 3) {
        orderItemTotal = twoDecimal(orderItemTotal +
            (food.unitPrice ?? 0) * (food.quantity ?? 0) +
            variationTotal +
            addonsTotal);
        foodAmount = twoDecimal((food.unitPrice ?? 0) * (food.quantity ?? 0) +
            variationTotal +
            addonsTotal);
      }

      if (selectedDiscountType == 'Percent' || selectedDiscountType == 'No') {
        double tempDiscountPercent = 0;
        // double tempDiscountPercent = selectedDiscountType == 'No'
        //     ? 0
        //     : _discountController.text.isEmpty
        //         ? 0
        //         : double.parse(_discountController.text);
        double tempAmount = 0;
        if (food.foodDetails!.giveDiscount.toString() == 'Yes') {
          tempAmount = twoDecimal(foodAmount -
              (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100));
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

          orderDiscount = twoDecimal(orderDiscount +
              (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100));
          // couponDiscount = twoDecimal(
          //     couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
        } else {
          tempAmount = twoDecimal(foodAmount);
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
        }
        if (food.foodDetails!.taxType.toString() == 'GST') {
          if (restaurant.gstStatus == 'true') {
            //   gstAmount = gstAmount +
            //       ((tempAmount * double.parse(cart.product.tax.toString())) /
            //           100);
            // }
            if (order.serviceCharge != 0) {
              gstAmount = twoDecimal(gstAmount +
                  (((tempAmount) *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            } else {
              gstAmount = twoDecimal(gstAmount +
                  ((tempAmount *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        } else if (food.foodDetails!.taxType.toString() == 'VAT') {
          if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
              'true') {
            // vatAmount = vatAmount +
            //     ((tempAmount * double.parse(cart.product.tax.toString())) /
            //         100);

            if (order.serviceCharge != 0) {
              vatAmount = twoDecimal(vatAmount +
                  (((tempAmount) *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            } else {
              vatAmount = twoDecimal(vatAmount +
                  ((tempAmount *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        }
      }
      // else {
      //   if (cart.product.taxType.toString() == 'GST') {
      //     gstTypeFood = gstTypeFood + foodAmount;
      //   } else if (cart.product.taxType.toString() == 'VAT') {
      //     vatTypeFood = vatTypeFood + foodAmount;
      //   }
      // }
    }

    if (selectedDiscountType == 'Fixed') {
      for (var i = 0; i < order.orderDetails!.length; i++) {
        OrderDetails food = order.orderDetails![i];

        double variationTotal = 0;
        double addonsTotal = 0;
        double foodAmount = 0;
        double halfVariationPrice = 0;

        if (food.variation != null && food.variation!.isNotEmpty) {
          for (int j = 0; j < food.variation!.length; j++) {
            final variation = food.variation![j];
            if (variation.values != null) {
              for (var element in variation.values!) {
                if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
                  if (halfVariationPrice <
                      double.parse(element.optionPrice ?? '0') *
                          (food.quantity ?? 0)) {
                    halfVariationPrice =
                        double.parse(element.optionPrice ?? '0') *
                            (food.quantity ?? 0);
                  }
                } else {
                  variationTotal = variationTotal +
                      double.parse(element.optionPrice ?? '0') *
                          (food.quantity ?? 0);
                }
              }
            }
            variationTotal = variationTotal + halfVariationPrice;
          }
        }

        if (food.addOns != null) {
          for (var i = 0; i < food.addOns!.length; i++) {
            final addOn = food.addOns![i];
            addonsTotal = addonsTotal +
                (((addOn.price ?? 0) * (addOn.qty ?? 0)) *
                    (food.quantity ?? 0));
          }
        }
        if (food.foodDetails!.name.toString().toLowerCase() != 'check in' &&
            food.foodStatus != 3) {
          // orderItemTotal = twoDecimal(orderItemTotal +
          //     (food.unitPrice ?? 0) * (food.quantity ?? 0) +
          //     variationTotal +
          //     addonsTotal);
          foodAmount = twoDecimal((food.unitPrice ?? 0) * (food.quantity ?? 0) +
              variationTotal +
              addonsTotal);
        }

        double tempDiscountPercent = 0;
        // double tempDiscountPercent =
        // _discountController.text.isEmpty
        //     ? 0
        //     : double.parse(
        //         ((double.parse(_discountController.text) / orderItemTotal) *
        //                 100)
        //             .toStringAsFixed(2));
        double tempAmount = 0;
        if (food.foodDetails!.giveDiscount.toString() == 'Yes') {
          tempAmount = twoDecimal(foodAmount -
              (foodAmount *
                  (coummunityDiscountPercentage + tempDiscountPercent) /
                  100));
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

          orderDiscount = 0;
          // orderDiscount =_discountController.text.isEmpty?0: twoDecimal(double.parse(_discountController.text));
          // couponDiscount = twoDecimal(
          //     couponDiscount + (foodAmount * (tempDiscountPercent) / 100));
        } else {
          tempAmount = twoDecimal(foodAmount);
          orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
        }
        if (food.foodDetails!.taxType.toString() == 'GST') {
          if (restaurant.gstStatus == 'true') {
            //   gstAmount = gstAmount +
            //       ((tempAmount * double.parse(cart.product.tax.toString())) /
            //           100);
            // }
            if (order.serviceCharge != 0) {
              gstAmount = twoDecimal(gstAmount +
                  (((tempAmount) *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            } else {
              gstAmount = twoDecimal(gstAmount +
                  ((tempAmount *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        } else if (food.foodDetails!.taxType.toString() == 'VAT') {
          if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
              'true') {
            // vatAmount = vatAmount +
            //     ((tempAmount * double.parse(cart.product.tax.toString())) /
            //         100);

            if (order.serviceCharge != 0) {
              vatAmount = twoDecimal(vatAmount +
                  (((tempAmount) *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));

              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            } else {
              vatAmount = twoDecimal(vatAmount +
                  ((tempAmount *
                          double.parse(food.foodDetails!.tax.toString())) /
                      100));
            }
          } else {
            if (order.serviceCharge != 0) {
              showServiceChargeValue = twoDecimal(showServiceChargeValue +
                  ((tempAmount * serviceChargePercentage) / 100));
            }
          }
          discountedOrderSubTotal =
              twoDecimal(discountedOrderSubTotal + tempAmount);
        }
      }
    }

    if (discountedOrderSubTotal >= 0) {
      // if (_addTips.text.isNotEmpty) {
      //   tipTaxAmount = twoDecimal(
      //     (tipTaxAmount+  (double.parse(_addTips.text) * restaurant.tipTaxPercent!) / 100));
      // }

      if (order.serviceCharge != 0) {
        gstServiceChargeTax = twoDecimal((gstServiceChargeTax +
            (showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
                100));
      }
      if (order.deliveryCharge != 0 &&
          restaurant.settings!.gstDeliveryCharge != 0)
        gstAmount = twoDecimal(gstAmount +
            ((order.deliveryCharge! * restaurant.settings!.gstDeliveryCharge!) /
                100));

      double addOrderAmount = discountedOrderSubTotal +
          showServiceChargeValue +
          gstAmount +
          vatAmount +
          gstServiceChargeTax +
          (order.tipTaxAmount ?? 0) +
          (order.tipAmount ?? 0) +
          order.deliveryCharge!;

      //// wallet used
      double tempWalletUsed = 0;
      double payable = twoDecimal(addOrderAmount);

      if (Get.find<CartController>().isApplyWallet) {
        // get wallet balance from controller (null-safe)
        // double tempWalletBalance = walletBalance;

        // if (tempWalletBalance >= payable) {
        //   // wallet covers whole amount
        //   tempWalletUsed = payable;
        //   payable = 0;
        // } else {
        //   // wallet covers partial
        //   tempWalletUsed = tempWalletBalance;
        //   payable = payable - tempWalletBalance;
        // }
        if (payable < 0) payable = 0;
      }

      // Round to 2 decimals if you'd like
      payable = double.parse(payable.toStringAsFixed(2));
      // walletUsed = double.parse(tempWalletUsed.toStringAsFixed(2));

      Get.find<PosController>().setcollectItemPrice(
          twoDecimal(payable)); // existing method you already call
    } else {
      showErrorToast('Please enter valid discount');
    }
  }

  placeOrderCallFunction(PosController posController) async {
    await discountCalculator();

    double orderPay = posController.collectItemPrice;

    Map<String, dynamic> jsonbody = {
      'order_id': order.id.toString(),
      "user_id": '${order.userId ?? ''}',

      //  if (selectedDateTime != null)
      //   "schedule_at":
      //       DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime!),
      // if (selectedDateTime != null) "scheduled": 1,
      "payment_method": 'pending',
      "order_sub_total_without_tax": orderSubTotal +
          (order.deliveryCharge ?? 0) +
          showServiceChargeValue +
          (order.tipAmount ?? 0),

      "paid_room": Get.find<PosController>().paymentTab.toLowerCase() == 'room'
          ? 'Yes'
          : '',
      "payment_status": 'unpaid', // "sucess", //paid, unpaid
      "tip_tax_amount": (order.tipTaxAmount ?? 0),
      "service_gst_tax_amount": gstServiceChargeTax,
      "cust_email": "",
      "payment_type": 'postpaid',
      "discount_type":
          Get.find<CartController>().isApplyLoyalty ? 'Loyality' : '',
      "order_note": order.orderNote ?? '',

      'delivery_charge': '${(order.deliveryCharge ?? 0)}',
      'use_wallet_balance': 0,

      "tax_amount": gstAmount +
          vatAmount +
          gstServiceChargeTax +
          (order.tipTaxAmount ?? 0),
      'order_sub_total_amount': orderItemTotal,
      'order_amount': Get.find<AuthController>()
                  .profileModel
                  ?.restaurants
                  ?.first
                  .isTotalRound ==
              'Yes'
          ? getRoundUpValue(value: orderPay)
          : orderPay.toStringAsFixed(2),
      'vat_tax': vatAmount,
      'gst_tax': gstAmount + (order.tipTaxAmount ?? 0) + gstServiceChargeTax,

      // 'address_id': Get.find<TableController>().selectedTable?.id == 0 &&
      //         Get.find<TableController>().selectedTable?.tableNo == 'Delivery'
      //     ? selectedAddress!.id.toString()
      //     : '',
      'print_kot': order.isPrintKot,

      'self_discount': 0,
      'coupon_discount': 0,
      'coupon_title': '',
      'coupon_type': '',
      'round_up': getRoundUpAmount(orderPay),

      'order_type': order.orderType,
      // "table_id":order.tableId,
      'tip_amount': (order.tipAmount ?? 0),
      'order_discount': orderDiscount,
      'used_loyalty_point': 0,
      // 'cust_mobile': _phoneController.text.isEmpty ? '' : _phoneController.text,
      'cust_name': order.userName,
      // 'cust_dob': _dobController.text.isEmpty ? '' : _dobController.text,
      // 'cust_anniversary': _anniversaryController.text.isEmpty
      //     ? ''
      //     : _anniversaryController.text,
      // 'cust_membership_id': _selectedDropdownOption ?? '',
      'service_tax': Get.find<PosController>().isAddServiceCharge
          ? showServiceChargeValue
          : 0,
      'room_id': '',
      'auto_dispatch': Get.find<AuthController>()
              .profileModel!
              .restaurants
              ?.first
              .settings
              ?.autoDispatch ??
          'No',
      'discount_member_category_id': '',
      'discount_member_category_name': '',
      "usage_id": "",
    };
    await Get.find<CartController>().newPlaceOrder(
        (bool isSuccess, String message, String orderID, String dailyToken) {
      if (isSuccess) {
        if (Get.isBottomSheetOpen ?? false) Get.back();

        showErrorToast(message, isError: false);
      } else {
        if (Get.isBottomSheetOpen ?? false) Get.back();

        showErrorToast(message);
      }
    }, jsonBody: jsonbody, jsonFoodList: jsonCartList, isUpdate: true);
  }
}
