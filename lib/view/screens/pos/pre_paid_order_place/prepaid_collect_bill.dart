import 'dart:async';
import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_customer_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/search_customer_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/beep.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/util/windows_byte_convert.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/product_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../controller/table_controller.dart';
import '../../../../data/model/response/get_room_list_respone.dart';
import '../../../../data/model/response/product_model.dart';
import '../../../../data/model/response/tap_managment_reesponse_model.dart';
import '../../../../helper/route_helper.dart';

class PrePaidCollectBill extends StatefulWidget {
  final String? orderNote;
  final String? phoneNumber;
  final String? name;
  final bool isAutoKot;
  final double deliveryCharge;
  final String? addressId;

  const PrePaidCollectBill({
    Key? key,
    this.orderNote,
    this.phoneNumber,
    this.name,
    this.addressId,
    this.isAutoKot = false,
    this.deliveryCharge = 0,
  }) : super(key: key);

  @override
  State<PrePaidCollectBill> createState() => _PrePaidCollectBillState();
}

class _PrePaidCollectBillState extends State<PrePaidCollectBill> {
  double foodTotal = 0;
  bool showPlayer = false;
  bool isAutoBillPrint = false;
  String? audioPath;
  StreamSubscription<BTStatus>? _singlePrintBtStatus;

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _addTips = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController changeController = TextEditingController();
  final TextEditingController _transactionNoController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double variationTotal = 0;
  double discountedOrderSubTotal = 0;
  double vatAmount = 0;
  String selectedDiscountType = 'Fixed';
  List<String> discountType = ['No', 'Percent', 'Fixed'];

  bool isPrint = true;
  bool isConnect = true;
  int currentPrintIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController addNameController = TextEditingController();
  DiscountCategoryListModel? selectedDiscount;

  double latitude = 0;
  double longitude = 0;
  double deliveryCharge = 0;
  PrinterManager individualPrinter = PrinterManager.instance;
  List<int>? pendingTask;
  double coummunityDiscount = 0;
  double coummunityDiscountPercentage = 0;
  double gstAmount = 0;
  double gstTaxPercentage = 0;
  double orderDiscount = 0;
  double showServiceChargeValue = 0;
  double serviceChargePercentage = 0;
  double orderSubTotal = 0;

  String orderId = '';
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // if (Get.find<AuthController>().profileModel.restaurants.first.printKot ==
      //     'Yes') {
      //   if (mounted)
      //     setState(() {
      //       isPrintKot = true; // Example: Set the initial state
      //     });
      // }

      if (widget.name != '') _nameController.text = widget.name ?? '';
      if (widget.phoneNumber != '')
        _phoneController.text = widget.phoneNumber ?? '';

      Get.find<CartController>().calculationCart();
      Get.find<PosController>().setPaymentTabIndex(0);
      Get.find<PosController>().setcollectItemPrice(0);
      Get.find<PosController>().setRoomIndex(null);

      selectedDiscountType = Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .discountType!;
      isAutoBillPrint = Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .isAutoBillPrintBilling ==
          'Yes';

      await Get.find<CartController>().getCustomerFromApi(isLoading: true);
      await Get.find<PosController>().getRoomList();
      double orderAmount = Get.find<CartController>().calculationCart();
      Get.find<PosController>().changeServeiceChargeValue(
          Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .serviceCharge ==
                      'Yes' &&
                  Get.find<AuthController>()
                          .profileModel!
                          .restaurants!
                          .first
                          .autoServiceCharge ==
                      'Yes'
              ? true
              : false);
      serviceChargePercentage = Get.find<AuthController>()
          .profileModel!
          .restaurants!
          .first
          .serviceChargePercentage!;
      discountCalculator();
      await Get.find<PosController>().getTapManageMentCustomerList();

      Get.find<PosController>().setcollectItemPrice(
          orderAmount + gstAmount + showServiceChargeValue);
      individualListenBluetooth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // toolbarHeight: Get.height / 10.72,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: ColorTheme.green,
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: MediaQuery.of(context).size.shortestSide > 570
            ? Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.2,
              )
            : Image.asset(
                logoHelper.appLogo!,
                width: Get.width * 0.25,
              ),
      ),
      body: SafeArea(
        child: GetBuilder<PosController>(builder: (posController) {
          return GetBuilder<CartController>(
            builder: (cartController) {
              return cartController.cartList.length > 0
                  ? SingleChildScrollView(
                      controller: _scrollController,
                      reverse: true,
                      physics: BouncingScrollPhysics(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Collect Payment',
                                    style:
                                        poppinsSemiBold.copyWith(fontSize: 15),
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        Get.bottomSheet(editUserBottomSheet(),
                                            backgroundColor: Colors.transparent,
                                            isScrollControlled: true,
                                            ignoreSafeArea: false);
                                      },
                                      child: Icon(Icons.manage_accounts,
                                          color: ColorTheme.appColor, size: 30))
                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                child: Divider(color: ColorTheme.borderGrey)),

                            // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                            // Product
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: ColorTheme.productCard,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.RADIUS_LARGE),
                                ),
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cartController.cartList.length,
                                  itemBuilder: (context, index) {
                                    return productWidget(
                                      onIncrease: (data) {
                                        if (data != null && data) {
                                          Future.delayed(
                                              Duration(microseconds: 300), () {
                                            discountCalculator();
                                          });
                                        }
                                      },
                                      cart: cartController.cartList[index],
                                      cartIndex: index,
                                      addOns: cartController.addOnsList[index],
                                      isAvailable:
                                          cartController.availableList[index],
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding: EdgeInsets.only(left: 20, top: 15),
                            //   child: Text('Customer Details',
                            //       style: poppinsMedium.copyWith(
                            //           fontSize: 13,
                            //           color: ColorTheme.hintText)),
                            // ),
                            customerDetail(cartController),

                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            showPaymentDetail(),
                            posController.isLoading
                                ? CircularProgressIndicator()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15, left: 20, right: 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();

                                              if (posController
                                                      .selectedPaymentTab ==
                                                  3) {
                                                if (_phoneController
                                                    .text.isEmpty) {
                                                  showErrorToast(
                                                      'Please enter phone number ');
                                                } else if (_phoneController
                                                        .text.isNotEmpty &&
                                                    _phoneController
                                                            .text.length <
                                                        10) {
                                                  showErrorToast(
                                                      'Minimum required 10 digit phone number');
                                                } else {
                                                  if (discountedOrderSubTotal >=
                                                      0) {
                                                    // payTabBills();
                                                    payNormalBill(
                                                        posController);
                                                  } else {
                                                    showErrorToast(
                                                        'Please enter valid discount');
                                                  }
                                                }
                                              } else {
                                                if (_phoneController
                                                        .text.isNotEmpty &&
                                                    _phoneController
                                                            .text.length <
                                                        10) {
                                                  showErrorToast(
                                                      'Minimum required 10 digit phone number');
                                                } else {
                                                  if (discountedOrderSubTotal >=
                                                      0) {
                                                    if (posController
                                                            .selectedPaymentTab ==
                                                        4) {
                                                      if (posController
                                                              .selectedRoom!
                                                              .table!
                                                              .id ==
                                                          0) {
                                                        showErrorToast(
                                                            'Please select room');
                                                      } else {
                                                        payNormalBill(
                                                            posController);
                                                      }
                                                    } else {
                                                      payNormalBill(
                                                          posController);
                                                    }
                                                  } else {
                                                    showErrorToast(
                                                        'Please enter valid discount');
                                                  }
                                                }
                                              }
                                            },
                                            child: Container(
                                              height: 30,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .PADDING_SIZE_DEFAULT,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: ColorTheme.appColor,
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Center(
                                                child: Text(
                                                  'Place & Collect Bill',
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: 13,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Container(
                                              height: 30,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .PADDING_SIZE_DEFAULT,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: ColorTheme.appColor,
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Center(
                                                child: Text(
                                                  'Place Order',
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: 13,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ),
                          ]),
                    )
                  : Center(child: Text('no_food_available'.tr));
            },
          );
        }),
      ),
    );
  }

  void discountCalculator() {
    orderSubTotal = 0;
    double discountableItemTotal = 0;
    discountedOrderSubTotal = 0;
    orderDiscount = 0;
    gstAmount = 0;
    vatAmount = 0;
    showServiceChargeValue = 0;
    double gstTypeFood = 0;
    double vatTypeFood = 0;
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    if (selectedDiscountType == 'Percent' &&
        _discountController.text.isNotEmpty &&
        double.parse(_discountController.text) > 100) {
      showErrorToast('Please enter valid discount');
    } else {
      for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
        CartModel cart = Get.find<CartController>().cartList[i];

        double variationTotal = 0;
        double addonsTotal = 0;
        double foodAmount = 0;
        double halfVariationPrice = 0;

        List<int> ids = [];
        List<int> qtys = [];
        int index0 = 0;
        for (var addOn in cart.addOnIds) {
          ids.add(addOn.id);
          qtys.add(addOn.quantity);
        }
        if (cart.product.addOns != null) {
          for (var addOn in cart.product.addOns!) {
            if (ids.contains(addOn.id)) {
              addonsTotal = addonsTotal + ((addOn.price ?? 0) * qtys[index0]);
              index0 = index0 + 1;
            }
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
                      variationTotal +=
                          double.parse(optionPrice) * cart.quantity;
                    }

                    // final optionPrice =
                    //     variations[index].values![i].optionPrice ?? '0';
                    // variationTotal +=
                    //     (double.parse(optionPrice) * (cart.quantity ?? 0));
                  }
                }
              }
              variationTotal = variationTotal + halfVariationPrice;
            }
          }
        }
        orderSubTotal = orderSubTotal +
            (cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity +
            variationTotal +
            addonsTotal;
        foodAmount = (cart.product.price == 1
                    ? cart.discountedPrice
                    : cart.product.price)! *
                cart.quantity +
            variationTotal +
            addonsTotal;
        if (cart.product.giveDiscount.toString() == 'Yes') {
          discountableItemTotal = discountableItemTotal + foodAmount;
        }
        if (selectedDiscountType == 'Percent') {
          double tempDiscountPercent = _discountController.text.isEmpty
              ? 0
              : double.parse(_discountController.text);
          double tempAmount = 0;
          if (cart.product.giveDiscount.toString() == 'Yes') {
            tempAmount = foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100);
            orderDiscount = orderDiscount +
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100);
          } else {
            tempAmount = foodAmount;
          }
          if (cart.product.taxType.toString() == 'GST') {
            if (restaurant.gstStatus == 'true') {
              //   gstAmount = gstAmount +
              //       ((tempAmount * double.parse(cart.product.tax.toString())) /
              //           100);
              // }
              if (Get.find<PosController>().isAddServiceCharge) {
                gstAmount = gstAmount +
                    (((tempAmount +
                                ((tempAmount * serviceChargePercentage) /
                                    100)) *
                            double.parse(cart.product.tax.toString())) /
                        100);
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
              } else {
                gstAmount = gstAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge)
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
            }
            discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
          } else if (cart.product.taxType.toString() == 'VAT') {
            if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
                'true') {
              // vatAmount = vatAmount +
              //     ((tempAmount * double.parse(cart.product.tax.toString())) /
              //         100);

              if (Get.find<PosController>().isAddServiceCharge) {
                vatAmount = vatAmount +
                    (((tempAmount +
                                ((tempAmount * serviceChargePercentage) /
                                    100)) *
                            double.parse(cart.product.tax.toString())) /
                        100);
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
              } else {
                vatAmount = vatAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge)
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
            }
            discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
          }
        } else {
          if (cart.product.taxType.toString() == 'GST') {
            gstTypeFood = gstTypeFood + foodAmount;
          } else if (cart.product.taxType.toString() == 'VAT') {
            vatTypeFood = vatTypeFood + foodAmount;
          }
        }
      }
