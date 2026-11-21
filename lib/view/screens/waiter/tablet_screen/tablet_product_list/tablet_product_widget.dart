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

import '../../../../../controller/auth_controller.dart';

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
    final String foodLevelNotes = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.first
            .foodLevelNotes ??
        '';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name!,
                  style: poppinsSemiBold.copyWith(fontSize: 17),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    (Get.find<TableController>().selectedTable == null ||
                            Get.find<TableController>()
                                    .selectedTable!
                                    .tableNo ==
                                'Select Table')
                        ? '₹ ${product.price}'
                        : Get.find<TableController>().selectedTable!.tableNo ==
                                'Take Away'
                            ? '₹ ${product.price! + product.takeAwayFoodPrice!}'
                            : Get.find<TableController>()
                                        .selectedTable!
                                        .tableNo ==
                                    'Delivery'
                                ? '₹ ${product.price! + product.deliveryFoodPrice!}'
                                : '₹ ${product.price!}',
                    style: poppinsBold.copyWith(
                        fontSize: 14, color: ColorTheme.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          GetBuilder<CartController>(
              id: 'qty',
              builder: (cart) {
                final qty = cart.getProductQty(product.id!);

                return Column(
                  children: [
                    qty != 0 && product.price != 1
                        ? Stack(
                            children: [
                              Container(
                                height: 100,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Container(
                                  width: 120,
                                  // height: 30,
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
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: QuantityButton(
                                            onTap: () {},
                                            isIncrement: false,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        // '$qty',
                                         qty % 1 == 0
                                              ? qty.toInt().toString()
                                              : qty.toString(),
                                          style: poppinsMedium.copyWith(
                                              color: Colors.black,
                                              fontSize: 16)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
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
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      cart.decreaseProductQty(product.id!);
                                      Get.find<RestaurantController>().update();
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 80,
                                      // color: Colors.transparent,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      cart.onAddProduct(product);
                                      swapToTop(index);
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
                          )
                        : InkWell(
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              searchController.clear();

                              cart.onAddProduct(product);
                              swapToTop(index);
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
