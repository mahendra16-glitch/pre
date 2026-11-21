// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
// import 'package:mygenie_restaurant/controller/splash_controller.dart';
// import 'package:mygenie_restaurant/data/model/response/config_model.dart';
// import 'package:mygenie_restaurant/data/model/response/product_model.dart';
// import 'package:mygenie_restaurant/helper/date_converter.dart';
// import 'package:mygenie_restaurant/helper/price_converter.dart';
// import 'package:mygenie_restaurant/helper/responsive_helper.dart';
// import 'package:mygenie_restaurant/helper/route_helper.dart';
// import 'package:mygenie_restaurant/util/dimensions.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
// import 'package:mygenie_restaurant/view/base/custom_image.dart';
// import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
// import 'package:mygenie_restaurant/view/base/discount_tag.dart';
// import 'package:mygenie_restaurant/view/base/not_available_widget.dart';
// import 'package:mygenie_restaurant/view/base/rating_bar.dart';
// import 'package:mygenie_restaurant/view/screens/pos/widget/product_bottom_sheet.dart';
// import 'package:mygenie_restaurant/view/screens/restaurant/product_details_screen.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ProductWidget extends StatelessWidget {
//   final Product product;
//   final int index;
//   final int length;
//   final bool inRestaurant;
//   final bool isCampaign;
//   final bool isPOS;

//   ProductWidget(
//       {@required this.product,
//       @required this.index,
//       @required this.length,
//       this.inRestaurant = false,
//       this.isCampaign = false,
//       this.isPOS = false});

//   @override
//   Widget build(BuildContext context) {
//     // BaseUrls _baseUrls = Get.find<SplashController>().configModel.baseUrls;
//     bool _desktop = ResponsiveHelper.isDesktop(context);
//     double _discount;
//     String _discountType;
//     bool _isAvailable;
//     _discount = (product.restaurantDiscount == 0 || isCampaign)
//         ? product.discount
//         : product.restaurantDiscount;
//     _discountType = (product.restaurantDiscount == 0 || isCampaign)
//         ? product.discountType
//         : 'percent';
//     _isAvailable = DateConverter.isAvailable(
//             product.availableTimeStarts, product.availableTimeEnds) &&
//         DateConverter.isAvailable(
//             product.restaurantOpeningTime, product.restaurantClosingTime);