// //////////////////   Calculate GST and VAT and Discount if discount type is fixed or no
      if (selectedDiscountType == 'No') {
        double tempFoodAmount = 0;
        double tempBarAmount = 0;
        tempBarAmount = vatTypeFood;
        tempFoodAmount = gstTypeFood;
        discountedOrderSubTotal = tempBarAmount + tempFoodAmount;
        if (restaurant.gstStatus == 'true') {
          if (Get.find<PosController>().isAddServiceCharge) {
            gstAmount = gstAmount +
                (((tempFoodAmount +
                            ((tempFoodAmount * serviceChargePercentage) /
                                100)) *
                        (restaurant.gstTax ?? 0)) /
                    100);
            showServiceChargeValue = showServiceChargeValue +
                ((tempFoodAmount * serviceChargePercentage) / 100);
          } else {
            gstAmount = gstAmount +
                (((tempFoodAmount) * (restaurant.gstTax ?? 0)) / 100);
          }
        } else {
          if (Get.find<PosController>().isAddServiceCharge)
            showServiceChargeValue = showServiceChargeValue +
                ((tempFoodAmount * serviceChargePercentage) / 100);
        }

        if (Get.find<AuthController>().profileModel?.vatInfo?.status ==
            'true') {
          if (Get.find<PosController>().isAddServiceCharge) {
            vatAmount = vatAmount +
                (((tempBarAmount +
                            ((tempBarAmount * serviceChargePercentage) / 100)) *
                        (restaurant.tax ?? 0)) /
                    100);
            showServiceChargeValue = showServiceChargeValue +
                ((tempBarAmount * serviceChargePercentage) / 100);
          } else {
            vatAmount =
                vatAmount + (((tempBarAmount) * (restaurant.tax ?? 0)) / 100);
          }
        } else {
          if (Get.find<PosController>().isAddServiceCharge)
            showServiceChargeValue = showServiceChargeValue +
                ((tempBarAmount * serviceChargePercentage) / 100);
        }
      } else if (selectedDiscountType == 'Fixed') {
        // Calculate discount percentage from fixed amount
        double enteredDiscount = _discountController.text.isEmpty
            ? 0
            : double.parse(_discountController.text);
        if (enteredDiscount > discountableItemTotal) {
          enteredDiscount = discountableItemTotal;
        }
        double tempDiscountPercent = _discountController.text.isEmpty ||
                discountableItemTotal == 0
            ? 0
            : double.parse(
                ((enteredDiscount / discountableItemTotal) * 100)
                    .toStringAsFixed(2));

        // Loop through each cart item to check giveDiscount individually
        for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
          CartModel cart = Get.find<CartController>().cartList[i];

          double variationTotal = 0;
          double addonsTotal = 0;
          double foodAmount = 0;
          double halfVariationPrice = 0;

          List<int> ids = [];
          List<int> qtys = [];
          int index0 = 0;
          for (var addOn in cart.addOnIds) {
            ids.add(addOn.id);
            qtys.add(addOn.quantity);
          }
          if (cart.product.addOns != null) {
            for (var addOn in cart.product.addOns!) {
              if (ids.contains(addOn.id)) {
                addonsTotal = addonsTotal + ((addOn.price ?? 0) * qtys[index0]);
                index0 = index0 + 1;
              }
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

          foodAmount = (cart.product.price == 1
                      ? cart.discountedPrice
                      : cart.product.price)! *
                  cart.quantity +
              variationTotal +
              addonsTotal;

          // Check giveDiscount condition for Fixed discount
          double tempAmount = 0;
          if (cart.product.giveDiscount.toString() == 'Yes') {
            tempAmount = foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100);
            orderDiscount = orderDiscount +
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100);
          } else {
            tempAmount = foodAmount;
          }

          if (cart.product.taxType.toString() == 'GST') {
            if (restaurant.gstStatus == 'true') {
              if (Get.find<PosController>().isAddServiceCharge) {
                gstAmount = gstAmount +
                    (((tempAmount +
                                ((tempAmount * serviceChargePercentage) /
                                    100)) *
                            double.parse(cart.product.tax.toString())) /
                        100);
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
              } else {
                gstAmount = gstAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge)
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
            }
            discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
          } else if (cart.product.taxType.toString() == 'VAT') {
            if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
                'true') {
              if (Get.find<PosController>().isAddServiceCharge) {
                vatAmount = vatAmount +
                    (((tempAmount +
                                ((tempAmount * serviceChargePercentage) /
                                    100)) *
                            double.parse(cart.product.tax.toString())) /
                        100);
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
              } else {
                vatAmount = vatAmount +
                    ((tempAmount * double.parse(cart.product.tax.toString())) /
                        100);
              }
            } else {
              if (Get.find<PosController>().isAddServiceCharge)
                showServiceChargeValue = showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100);
            }
            discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
          }
        }
      }

      if (discountedOrderSubTotal >= 0) {
        ////final calculation for addition of gst, vat, service charge
        // if (Get.find<PosController>().isAddServiceCharge) {
        //   showServiceChargeValue =
        //       (discountedOrderSubTotal * serviceChargePercentage) / 100;
        //   paidController.text = (discountedOrderSubTotal +
        //           (discountedOrderSubTotal * serviceChargePercentage / 100) +
        //           gstAmount +
        //           vatAmount +
        //           (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)))
        //       .toStringAsFixed(2);
        //   Get.find<PosController>().setcollectItemPrice(
        //       discountedOrderSubTotal +
        //           (discountedOrderSubTotal * serviceChargePercentage / 100) +
        //           gstAmount +
        //           vatAmount +
        //           (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
        // } else {
        paidController.text = (discountedOrderSubTotal +
                showServiceChargeValue +
                gstAmount +
                vatAmount +
                (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)))
            .toStringAsFixed(2);
        Get.find<PosController>().setcollectItemPrice(discountedOrderSubTotal +
            showServiceChargeValue +
            gstAmount +
            vatAmount +
            (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
        // }
      } else {
        showErrorToast('Please enter valid discount');
      }
    }

    if (mounted) setState(() {});
  }

  Widget productWidget({
    CartModel? cart,
    int? cartIndex,
    List<AddOns>? addOns,
    bool? isAvailable,
    Function? onIncrease,
  }) {
    String addOnText = '';
    double addonsTotal = 0;
    int index0 = 0;
    List<int> ids = [];
    List<int> qtys = [];
    for (var addOn in cart!.addOnIds) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    if (cart.product.addOns != null) {
      for (var addOn in cart.product.addOns!) {
        if (ids.contains(addOn.id)) {
          addOnText =
              '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
          addonsTotal = addonsTotal + ((addOn.price ?? 0) * qtys[index0]);
          index0 = index0 + 1;
        }
      }
    }

    String variationText = '';
    double halfVariationPrice = 0;
    variationTotal = 0;
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
                variationTotal += double.parse(
                    cart.product.variations![index].values![i].optionPrice!);
              }
              // print(variationTotal);
              variationText +=
                  '${variationText.endsWith('(') ? '' : ', '}${cart.product.variations![index].values![i].level}';
            }
          }
          variationText += ')';
          variationTotal = variationTotal + halfVariationPrice;
        }
      }
    }

    return InkWell(
      onTap: () {
        if (cart.product.price == 1 ||
            (cart.product.variations != null &&
                cart.product.variations!.isNotEmpty) ||
            (cart.product.addOns != null && cart.product.addOns!.isNotEmpty)) {
          if (cart.quantity == 1) {
            Get.find<CartController>().initData(cart.product, cart);

            MediaQuery.of(context).size.width > 1600
                ? Get.dialog(
                    Dialog(
                      child: ProductBottomSheet(
                          onIncrease: (data) {
                            if (data != null && data) {
                              if (onIncrease != null) onIncrease(true);
                            }
                          },
                          product: cart.product,
                          cartIndex: cartIndex!,
                          cart: cart),
                    ),
                  )
                : showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (con) {
                      return ProductBottomSheet(
                          onIncrease: (data) {
                            if (data != null && data) {
                              if (onIncrease != null) onIncrease(true);
                            }
                          },
                          product: cart.product,
                          cartIndex: cartIndex!,
                          cart: cart);
                    },
                  );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: ColorTheme.productCard,
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cart.product.name ?? '',
                              style: poppinsSemiBold.copyWith(
                                  color: Colors.black, fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((cart.product.description ?? '') != '')
                              const SizedBox(height: 2),
                            if ((cart.product.description ?? '') != '')
                              Text(
                                cart.product.description ?? '',
                                style: poppinsMedium.copyWith(
                                    color: ColorTheme.hintText,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 13
                                        : 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 2),

                            // Ratig should be removed from web browser

                            const SizedBox(height: 5),
                            Row(children: [
                              Text(
                                PriceConverter.convertPrice(
                                    cart.discountedPrice +
                                        variationTotal +
                                        addonsTotal,
                                    asFixed: 2,
                                    isHideCurrency: true),
                                style: poppinsBold.copyWith(
                                    color: ColorTheme.green, fontSize: 13),
                              ),
                            ]),
                          ]),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: ColorTheme.borderGrey)),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: QuantityButton(
                                      onTap: () {
                                        if (cart.quantity > 1) {
                                          Get.find<CartController>()
                                              .setQuantity(false, cart);
                                        } else {
                                          Get.find<CartController>()
                                              .removeFromCart(cartIndex!);
                                          if (Get.find<CartController>()
                                              .cartList
                                              .isEmpty) {
                                            Navigator.pop(context);
                                          }
                                        }

                                        if (onIncrease != null)
                                          onIncrease(true);
                                      },
                                      isIncrement: false,
                                    ),
                                  ),
                                  Text(cart.quantity.toString(),
                                      style:
                                          poppinsMedium.copyWith(fontSize: 14)),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: QuantityButton(
                                      onTap: () {
                                        if (addOnText == '') {
                                          Get.find<CartController>()
                                              .setQuantity(true, cart);

                                          if (onIncrease != null)
                                            onIncrease(true);
                                        }
                                      },
                                      isIncrement: true,
                                    ),
                                  ),
                                ]),
                          ),
                        ]),
                  ],
                ),
                (variationText != '' &&
                        cart.product.variations != null &&
                        cart.product.variations!.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Variants: ',
                                style: poppinsMedium.copyWith(
                                    color: ColorTheme.blue,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 14
                                        : 10),
                              ),
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
                                style: poppinsMedium.copyWith(
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 14
                                        : 10,
                                    color: Colors.black),
                              )),
                            ]),
                      )
                    : const SizedBox(),
                if (Get.find<CartController>().cartList.length - 1 != cartIndex)
                  Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: DottedLine(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      lineThickness: 1.0,
                      dashLength: 2.5,
                      dashColor: ColorTheme.hintText,
                    ),
                  ),
              ],
            )),
      ),
    );
  }

  Widget customerDetail(CartController cartController) {
    return Container(
      margin: EdgeInsets.only(top: 15, left: 20, right: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: ColorTheme.productCard,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('Sub Total'.tr,
                    textAlign: TextAlign.right,
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
                Text(
                    ' :   ' +
                        PriceConverter.convertPrice(orderSubTotal,
                            isHideCurrency: true, asFixed: 2),
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11)),
              ]),
              if (selectedDiscountType == 'Percent' &&
                  Get.find<AuthController>().profileModel!.discountList !=
                      null &&
                  Get.find<AuthController>()
                      .profileModel!
                      .discountList!
                      .isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        'Discount Type'
                        ' : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      width: Get.width * 0.35,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: DropdownButton<DiscountCategoryListModel>(
                        isExpanded: true,
                        underline: SizedBox.shrink(),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        value: selectedDiscount,
                        hint: Text("Discount"),
                        onChanged: (DiscountCategoryListModel? newValue) {
                          selectedDiscount = newValue;
                          _discountController.text = newValue!.discount!;
                          discountCalculator();
                          Get.find<PosController>().update();
                          // setState(() {
                          //   selectedCategory = newValue;
                          // });
                        },
                        items: Get.find<AuthController>()
                            .profileModel!
                            .discountList!
                            .map<DropdownMenuItem<DiscountCategoryListModel>>(
                          (DiscountCategoryListModel category) {
                            return DropdownMenuItem<DiscountCategoryListModel>(
                              value: category,
                              child: Text(category.discountType!),
                            );
                          },
                        ).toList(),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),
              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .discountType !=
                  'No')
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        'Discount Type'
                        ' : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      width: Get.width * 0.35,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: SizedBox.shrink(),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        value: selectedDiscountType,
                        hint: Text("Discount"),
                        onChanged: (String? newValue) {
                          selectedDiscountType = newValue!;
                          _discountController.text = '0';
                          discountCalculator();
                          // setState(() {
                          //   selectedCategory = newValue;
                          // });
                        },
                        items: discountType.map<DropdownMenuItem<String>>(
                          (String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          },
                        ).toList(),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),

              if (selectedDiscountType != 'No')
                Padding(
                  padding: const EdgeInsets.only(right: 0, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                        Get.find<AuthController>()
                                .profileModel!
                                .restaurants!
                                .first
                                .discountText! +
                            ' : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      width: Get.width * 0.2,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: TextField(
                        controller: _discountController,
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        autofocus: false,
                        decoration: InputDecoration(
                          // hintText: 'phone'.tr,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(style: BorderStyle.none, width: 0),
                          ),
                          hintStyle: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                              color: ColorTheme.hintText),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        onChanged: (value) async {
                          discountCalculator();
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),

              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .isShowTips ==
                  'Yes')
                Padding(
                  padding: const EdgeInsets.only(right: 0, top: 10),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('Add tips : ',
                        textAlign: TextAlign.right,
                        style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      width: Get.width * 0.2,
                      height: MediaQuery.of(context).size.shortestSide > 570
                          ? 40
                          : 25,
                      child: TextField(
                        controller: _addTips,
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        autofocus: false,
                        decoration: InputDecoration(
                          // hintText: 'phone'.tr,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(style: BorderStyle.none, width: 0),
                          ),
                          hintStyle: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                              color: ColorTheme.hintText),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: poppinsMedium.copyWith(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11,
                        ),
                        onChanged: (value) async {
                          discountCalculator();
                        },
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: ColorTheme.borderGrey)),
                    ),
                  ]),
                ),

              if (Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .serviceCharge ==
                  'Yes')
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Checkbox(
                      value: Get.find<PosController>().isAddServiceCharge,
                      onChanged: (val) {
                        Get.find<PosController>()
                            .changeServeiceChargeValue(val!);
                        discountCalculator();
                      }),
                  Text(
                      '${Get.find<AuthController>().profileModel!.restaurants!.first.settings?.serviceChrgTaxt}',
                      textAlign: TextAlign.right,
                      style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11,
                      )),
                  Text(
                      ' :  ${PriceConverter.convertPrice(showServiceChargeValue, isHideCurrency: true)}',
                      style: poppinsMedium.copyWith(
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11)),
                ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    // width: 28,
                    child: Checkbox(
                      value: isAutoBillPrint,
                      onChanged: (bool? value) {
                        setState(() {
                          isAutoBillPrint = value!;
                        });
                      },
                    ),
                  ),
                  Text(
                    "Auto Bill Print",
                    style: poppinsMedium.copyWith(
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 15
                            : 11),
                  ),
                ],
              ),
              if (gstAmount != 0)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('CGST'.tr,
                            textAlign: TextAlign.right,
                            style: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                            )),
                        Text(' :   ${(gstAmount / 2).toStringAsFixed(2)}',
                            style: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 11)),
                      ]),
                      SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('SGST'.tr,
                            textAlign: TextAlign.right,
                            style: poppinsMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 570
                                      ? 15
                                      : 11,
                            )),
                        Text(' :   ${(gstAmount / 2).toStringAsFixed(2)}',
                            style: poppinsMedium.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 15
                                        : 11)),
                      ]),
                    ],
                  ),
                ),
              // SizedBox(
              //     height: Dimensions
              //         .PADDING_SIZE_SMALL),

              Padding(
                padding: const EdgeInsets.only(right: 0, top: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('Total'.tr,
                      textAlign: TextAlign.right,
                      style: poppinsBold.copyWith(
                        color: ColorTheme.green,
                        fontSize: MediaQuery.of(context).size.shortestSide > 570
                            ? 17
                            : 14,
                      )),
                  Text(
                      ' :  ' +
                          PriceConverter.convertPrice(
                              (Get.find<PosController>().collectItemPrice),
                              isHideCurrency: true,
                              asFixed: 2),
                      style: poppinsBold.copyWith(
                          color: ColorTheme.green,
                          fontSize:
                              MediaQuery.of(context).size.shortestSide > 570
                                  ? 17
                                  : 14)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  showPaymentDetail() {
    return GetBuilder<PosController>(builder: (posController) {
      return GetBuilder<CartController>(builder: (cartController) {
        return posController.isLoading || cartController.isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 15, right: 15,
                      top: Dimensions.PADDING_SIZE_DEFAULT,
                      bottom: Dimensions.PADDING_SIZE_SMALL,
                      // left: Dimensions.PADDING_SIZE_DEFAULT,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorTheme.bgSettleCardGreyColor),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .payCash ==
                                    'Yes')
                                  SizedBox(
                                    width: Get.width * 0.14,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        posController.setPaymentTabIndex(0);
                                      },
                                      child: Container(
                                        width: Get.width,
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        0
                                                    ? Colors.transparent
                                                    : ColorTheme.borderGrey),
                                            color: posController
                                                        .selectedPaymentTab ==
                                                    0
                                                ? ColorTheme.appColor
                                                : Colors.transparent,
                                            // border:
                                            //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Center(
                                          child: Text(
                                            'Cash'.tr,
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        0
                                                    ? Colors.white
                                                    : ColorTheme.appColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .payCC ==
                                    'Yes')
                                  SizedBox(
                                    width: Get.width * 0.14,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        posController.setPaymentTabIndex(1);
                                      },
                                      child: Container(
                                        width: Get.width,
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        1
                                                    ? Colors.transparent
                                                    : ColorTheme.borderGrey),
                                            color: posController
                                                        .selectedPaymentTab ==
                                                    1
                                                ? ColorTheme.appColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Center(
                                          child: Text(
                                            'Card'.tr,
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        1
                                                    ? Colors.white
                                                    : ColorTheme.appColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .payUpi ==
                                    'Yes')
                                  SizedBox(
                                    width: Get.width * 0.14,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        posController.setPaymentTabIndex(2);
                                      },
                                      child: Container(
                                        width: Get.width,
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        2
                                                    ? Colors.transparent
                                                    : ColorTheme.borderGrey),
                                            color: posController
                                                        .selectedPaymentTab ==
                                                    2
                                                ? ColorTheme.appColor
                                                : Colors.transparent,

                                            // border:
                                            //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Center(
                                          child: Text(
                                            'UPI'.tr,
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        2
                                                    ? Colors.white
                                                    : ColorTheme.appColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .payTab ==
                                    'Yes')
                                  SizedBox(
                                    width: Get.width * 0.14,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        posController.setPaymentTabIndex(3);
                                      },
                                      child: Container(
                                        width: Get.width,
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.symmetric(
                                            // horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        3
                                                    ? Colors.transparent
                                                    : ColorTheme.borderGrey),
                                            color: posController
                                                        .selectedPaymentTab ==
                                                    3
                                                ? ColorTheme.appColor
                                                : Colors.transparent,

                                            // border:
                                            //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Center(
                                          child: Text(
                                            'Credit',
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        3
                                                    ? Colors.white
                                                    : ColorTheme.appColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (Get.find<AuthController>()
                                        .profileModel!
                                        .restaurants!
                                        .first
                                        .showRoom ==
                                    'Yes')
                                  SizedBox(
                                    width: Get.width * 0.14,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        posController.setPaymentTabIndex(4);
                                      },
                                      child: Container(
                                        width: Get.width,
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        4
                                                    ? Colors.transparent
                                                    : ColorTheme.borderGrey),
                                            color: posController
                                                        .selectedPaymentTab ==
                                                    4
                                                ? ColorTheme.appColor
                                                : Colors.transparent,

                                            // border:
                                            //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Center(
                                          child: Text(
                                            'Room'.tr,
                                            style: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: posController
                                                            .selectedPaymentTab ==
                                                        4
                                                    ? Colors.white
                                                    : ColorTheme.appColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 15),
                            DottedLine(
                              direction: Axis.horizontal,
                              alignment: WrapAlignment.center,
                              lineThickness: 1.0,
                              dashLength: 2.5,
                              dashColor: ColorTheme.hintText,
                            ),

                            posController.selectedPaymentTab == 4
                                ? posController.roomList.isNotEmpty
                                    ? Column(
                                        children: [
                                          Container(
                                            height: 30,
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 15),
                                            // width: Get.width * 0.8,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: ColorTheme.borderGrey),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: DropdownButton<
                                                GetRoomListResponse>(
                                              isExpanded: true,
                                              icon: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: ColorTheme.appColor,
                                              ),
                                              value: posController
                                                          .selectedRoom ==
                                                      null
                                                  ? posController.roomList.first
                                                  : posController.selectedRoom,
                                              items: posController.roomList.map(
                                                  (GetRoomListResponse value) {
                                                return DropdownMenuItem<
                                                    GetRoomListResponse>(
                                                  value: value,
                                                  child: Text(
                                                    '${value.table!.title} ${value.table!.tableNo}',
                                                    maxLines: 1,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color:
                                                          value.table!.id == 0
                                                              ? Colors.grey
                                                              : Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged:
                                                  (GetRoomListResponse? value) {
                                                posController
                                                    .setRoomIndex(value);

                                                if (value!.user != null) {
                                                  _nameController.clear();
                                                  _phoneController.clear();
                                                  if (value.user!.fName != '') {
                                                    _nameController.text =
                                                        value.user!.fName;
                                                  }
                                                }
                                                if (value.user != null) {
                                                  if (value.user!.phone != '') {
                                                    _phoneController.text =
                                                        value.user!.phone;
                                                  }
                                                }
                                              },
                                              underline: SizedBox(),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          nameTextField(context),
                                          SizedBox(height: 15),
                                          phoneTextField(context),
                                        ],
                                      )
                                    : SizedBox.shrink()
                                : Container(
                                    margin: EdgeInsets.only(
                                      top: Dimensions.PADDING_SIZE_LARGE,
                                    ),
                                    child: Column(
                                      children: [
                                        posController.selectedPaymentTab == 0
                                            ? Column(
                                                children: [
                                                  Container(
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color: ColorTheme
                                                                .borderGrey)),
                                                    child: TextField(
                                                      controller:
                                                          paidController,
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                              signed: true),
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          borderSide: BorderSide(
                                                              style: BorderStyle
                                                                  .none,
                                                              width: 0),
                                                        ),
                                                        hintStyle: poppinsMedium
                                                            .copyWith(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey),
                                                        filled: true,
                                                        hintText: 'Paid',
                                                        fillColor: Colors.white,
                                                      ),
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      onChanged: (value) async {
                                                        if (paidController
                                                            .text.isEmpty) {
                                                          changeController
                                                              .text = '';
                                                        } else {
                                                          if (double.parse(
                                                                  paidController
                                                                      .text) >
                                                              (posController
                                                                  .collectItemPrice)) {
                                                            changeController
                                                                    .text =
                                                                '${(double.parse(paidController.text) - posController.collectItemPrice).toStringAsFixed(2)}';
                                                          } else {
                                                            changeController
                                                                .text = '0';
                                                          }
                                                        }
                                                        // posController.update();
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 15),
                                                  Container(
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .RADIUS_SMALL),
                                                        border: Border.all(
                                                            color: ColorTheme
                                                                .borderGrey)),
                                                    child: TextField(
                                                      controller:
                                                          changeController,
                                                      autofocus: false,
                                                      readOnly: true,
                                                      decoration:
                                                          InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                borderSide: BorderSide(
                                                                    style:
                                                                        BorderStyle
                                                                            .none,
                                                                    width: 0),
                                                              ),
                                                              hintStyle: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .grey),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              hintText:
                                                                  'Change'),
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      onChanged:
                                                          (value) async {},
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox.shrink(),
                                        posController.selectedPaymentTab == 1
                                            ? Container(
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: ColorTheme
                                                            .borderGrey)),
                                                child: TextField(
                                                  controller:
                                                      _transactionNoController,
                                                  autofocus: false,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      borderSide: BorderSide(
                                                          style:
                                                              BorderStyle.none,
                                                          width: 0),
                                                    ),
                                                    hintStyle:
                                                        poppinsMedium.copyWith(
                                                            fontSize: 13,
                                                            color: Colors.grey),
                                                    hintText: 'Transaction No.',
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
                                                  style: poppinsMedium.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                  onChanged: (value) async {},
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        if (posController.selectedPaymentTab ==
                                            3)
                                          nameTextField(context),
                                        if (posController.selectedPaymentTab ==
                                            3)
                                          SizedBox(height: 15),
                                        if (posController.selectedPaymentTab ==
                                            3)
                                          phoneTextField(context),
                                        posController.selectedPaymentTab == 2 &&
                                                Get.find<AuthController>()
                                                        .profileModel!
                                                        .restaurants!
                                                        .first
                                                        .upiId !=
                                                    ''
                                            ? QrImageView(
                                                data:
                                                    'upi://pay?pa=${Get.find<AuthController>().profileModel!.restaurants!.first.upiId}&pn=&am=${Get.find<PosController>().collectItemPrice}&tn=',
                                                size: 120,
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                                  ), // : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
      });
    });
  }

  payNormalBill(PosController posController) {
    Map<String, dynamic> jsonData = {
      'waiter_id': Get.find<AuthController>().profileModel!.empId.toString(),
      'payment_method': Get.find<PosController>().selectedPaymentTab == 0
          ? 'cash'
          : Get.find<PosController>().selectedPaymentTab == 1
              ? 'card'
              : Get.find<PosController>().selectedPaymentTab == 2
                  ? 'upi'
                  : posController.selectedPaymentTab == 4
                      ? 'ROOM'
                      : 'TAB',
      'paid_room': posController.selectedPaymentTab == 4 ? 'Yes' : '',
      'payment_status': 'sucess',
      'cust_email': '',
      "payment_type": "prepaid",
      "order_note": widget.orderNote ?? '',
      'delivery_charge': '${widget.deliveryCharge}',
      // "order_amount": orderSubTotal,
      "tax_amount": gstAmount + vatAmount,
      'order_sub_total_amount': orderSubTotal,
      'order_amount': Get.find<PosController>().collectItemPrice,
      'vat_tax': vatAmount,
      'gst_tax': gstAmount,
      'address_id': widget.addressId ?? '',
      'print_kot': widget.isAutoKot ? 'Yes' : 'No',
      'self_discount': orderDiscount,
      'order_type': Get.find<TableController>().selectedTable == null
          ? 'pos'
          : (Get.find<TableController>().selectedTable?.id == 0 &&
                  Get.find<TableController>().selectedTable?.tableNo ==
                      'Delivery')
              ? 'delivery'
              : (Get.find<TableController>().selectedTable?.id == 0 &&
                      Get.find<TableController>().selectedTable?.tableNo ==
                          'Take Away')
                  ? 'take_away'
                  : 'pos',
      "table_id": Get.find<TableController>().selectedTable?.id == 0
          ? '0'
          : Get.find<TableController>().selectedTable?.id.toString() ?? '0',

      'tip_amount': _addTips.text.isEmpty ? '0' : _addTips.text,
      'order_discount': orderDiscount,
      'cust_mobile': _phoneController.text.isEmpty ? '' : _phoneController.text,
      'cust_name': _nameController.text.isEmpty ? '' : _nameController.text,
      'restaurant_name':
          Get.find<AuthController>().profileModel!.restaurants![0].name,
      'service_tax': Get.find<PosController>().isAddServiceCharge
          ? showServiceChargeValue
          : 0,
      'transaction_id': _transactionNoController.text.isEmpty
          ? ''
          : _transactionNoController.text,
      'room_id': posController.selectedPaymentTab == 4
          ? '${Get.find<PosController>().selectedRoom!.table!.id}'
          : ''
    };
    if (Get.find<PosController>().selectedPaymentTab == 0) {
      if (paidController.text.isEmpty) {
        showErrorToast('Please enter paid amount');
      } else if (double.parse(paidController.text) <
          Get.find<PosController>().collectItemPrice) {
        showErrorToast('Paid amount cannot be less than bill amount');
      } else {
        Get.find<CartController>().prepaidOrder(callback, jsonBody: jsonData);
      }
    } else if (Get.find<PosController>().selectedPaymentTab == 1 ||
        Get.find<PosController>().selectedPaymentTab == 2 ||
        Get.find<PosController>().selectedPaymentTab == 3 ||
        Get.find<PosController>().selectedPaymentTab == 4) {
      if (_transactionNoController.text.isEmpty &&
          Get.find<PosController>().selectedPaymentTab == 1) {
        showErrorToast('Please enter transaction number');
      } else {
        Get.find<CartController>().prepaidOrder(callback, jsonBody: jsonData);
      }
    }
  }

  void callback(bool isSuccess, String message, String orderID) async {
    if (isSuccess) {
      if (isAutoBillPrint) {
        if (GetPlatform.isWindows) {
          final printers = await Printing.listPrinters();
          for (var element in printers) {
            if (element.isAvailable &&
                (element.name.toLowerCase() ==
                    Get.find<AuthController>()
                        .profileModel!
                        .wifiBillPrinterName!
                        .toLowerCase())) {
              await Printing.directPrintPdf(
                printer: element,
                onLayout: (_) => WindowsPrintByteConvert().byteConvert(
                    paymentType: Get.find<PosController>().selectedPaymentTab ==
                            0
                        ? 'cash'
                        : Get.find<PosController>().selectedPaymentTab == 1
                            ? 'card'
                            : Get.find<PosController>().selectedPaymentTab == 2
                                ? 'upi'
                                : Get.find<PosController>()
                                            .selectedPaymentTab ==
                                        4
                                    ? 'ROOM'
                                    : Get.find<PosController>()
                                                .selectedPaymentTab ==
                                            5
                                        ? 'partial'
                                        : Get.find<PosController>()
                                                    .selectedPaymentTab ==
                                                3
                                            ? 'TAB'
                                            : '',
                    printType: 'billing',
                    paperRoll:
                        Get.find<AuthController>()
                                    .profileModel!
                                    .billPrinterPaperRoll ==
                                58
                            ? 58
                            : 80,
                    orderId: orderID,
                    date:
                        '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
                    waiterName:
                        '${Get.find<AuthController>().selectedEmployee == null ? Get.find<AuthController>().profileModel!.empFname : Get.find<AuthController>().selectedEmployee!.fName}',
                    tablename: 'Billing',
                    custName: _nameController.text.isEmpty
                        ? ''
                        : _nameController.text,
                    custPhone: _phoneController.text.isEmpty
                        ? ''
                        : _phoneController.text,
                    cartList: Get.find<CartController>().cartList ?? [],
                    orderNote: '',
                    orderSubTotal: orderSubTotal,
                    discount: orderDiscount,
                    serviceChargeAmount:
                        Get.find<PosController>().isAddServiceCharge
                            ? showServiceChargeValue
                            : 0,
                    roomRemainingPay: 0,
                    roomAdvancePay: 0,
                    roomGst: 0,
                    deliveryCharge: 0,
                    gstAmount: gstAmount,
                    vatAmount: vatAmount,
                    grandTotal: Get.find<PosController>().collectItemPrice,
                    tips:
                        _addTips.text.isEmpty ? 0 : double.parse(_addTips.text),
                    orderType: 'Billing'),
              );
              beepWindows();

              if (MediaQuery.of(context).size.shortestSide > 570) {
                Get.until((route) =>
                    route.settings.name == RouteHelper.getTableViewHomeRoute());
                // route.settings.name ==
                // RouteHelper.getTablateWaiterDashboardInitialRoute());
                Get.find<CartController>().clearCartList();
              } else {
                Get.until((route) =>
                    route.settings.name == RouteHelper.getTableViewHomeRoute());
                // RouteHelper.getWaiterDashboardInitialRoute());
                Get.find<CartController>().clearCartList();
              }
              break;
            }
          }
        } else if (GetPlatform.isAndroid) {
          _kdsPrintEscPos(await PrintByteConvert().byteConvert(
              printType: 'billing',
              paymentType: Get.find<PosController>().selectedPaymentTab == 0
                  ? 'cash'
                  : Get.find<PosController>().selectedPaymentTab == 1
                      ? 'card'
                      : Get.find<PosController>().selectedPaymentTab == 2
                          ? 'upi'
                          : Get.find<PosController>().selectedPaymentTab == 4
                              ? 'ROOM'
                              : Get.find<PosController>().selectedPaymentTab ==
                                      5
                                  ? 'partial'
                                  : Get.find<PosController>()
                                              .selectedPaymentTab ==
                                          3
                                      ? 'TAB'
                                      : '',
              paperRoll: Get.find<AuthController>()
                          .profileModel!
                          .billPrinterPaperRoll ==
                      58
                  ? 58
                  : 80,
              orderId: orderID,
              date:
                  '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
              waiterName:
                  '${Get.find<AuthController>().selectedEmployee == null ? Get.find<AuthController>().profileModel!.empFname : Get.find<AuthController>().selectedEmployee!.fName}',
              tablename: 'Billing',
              custName:
                  _nameController.text.isEmpty ? '' : _nameController.text,
              custPhone:
                  _phoneController.text.isEmpty ? '' : _phoneController.text,
              cartList: Get.find<CartController>().cartList ?? [],
              orderNote: '',
              orderSubTotal: orderSubTotal,
              discount: orderDiscount,
              serviceChargeAmount: Get.find<PosController>().isAddServiceCharge
                  ? showServiceChargeValue
                  : 0,
              roomRemainingPay: 0,
              roomAdvancePay: 0,
              deliveryCharge: 0,
              gstAmount: gstAmount,
              vatAmount: vatAmount,
              grandTotal: Get.find<PosController>().collectItemPrice,
              tips: _addTips.text.isEmpty ? 0 : double.parse(_addTips.text),
              orderType: 'Billing'));
          if (MediaQuery.of(context).size.shortestSide > 570) {
            Get.until((route) =>
                route.settings.name == RouteHelper.getTableViewHomeRoute());
            Get.find<CartController>().clearCartList();
          } else {
            Get.until((route) =>
                route.settings.name == RouteHelper.getTableViewHomeRoute());
            Get.find<CartController>().clearCartList();
          }
        } else {
          _iosPrintEscPos(await PrintByteConvert().byteConvert(
              printType: 'billing',
              paymentType: Get.find<PosController>().selectedPaymentTab == 0
                  ? 'cash'
                  : Get.find<PosController>().selectedPaymentTab == 1
                      ? 'card'
                      : Get.find<PosController>().selectedPaymentTab == 2
                          ? 'upi'
                          : Get.find<PosController>().selectedPaymentTab == 4
                              ? 'ROOM'
                              : Get.find<PosController>().selectedPaymentTab ==
                                      5
                                  ? 'partial'
                                  : Get.find<PosController>()
                                              .selectedPaymentTab ==
                                          3
                                      ? 'TAB'
                                      : '',
              paperRoll: Get.find<AuthController>()
                          .profileModel!
                          .billPrinterPaperRoll ==
                      58
                  ? 58
                  : 80,
              orderId: orderID,
              date:
                  '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
              waiterName:
                  '${Get.find<AuthController>().selectedEmployee == null ? Get.find<AuthController>().profileModel!.empFname : Get.find<AuthController>().selectedEmployee!.fName}',
              tablename: 'Billing',
              custName:
                  _nameController.text.isEmpty ? '' : _nameController.text,
              custPhone:
                  _phoneController.text.isEmpty ? '' : _phoneController.text,
              cartList: Get.find<CartController>().cartList ?? [],
              orderNote: '',
              orderSubTotal: orderSubTotal,
              discount: orderDiscount,
              serviceChargeAmount: Get.find<PosController>().isAddServiceCharge
                  ? showServiceChargeValue
                  : 0,
              roomRemainingPay: 0,
              roomAdvancePay: 0,
              deliveryCharge: 0,
              gstAmount: gstAmount,
              vatAmount: vatAmount,
              grandTotal: Get.find<PosController>().collectItemPrice,
              tips: _addTips.text.isEmpty ? 0 : double.parse(_addTips.text),
              orderType: 'Billing'));
          if (MediaQuery.of(context).size.shortestSide > 570) {
            Get.until((route) =>
                route.settings.name == RouteHelper.getTableViewHomeRoute());
            Get.find<CartController>().clearCartList();
          } else {
            Get.until((route) =>
                route.settings.name == RouteHelper.getTableViewHomeRoute());
            Get.find<CartController>().clearCartList();
          }
        }
      } else {
        if (GetPlatform.isWindows ||
            MediaQuery.of(context).size.shortestSide > 570) {
          Get.until((route) =>
              route.settings.name == RouteHelper.getTableViewHomeRoute());
          // RouteHelper.getTablateWaiterDashboardInitialRoute());
          Get.find<CartController>().clearCartList();
        } else {
          Get.until((route) =>
              route.settings.name == RouteHelper.getTableViewHomeRoute());
          // RouteHelper.getWaiterDashboardInitialRoute());
          Get.find<CartController>().clearCartList();
        }
      }
      // Get.find<CartController>().clearCartList();
    } else {
      showErrorToast(message);
    }
  }

  /// print ticket
  Future _kdsPrintEscPos(List<int> bytes) async {
    // await printerManager.disconnect(type: PrinterType.bluetooth);
    BluetoothPrinter? bluetoothPrinter;
    if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
      bluetoothPrinter = await BluetoothPrinter(
          productId: Get.find<AuthController>().profileModel!.billProductId,
          vendorId: Get.find<AuthController>().profileModel!.billVendorId,
          typePrinter: PrinterType.usb);
    } else {
      bluetoothPrinter = await BluetoothPrinter(
          typePrinter: Get.find<AuthController>().profileModel!.billWifiIp != ''
              ? PrinterType.network
              : PrinterType.bluetooth,
          port: '9100',
          address: Get.find<AuthController>().profileModel!.billWifiIp != ''
              ? Get.find<AuthController>().profileModel!.billWifiIp
              : Get.find<AuthController>().profileModel!.billPrinterIp,
          deviceName: Get.find<AuthController>()
              .profileModel!
              .billPrinterName); // ip was mandadory
    }

    var data;
    // if (Get.find<AuthController>().profileModel!.billPrinterType == 'usb') {
    //   data = await individualPrinter.connect(
    //     type: PrinterType.usb,
    //     model: UsbPrinterInput(
    //       productId: Get.find<AuthController>().profileModel!.billProductId,
    //       vendorId: Get.find<AuthController>().profileModel!.billVendorId,
    //     ),
    //   );
    // } else {
    //   data = await individualPrinter.connect(
    //     type: bluetoothPrinter.typePrinter,
    //     model: BluetoothPrinterInput(
    //       name: bluetoothPrinter.deviceName,
    //       address: bluetoothPrinter.address!,
    //     ),
    //   );
    // }
    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        // bytes += generator.feed(2);
        data = await individualPrinter.connect(
          type: bluetoothPrinter.typePrinter,
          model: UsbPrinterInput(
            name: bluetoothPrinter.deviceName,
            productId: bluetoothPrinter.productId,
            vendorId: bluetoothPrinter.vendorId,
          ),
        );
        break;
      case PrinterType.bluetooth:
        data = await individualPrinter.connect(
          type: bluetoothPrinter.typePrinter,
          model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
          ),
        );
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        // bytes += generator.feed(2);
        data = await individualPrinter.connect(
          type: bluetoothPrinter.typePrinter,
          model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!),
        );
        break;
      default:
    }

    try {
      await individualPrinter.send(
          type: bluetoothPrinter.typePrinter, bytes: bytes);
      Future.delayed(
          Duration(
              seconds: bytes.length <= 5850
                  ? 1
                  : bytes.length <= 7890
                      ? 2
                      : bytes.length <= 10195
                          ? 5
                          : bytes.length <= 13100
                              ? 10
                              : bytes.length <= 21150
                                  ? 15
                                  : 20), () async {
        pendingTask = null;
        Get.find<LoadingController>().startLoading(false);

        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        await PrinterManager.instance
            .disconnect(type: bluetoothPrinter!.typePrinter);
      });
      // await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
    } catch (e) {}
    if (data != null && !data) {
      await Get.find<LoadingController>().changeText(
          data:
              Get.find<AuthController>().profileModel!.billPrinterType == 'usb'
                  ? 'Failed to usb connect!!'
                  : 'Failed to bluetooth connect!!',
          error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  Future<void> _iosPrintEscPos(List<int> bytes) async {
    print('########## bytes length ${bytes.length}');

    final bool result = await IosPrintTransport.connect(wifiPrinter: NetworkPrinterResolver.billPrinter(), 
      macPrinterAddress:
          Get.find<AuthController>().profileModel!.macBillPrinterIp!,
    );

    // Small delay after connect (important on iPad)
    await Future.delayed(const Duration(seconds: 2));

    if (!result) {
      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Failed to bluetooth connect!!', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
      return;
    }

    try {
      // 🔥 iPad-safe chunked write (MOST IMPORTANT PART)
      (Get.find<AuthController>().profileModel!.billPrinterPaperRoll == 58 ||
              MediaQuery.of(context).size.shortestSide < 570)
          ? await IosPrintTransport.writeBytes(bytes)
          : await _writeBytesForIPad(bytes);

      // Wait a bit to ensure printer finishes printing
      await Future.delayed(
          Duration(
              seconds: bytes.length <= 5850
                  ? 2
                  : bytes.length <= 7890
                      ? 3
                      : bytes.length <= 10195
                          ? 6
                          : bytes.length <= 13100
                              ? 10
                              : bytes.length <= 21150
                                  ? 15
                                  : 20), () async {
        Get.find<LoadingController>().startLoading(false);
        await Get.find<LoadingController>()
            .changeText(data: 'Successfully printed!!');
        await Get.find<LoadingController>().changeStatus(data: true);
        final isDisconnect = await IosPrintTransport.disconnect;
        print('is disconnect $isDisconnect');
      });
    } catch (e) {
      print('Print error: $e');
      Get.find<LoadingController>().startLoading(false);
      await Get.find<LoadingController>()
          .changeText(data: 'Printing failed!!', error: true);
      await Get.find<LoadingController>().changeStatus(data: true);
    }
  }

  Future<void> _writeBytesForIPad(List<int> bytes) async {
    const int chunkSize = 255; // 🔥 SAFE for all iPads
    const int delayMs = 60; // Required for 80mm stability

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final chunk = bytes.sublist(
        i,
        (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize,
      );

      await IosPrintTransport.writeBytes(chunk);
      await Future.delayed(const Duration(milliseconds: delayMs));
    }
  }
  // Future _iosPrintEscPos(List<int> bytes) async {
  //   print('########## bytes length ${bytes.length}');
  //   // bytes += generator.feed(2);
  //   // await PrintBluetoothThermal.pairedBluetooths;

  //   // Future.delayed(Duration(seconds: 5), () async {
  //   final bool result = await PrintBluetoothThermal.connect(
  //       macPrinterAddress:
  //           Get.find<AuthController>().profileModel!.macBillPrinterIp!);

  //   Future.delayed(Duration(seconds: 1), () async {
  //     if (result) {
  //       // List<int> ticket = await testTicket();
  //       await PrintBluetoothThermal.writeBytes(bytes);

  //       Future.delayed(
  //           Duration(
  //               seconds: bytes.length <= 5850
  //                   ? 2
  //                   : bytes.length <= 7890
  //                       ? 3
  //                       : bytes.length <= 10195
  //                           ? 6
  //                           : bytes.length <= 13100
  //                               ? 10
  //                               : bytes.length <= 21150
  //                                   ? 15
  //                                   : 20), () async {
  //         Get.find<LoadingController>().startLoading(false);

  //         await Get.find<LoadingController>()
  //             .changeText(data: 'Successfully printed!!');
  //         await Get.find<LoadingController>().changeStatus(data: true);
  //         var isDisconnect = await PrintBluetoothThermal.disconnect;
  //         print('is disconnect $isDisconnect');
  //       });
  //       print("print test result:  $result");
  //     } else {
  //       //no conectado, reconecte
  //       Get.find<LoadingController>().startLoading(false);

  //       await Get.find<LoadingController>()
  //           .changeText(data: 'Failed to bluetooth connect!!', error: true);
  //       await Get.find<LoadingController>().changeStatus(data: true);
  //       // showErrorToast('Failed to bluetooth connect');
  //     }
  //     // });
  //   });
  // }

  individualListenBluetooth() async {
    if (GetPlatform.isAndroid) {
      _singlePrintBtStatus =
          individualPrinter.stateBluetooth.listen((status) async {
        if (status == BTStatus.connecting) {}
        if (status == BTStatus.connected && pendingTask != null) {
          isConnect = true;
          if (mounted) setState(() {});

          Future.delayed(const Duration(milliseconds: 1000), () async {
            pendingTask = null;
          });
        } else if (status == BTStatus.none) {
          Get.find<LoadingController>().startLoading(false);

          await Get.find<LoadingController>()
              .changeText(data: 'Failed to bluetooth connect!!', error: true);
          await Get.find<LoadingController>().changeStatus(data: true);
        }
      });
    }
  }

  Widget nameTextField(BuildContext context) {
    return Container(
      height: 30,
      child: Get.find<PosController>().selectedPaymentTab == 3 &&
              Get.find<PosController>().tapManagmentCustomerListResponse != null
          ? TypeAheadField(
              getImmediateSuggestions: true,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _nameController,
                textInputAction: TextInputAction.search,
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  hintStyle:
                      poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
                  hintText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: poppinsMedium.copyWith(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              noItemsFoundBuilder: (context) => SizedBox.shrink(),
              suggestionsCallback: (pattern) async {
                return Get.find<PosController>()
                    .tapManagmentCustomerListResponse!
                    .employeeTapList
                    .where((item) => item.name
                        .toString()
                        .trim()
                        .toLowerCase()
                        .contains(pattern.toLowerCase().trim()))
                    .toList();
              },
              itemBuilder: (context, EmployeeTapList suggestion) {
                return Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Row(children: [
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${suggestion.name ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: poppinsRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  fontSize: Dimensions.FONT_SIZE_SMALL,
                                )),
                          ]),
                    ),
                  ]),
                );
              },
              onSuggestionSelected: (EmployeeTapList suggestion) {
                _phoneController.text = suggestion.mobile.toString();
                _nameController.text = suggestion.name;
                // emailController.text = suggestion.email;
                Get.find<PosController>().update();
              },
            )
          : TextField(
              controller: _nameController,
              textInputAction: TextInputAction.search,
              autofocus: false,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                hintStyle: poppinsSemiBold.copyWith(
                    fontSize: Dimensions.FONT_SIZE_SMALL, color: Colors.grey),
                filled: true,
                hintText: 'Name',
                fillColor: Theme.of(context).cardColor,
              ),
              style: poppinsSemiBold.copyWith(
                color: Colors.black,
                fontSize: Dimensions.FONT_SIZE_SMALL,
              ),
            ),
    );
  }

  Widget phoneTextField(BuildContext context) {
    return Container(
      height: 30,
      child: Get.find<PosController>().selectedPaymentTab == 3 &&
              Get.find<PosController>().tapManagmentCustomerListResponse != null
          ? TypeAheadField(
              getImmediateSuggestions: true,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _phoneController,
                textInputAction: TextInputAction.search,
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    borderSide: BorderSide(color: ColorTheme.borderGrey),
                  ),
                  hintStyle:
                      poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
                  hintText: 'Phone No.',
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: poppinsMedium.copyWith(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              noItemsFoundBuilder: (context) => SizedBox.shrink(),
              suggestionsCallback: (pattern) async {
                return Get.find<PosController>()
                    .tapManagmentCustomerListResponse!
                    .employeeTapList
                    .where((item) => item.mobile
                        .toString()
                        .trim()
                        .toLowerCase()
                        .contains(pattern.toLowerCase().trim()))
                    .toList();
              },
              itemBuilder: (context, EmployeeTapList suggestion) {
                return Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Row(children: [
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${suggestion.mobile ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: poppinsRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  fontSize: 13,
                                )),
                          ]),
                    ),
                  ]),
                );
              },
              onSuggestionSelected: (EmployeeTapList suggestion) {
                _phoneController.text = suggestion.mobile.toString();
                _nameController.text = suggestion.name;
                // emailController.text = suggestion.email;
                Get.find<PosController>().update();
              },
            )
          : TextField(
              controller: _phoneController,
              textInputAction: TextInputAction.search,
              autofocus: false,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp("[0-9,+]")),
              ],
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  borderSide: BorderSide(color: ColorTheme.borderGrey),
                ),
                hintStyle:
                    poppinsMedium.copyWith(fontSize: 13, color: Colors.grey),
                filled: true,
                hintText: 'Phone No.',
                fillColor: Colors.white,
              ),
              onChanged: (String d) async {
                if (_phoneController.text.isNotEmpty &&
                    _phoneController.text.length > 9) {
                  List<SearchCustomerResponseModel> searchData =
                      await Get.find<CartController>()
                          .searchWaiterPOSCustomer(_phoneController.text);
                  if (searchData.isNotEmpty && searchData.first.id != 'false') {
                    if (searchData.first.name != '')
                      _nameController.text = searchData.first.name;
                  }
                }
              },
              style: poppinsMedium.copyWith(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
    );
  }

  Widget editUserBottomSheet() {
    Get.find<CartController>().getCustomerFromApi();

    return GetBuilder<CartController>(builder: (cartController) {
      return cartController.isLoading
          ? CircularProgressIndicator()
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 25,
                  right: 25,
                  top: 25,
                  bottom: Dimensions.PADDING_SIZE_DEFAULT,
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Customer Detail',
                              style: poppinsMedium.copyWith(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: ColorTheme.borderGrey),
                      ),
                      SizedBox(height: 10),
                      cartController.customerList == null
                          ? TextField(
                              controller: _nameController,
                              autofocus: false,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: 'Name',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 15),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide:
                                      BorderSide(color: ColorTheme.borderGrey),
                                ),
                                hintStyle: poppinsMedium.copyWith(
                                    fontSize: 13, color: ColorTheme.hintText),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              style: poppinsMedium.copyWith(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            )
                          : TypeAheadField(
                              getImmediateSuggestions: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _nameController,
                                textInputAction: TextInputAction.search,
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 15),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_SMALL),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_SMALL),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_SMALL),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_SMALL),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  hintStyle: poppinsMedium.copyWith(
                                      fontSize: 13, color: Colors.grey),
                                  hintText: 'Name',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: poppinsMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              noItemsFoundBuilder: (context) =>
                                  SizedBox.shrink(),
                              suggestionsCallback: (pattern) async {
                                return cartController.customerList!.customerList
                                    .where((item) =>
                                        item.customerName != '' &&
                                        item.customerName
                                            .toString()
                                            .trim()
                                            .toLowerCase()
                                            .contains(
                                                pattern.toLowerCase().trim()))
                                    .toList();
                              },
                              itemBuilder: (context, CustomerList suggestion) {
                                return Padding(
                                  padding: EdgeInsets.all(
                                      Dimensions.PADDING_SIZE_SMALL),
                                  child: Row(children: [
                                    SizedBox(
                                        width: Dimensions.PADDING_SIZE_SMALL),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${suggestion.customerName ?? ''}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: poppinsRegular.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_SMALL,
                                                )),
                                          ]),
                                    ),
                                  ]),
                                );
                              },
                              onSuggestionSelected: (CustomerList suggestion) {
                                _phoneController.text =
                                    suggestion.phone.toString();
                                _nameController.text = suggestion.customerName;
                                // emailController.text = suggestion.email;
                                // Get.find<CartController>().update();
                              },
                            ),
                      SizedBox(height: 15),
                      Container(
                        height: 40,
                        child: cartController.customerList == null
                            ? TextField(
                                controller: _phoneController,
                                textInputAction: TextInputAction.search,
                                autofocus: false,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: true),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9,+]")),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Mobile Number',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 15),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide(
                                        color: ColorTheme.borderGrey),
                                  ),
                                  hintStyle: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (String d) async {
                                  if (_phoneController.text.isNotEmpty &&
                                      GetUtils.isPhoneNumber(
                                          _phoneController.text)) {
                                    List<SearchCustomerResponseModel>
                                        searchData =
                                        await Get.find<CartController>()
                                            .searchWaiterPOSCustomer(
                                                _phoneController.text);
                                    if (searchData.isNotEmpty &&
                                        searchData.first.id != 'false') {
                                      if (searchData.first.name != '')
                                        _nameController.text =
                                            searchData.first.name;
                                    }
                                  }
                                },
                                style: poppinsMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              )
                            : TypeAheadField(
                                getImmediateSuggestions: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _phoneController,
                                  textInputAction: TextInputAction.search,
                                  autofocus: false,
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9,+]")),
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.RADIUS_SMALL),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.RADIUS_SMALL),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.RADIUS_SMALL),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.RADIUS_SMALL),
                                      borderSide: BorderSide(
                                          color: ColorTheme.borderGrey),
                                    ),
                                    hintStyle: poppinsMedium.copyWith(
                                        fontSize: 13, color: Colors.grey),
                                    hintText: 'Phone Number',
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style: poppinsMedium.copyWith(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                                noItemsFoundBuilder: (context) =>
                                    SizedBox.shrink(),
                                suggestionsCallback: (pattern) async {
                                  return cartController
                                      .customerList!.customerList
                                      .where((item) =>
                                          item.phone != '' &&
                                          item.phone
                                              .toString()
                                              .trim()
                                              .toLowerCase()
                                              .contains(
                                                  pattern.toLowerCase().trim()))
                                      .toList();
                                },
                                itemBuilder:
                                    (context, CustomerList suggestion) {
                                  return Padding(
                                    padding: EdgeInsets.all(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    child: Row(children: [
                                      SizedBox(
                                          width: Dimensions.PADDING_SIZE_SMALL),
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('${suggestion.phone ?? ''}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      poppinsRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color,
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_SMALL,
                                                  )),
                                            ]),
                                      ),
                                    ]),
                                  );
                                },
                                onSuggestionSelected:
                                    (CustomerList suggestion) {
                                  _phoneController.text =
                                      suggestion.phone.toString();
                                  _nameController.text =
                                      suggestion.customerName;
                                  // emailController.text = suggestion.email;
                                  // Get.find<CartController>().update();
                                },
                              ),
                      ),
                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () async {
                            if (_nameController.text.isEmpty) {
                              showErrorToast('Please enter customer name');
                            } else if (_phoneController.text.isEmpty ||
                                _phoneController.text.isNotEmpty &&
                                    _phoneController.text.length < 10) {
                              showErrorToast('Please enter valid phone number');
                            } else {
                              //  print('...............$orderId');
                              await cartController.changeCustomerDetail({
                                "phone": _phoneController.text,
                                "f_name": _nameController.text,
                                "l_name": "",
                                "email": "",
                                "order_id": orderId
                              }, (bool value) {
                                Get.back();
                              });
                              //     .then((value) {

                              // });
                            }
                          },
                          child: Container(
                            height: 35,
                            width: 110,
                            decoration: BoxDecoration(
                              color: ColorTheme.appColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Submit',
                                style: poppinsMedium.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1600
                                          ? 18
                                          : 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
    });
  }
}