//     return InkWell(
//       onTap: () {
//         // Get.toNamed(RouteHelper.getProductDetailsRoute(product),
//         //     arguments: ProductDetailsScreen(product: product));
//       },
//       child: Container(
//         padding: ResponsiveHelper.isDesktop(context)
//             ? EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL)
//             : null,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
//           color: ResponsiveHelper.isDesktop(context)
//               ? Theme.of(context).cardColor
//               : null,
//           boxShadow: ResponsiveHelper.isDesktop(context)
//               ? [
//                   BoxShadow(
//                     color: Colors.grey[Get.isDarkMode ? 700 : 300],
//                     spreadRadius: 1,
//                     blurRadius: 5,
//                   )
//                 ]
//               : null,
//         ),
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Expanded(
//               child: Padding(
//             padding: EdgeInsets.symmetric(
//                 vertical: _desktop ? 0 : Dimensions.PADDING_SIZE_EXTRA_SMALL),
//             child: Row(children: [
//               // (product.image != null && product.image.isNotEmpty)
//               //     ? Stack(children: [
//               //         ClipRRect(
//               //           borderRadius:
//               //               BorderRadius.circular(Dimensions.RADIUS_SMALL),
//               //           child: CustomImage(
//               //             image:
//               //                 '${isCampaign ? _baseUrls.campaignImageUrl : _baseUrls.productImageUrl}/${product.image}',
//               //             height: _desktop ? 120 : 65,
//               //             width: _desktop ? 120 : 80,
//               //             fit: BoxFit.cover,
//               //           ),
//               //         ),
//               //         DiscountTag(
//               //           discount: _discount,
//               //           discountType: _discountType,
//               //           freeDelivery: false,
//               //         ),
//               //         _isAvailable
//               //             ? SizedBox()
//               //             : NotAvailableWidget(isRestaurant: false),
//               //       ])
//               //     : SizedBox(),
//               SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
//               Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         product.name,
//                         style: poppinsMedium.copyWith(
//                             fontSize: Dimensions.FONT_SIZE_SMALL),
//                         maxLines: _desktop ? 2 : 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                       RatingBar(
//                         rating: product.avgRating,
//                         size: _desktop ? 15 : 12,
//                         ratingCount: product.ratingCount,
//                       ),
//                       Row(children: [
//                         Text(
//                           PriceConverter.convertPrice(product.price,
//                               discount: _discount, discountType: _discountType),
//                           style: poppinsMedium.copyWith(
//                               fontSize: Dimensions.FONT_SIZE_SMALL),
//                         ),
//                         SizedBox(
//                             width: _discount > 0
//                                 ? Dimensions.PADDING_SIZE_EXTRA_SMALL
//                                 : 0),
//                         _discount > 0
//                             ? Text(
//                                 PriceConverter.convertPrice(product.price),
//                                 style: poppinsMedium.copyWith(
//                                   fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
//                                   color: Theme.of(context).disabledColor,
//                                   decoration: TextDecoration.lineThrough,
//                                 ),
//                               )
//                             : SizedBox(),
//                         (product.image != null && product.image.isNotEmpty)
//                             ? SizedBox()
//                             : Text(
//                                 '(${_discount > 0 ? '$_discount${_discountType == 'percent' ? '%' : Get.find<SplashController>().configModel.currencySymbol}${'off'.tr}' : 'free_delivery'.tr})',
//                                 style: poppinsMedium.copyWith(
//                                     color: Theme.of(context).primaryColor,
//                                     fontSize: ResponsiveHelper.isMobile(context)
//                                         ? 8
//                                         : 12),
//                                 textAlign: TextAlign.center,
//                               ),
//                       ]),
//                     ]),
//               ),
//               isPOS
//                   ? const SizedBox.shrink()
//                   : IconButton(
//                       onPressed: () {
//                         if (Get.find<AuthController>()
//                             .profileModel
//                             .restaurants[0]
//                             .foodSection) {
//                           Get.toNamed(RouteHelper.getProductRoute(product));
//                         } else {
//                           showErrorToast('this_feature_is_blocked_by_admin'.tr);
//                         }
//                       },
//                       icon: Icon(Icons.edit, color: Colors.blue),
//                     ),
//               IconButton(
//                 onPressed: () {
//                   if (isPOS) {
//                     Get.bottomSheet(
//                       ProductBottomSheet(
//                           product: product, isCampaign: isCampaign),
//                       backgroundColor: Colors.transparent,
//                       isScrollControlled: true,
//                     );
//                   } else {
//                     if (Get.find<AuthController>()
//                         .profileModel
//                         .restaurants[0]
//                         .foodSection) {
//                       Get.dialog(
//                           ConfirmationDialog(
//                             icon: Images.warning,
//                             description:
//                                 'are_you_sure_want_to_delete_this_product'.tr,
//                             onYesPressed: () => Get.find<RestaurantController>()
//                                 .deleteProduct(product.id),
//                           ),
//                           barrierDismissible: true);
//                     } else {
//                       showErrorToast('this_feature_is_blocked_by_admin'.tr);
//                     }
//                   }
//                 },
//                 icon: Icon(
//                     isPOS ? CupertinoIcons.add_circled : Icons.delete_forever,
//                     color: isPOS ? Colors.blue : Colors.red),
//               ),
//             ]),
//           )),
//           _desktop
//               ? SizedBox()
//               : Padding(
//                   padding: EdgeInsets.only(left: _desktop ? 130 : 90),
//                   child: Divider(
//                       color: index == length - 1
//                           ? Colors.transparent
//                           : Theme.of(context).disabledColor),
//                 ),
//         ]),
//       ),
//     );
//   }
// }
