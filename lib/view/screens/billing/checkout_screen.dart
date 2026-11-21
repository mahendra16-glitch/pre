import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/save_local_oreder_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/billing/collect_payment/payment_method.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/product_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/pos/widget/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';

import '../../../data/model/response/product_model.dart';

class BillingCheckOut extends StatefulWidget {
  final Function(bool) placeOrderEvent;
  final List<LocalOrderModel> orderList;
  const BillingCheckOut(
      {Key? key, required this.placeOrderEvent, required this.orderList})
      : super(key: key);

  @override
  State<BillingCheckOut> createState() => _BillingCheckOutState();
}

class _BillingCheckOutState extends State<BillingCheckOut> {
  double foodTotal = 0;
  bool showPlayer = false;
  String? audioPath;

  final TextEditingController _addNoteController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _addTips = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController changeController = TextEditingController();
  final TextEditingController _transactionNoController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DiscountCategoryListModel? selectedDiscount;
  double variationTotal = 0;
  double discountedOrderSubTotal = 0;
  double vatAmount = 0;

  bool isPrint = true;
  bool isConnect = true;
  int currentPrintIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController addNameController = TextEditingController();
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

  Future<void> initData() async {
    Get.find<CartController>().calculationCart();
    Get.find<PosController>().setPaymentTabIndex(0);
    Get.find<PosController>().setcollectItemPrice(0);

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
    amountCalculation();
    // Get.find<PosController>()
    //     .setcollectItemPrice(orderAmount + gstAmount + showServiceChargeValue);
    await generateOrderId();
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
              return cartController.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : cartController.cartList.length > 0
                      ? SingleChildScrollView(
                          controller: _scrollController,
                          reverse: true,
                          physics: BouncingScrollPhysics(),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 20, right: 20),
                                  child: TextField(
                                    controller: _addNoteController,
                                    autofocus: false,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: 'Add notes..'.tr,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.PADDING_SIZE_SMALL,
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: ColorTheme.borderGrey),
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      hintStyle: poppinsMedium.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .shortestSide >
                                                  570
                                              ? 15
                                              : 13,
                                          color: ColorTheme.hintText),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: poppinsMedium.copyWith(
                                      color: Colors.black,
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 13,
                                    ),
                                    onChanged: (value) async {},
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(color: ColorTheme.borderGrey),
                                ),

                                // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                                // Product
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
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
                                        return 
                                        productWidget(
                                          onIncrease: (data) {
                                            if (data != null && data) {
                                              Future.delayed(
                                                  Duration(microseconds: 300),
                                                  () {
                                                amountCalculation();
                                              });
                                            }
                                          },
                                          variationTotal: variationTotal,
                                          cart: cartController.cartList[index],
                                          cartIndex: index,
                                          addOns:
                                              cartController.addOnsList[index],
                                          isAvailable: cartController
                                              .availableList[index],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20, top: 15),
                                  child: Text('Customer Details',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText)),
                                ),

                                Container(
                                  margin: EdgeInsets.only(
                                      top: 15, left: 20, right: 20),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: ColorTheme.productCard,
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_LARGE),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: TextField(
                                          controller: _nameController,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          decoration: InputDecoration(
                                            hintText: 'Name',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 15),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            hintStyle: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          style: poppinsMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),

                                      Container(
                                        height: 40,
                                        child: TextField(
                                          controller: _phoneController,
                                          textInputAction:
                                              TextInputAction.search,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[0-9,+]")),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: 'Mobile Number',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0,
                                                    horizontal: 15),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              borderSide: BorderSide(
                                                  color: ColorTheme.borderGrey),
                                            ),
                                            hintStyle: poppinsMedium.copyWith(
                                                fontSize: 13,
                                                color: ColorTheme.hintText),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          onChanged: (String d) async {},
                                          style: poppinsMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_SMALL),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        child: DottedLine(
                                          direction: Axis.horizontal,
                                          alignment: WrapAlignment.center,
                                          lineThickness: 1.0,
                                          dashLength: 2.5,
                                          dashColor: ColorTheme.hintText,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text('Sub Total'.tr,
                                                  textAlign: TextAlign.right,
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11)),
                                              Text(
                                                  ' :   ' +
                                                      PriceConverter
                                                          .convertPrice(
                                                              orderSubTotal,
                                                              isHideCurrency:
                                                                  true,
                                                              asFixed: 2),
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11)),
                                            ]),
                                      ),

                                      // if (coummunityDiscount != 0)
                                      //   Padding(
                                      //     padding: const EdgeInsets.only(
                                      //         right: 15, top: 5),
                                      //     child: Row(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.end,
                                      //         children: [
                                      //           Text('Community Discount'.tr,
                                      //               textAlign: TextAlign.right,
                                      //               style: poppinsMedium.copyWith(
                                      //                   fontSize: MediaQuery.of(
                                      //                                   context)
                                      //                               .size
                                      //                               .shortestSide >
                                      //                           570
                                      //                       ? 15
                                      //                       : 11)),
                                      //           Text(
                                      //               ' :   ' +
                                      //                   PriceConverter
                                      //                       .convertPrice(
                                      //                           coummunityDiscount,
                                      //                           isHideCurrency:
                                      //                               true,
                                      //                           asFixed: 2),
                                      //               style: poppinsMedium.copyWith(
                                      //                   fontSize: MediaQuery.of(
                                      //                                   context)
                                      //                               .size
                                      //                               .shortestSide >
                                      //                           570
                                      //                       ? 15
                                      //                       : 11)),
                                      //         ]),
                                      //   ),

                                      // SizedBox(height: 10),
                                      if (Get.find<AuthController>()
                                                  .profileModel!
                                                  .restaurants!
                                                  .first
                                                  .discountType ==
                                              'Percent' &&
                                          Get.find<AuthController>()
                                                  .profileModel!
                                                  .discountList !=
                                              null &&
                                          Get.find<AuthController>()
                                              .profileModel!
                                              .discountList!
                                              .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15, top: 10),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                    'Discount Type'
                                                    ' : ',
                                                    textAlign: TextAlign.right,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                    )),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 7),
                                                  width: Get.width * 0.35,
                                                  height: MediaQuery.of(context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 40
                                                      : 25,
                                                  child: DropdownButton<
                                                      DiscountCategoryListModel>(
                                                    isExpanded: true,
                                                    underline:
                                                        SizedBox.shrink(),
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                    ),
                                                    value: selectedDiscount,
                                                    hint: Text("Discount"),
                                                    onChanged:
                                                        (DiscountCategoryListModel?
                                                            newValue) {
                                                      selectedDiscount =
                                                          newValue;
                                                      _discountController.text =
                                                          newValue!.discount!;
                                                      amountCalculation();
                                                      posController.update();
                                                      // setState(() {
                                                      //   selectedCategory = newValue;
                                                      // });
                                                    },
                                                    items: Get.find<
                                                            AuthController>()
                                                        .profileModel!
                                                        .discountList!
                                                        .map<
                                                            DropdownMenuItem<
                                                                DiscountCategoryListModel>>(
                                                      (DiscountCategoryListModel
                                                          category) {
                                                        return DropdownMenuItem<
                                                            DiscountCategoryListModel>(
                                                          value: category,
                                                          child: Text(category
                                                              .discountType!),
                                                        );
                                                      },
                                                    ).toList(),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      border: Border.all(
                                                          color: ColorTheme
                                                              .borderGrey)),
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
                                          padding: const EdgeInsets.only(
                                              right: 15, top: 10),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                    Get.find<AuthController>()
                                                            .profileModel!
                                                            .restaurants!
                                                            .first
                                                            .discountText! +
                                                        ' : ',
                                                    textAlign: TextAlign.right,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                    )),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  width: Get.width * 0.2,
                                                  height: MediaQuery.of(context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 40
                                                      : 25,
                                                  child: TextField(
                                                    controller:
                                                        _discountController,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            signed: true),
                                                    autofocus: false,
                                                    decoration: InputDecoration(
                                                      // hintText: 'phone'.tr,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: Dimensions
                                                                  .PADDING_SIZE_EXTRA_SMALL),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        borderSide: BorderSide(
                                                            style: BorderStyle
                                                                .none,
                                                            width: 0),
                                                      ),
                                                      hintStyle: poppinsMedium.copyWith(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .shortestSide >
                                                                  570
                                                              ? 15
                                                              : 11,
                                                          color: ColorTheme
                                                              .hintText),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                    ),
                                                    onChanged: (value) async {
                                                      amountCalculation();
                                                    },
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      border: Border.all(
                                                          color: ColorTheme
                                                              .borderGrey)),
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
                                          padding: const EdgeInsets.only(
                                              right: 15, top: 10),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text('Add tips : ',
                                                    textAlign: TextAlign.right,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                    )),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  width: Get.width * 0.2,
                                                  height: MediaQuery.of(context)
                                                              .size
                                                              .shortestSide >
                                                          570
                                                      ? 40
                                                      : 25,
                                                  child: TextField(
                                                    controller: _addTips,
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            signed: true),
                                                    autofocus: false,
                                                    decoration: InputDecoration(
                                                      // hintText: 'phone'.tr,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: Dimensions
                                                                  .PADDING_SIZE_EXTRA_SMALL),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        borderSide: BorderSide(
                                                            style: BorderStyle
                                                                .none,
                                                            width: 0),
                                                      ),
                                                      hintStyle: poppinsMedium.copyWith(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .shortestSide >
                                                                  570
                                                              ? 15
                                                              : 11,
                                                          color: ColorTheme
                                                              .hintText),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                    ),
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                    ),
                                                    onChanged: (value) async {
                                                      amountCalculation();
                                                    },
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      border: Border.all(
                                                          color: ColorTheme
                                                              .borderGrey)),
                                                ),
                                              ]),
                                        ),
                                      if (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .serviceCharge ==
                                          'Yes')
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Checkbox(
                                                    value: posController
                                                        .isAddServiceCharge,
                                                    onChanged: (val) {
                                                      posController
                                                          .changeServeiceChargeValue(
                                                              val!);
                                                      amountCalculation();
                                                    }),
                                                Text(
                                                    '${Get.find<AuthController>().profileModel!.restaurants!.first.settings?.serviceChrgTaxt}',
                                                    textAlign: TextAlign.right,
                                                    style:
                                                        poppinsMedium.copyWith(
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 15
                                                          : 11,
                                                    )),
                                                Text(
                                                    ' :  ${PriceConverter.convertPrice(showServiceChargeValue, isHideCurrency: true)}',
                                                    style: poppinsMedium.copyWith(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .shortestSide >
                                                                570
                                                            ? 15
                                                            : 11)),
                                              ]),
                                        ),
                                      if (gstAmount != 0)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 15, top: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text('CGST'.tr,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .shortestSide >
                                                                  570
                                                              ? 15
                                                              : 11,
                                                        )),
                                                    Text(
                                                        ' :   ${(gstAmount / 2).toStringAsFixed(2)}',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
                                                                    570
                                                                ? 15
                                                                : 11)),
                                                  ]),
                                              SizedBox(height: 10),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text('SGST'.tr,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .shortestSide >
                                                                  570
                                                              ? 15
                                                              : 11,
                                                        )),
                                                    Text(
                                                        ' :   ${(gstAmount / 2).toStringAsFixed(2)}',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
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
                                        padding: const EdgeInsets.only(
                                            right: 15, top: 20),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text('Total'.tr,
                                                  textAlign: TextAlign.right,
                                                  style: poppinsBold.copyWith(
                                                    color: ColorTheme.green,
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 17
                                                        : 14,
                                                  )),
                                              Text(
                                                  ' :  ' +
                                                      PriceConverter.convertPrice(
                                                          (posController
                                                              .collectItemPrice),
                                                          isHideCurrency: true,
                                                          asFixed: 2),
                                                  style: poppinsBold.copyWith(
                                                      color: ColorTheme.green,
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .shortestSide >
                                                              570
                                                          ? 17
                                                          : 14)),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                                BillingPaymentMethod(
                                  orderDiscount: orderDiscount,
                                  serviceChargeValue: showServiceChargeValue,
                                  noteController: _addNoteController,
                                  orderId: orderId,
                                  posController: Get.find<PosController>(),
                                  placeOrderEvent: (data) async {
                                    if (data != null && data) {
                                      widget.placeOrderEvent(true);
                                    }
                                  },
                                  tipsController: _addTips,
                                  printerManager: individualPrinter,
                                  isPrint: isPrint,
                                  discountController:
                                      _discountController.text.isEmpty
                                          ? TextEditingController(text: '0')
                                          : _discountController,
                                  gstAmount: gstAmount,
                                  nameController: _nameController,
                                  orderSubTotal: cartController.subTotal,
                                  orderTotal: discountedOrderSubTotal,
                                  phoneController: _phoneController,
                                  changeController: changeController,
                                  paidController: paidController,
                                  transactionNoController:
                                      _transactionNoController,
                                  pendingTask: pendingTask ?? [],
                                )
                              ]),
                        )
                      : Center(child: Text('no_food_available'.tr));
            },
          );
        }),
      ),
    );
  }

  // calculationAmount(CartController cartController) {
  //   double orderAmount = cartController.subTotal;
  //   if (_discountController.text.isEmpty || _discountController.text == '0') {
  //     gstTaxPercentage =
  //         Get.find<AuthController>().profileModel.restaurants.first.gstTax;
  //     gstAmount = (orderAmount * gstTaxPercentage / 100);
  //   } else {
  //     double tempDiscountPercent = 0;

  //     if (Get.find<AuthController>()
  //             .profileModel
  //             .restaurants
  //             .first
  //             .discountType ==
  //         'Fixed') {
  //       if (orderAmount == 0) {
  //         tempDiscountPercent = 0;
  //       } else {
  //         tempDiscountPercent =
  //             ((double.parse(_discountController.text)) * 100) /
  //                 orderAmount;
  //       }
  //     } else {
  //       tempDiscountPercent = double.parse(_discountController.text);
  //     }
  //   }

  //   Get.find<PosController>().setcollectItemPrice(orderAmount + gstAmount);
  // }
  void amountCalculation() {
    orderSubTotal = 0;
    discountedOrderSubTotal = 0;
    orderDiscount = 0;
    gstAmount = 0;
    vatAmount = 0;
    showServiceChargeValue = 0;
    double gstTypeFood = 0;
    double vatTypeFood = 0;
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    if (restaurant.discountType == 'Percent' &&
        _discountController.text.isNotEmpty &&
        double.parse(_discountController.text) > 100) {
      showErrorToast('Please enter valid discount');
    } else {
      for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
        CartModel cart = Get.find<CartController>().cartList[i];

        double variationTotal = 0;
        double addonsTotal = 0;
        double foodAmount = 0;
        List<int> ids = [];
        List<int> qtys = [];
        int index0 = 0;

        for (var addOn in cart.addOnIds) {
          ids.add(addOn.id);
          qtys.add(addOn.quantity);
        }
        for (var addOn in cart.product.addOns!) {
          if (ids.contains(addOn.id)) {
            addonsTotal = addonsTotal + (addOn.price! * qtys[index0]);
            index0 = index0 + 1;
          }
        }
        if (cart.variation.isNotEmpty) {
          for (int index = 0; index < cart.variation.length; index++) {
            if (cart.variation[index].isNotEmpty &&
                cart.variation[index].contains(true)) {
              for (int i = 0; i < cart.variation[index].length; i++) {
                if (cart.variation[index][i]) {
                  variationTotal += (double.parse(cart
                          .product.variations![index].values![i].optionPrice!) *
                      cart.quantity);
                }
              }
            }
          }
        }
        orderSubTotal = orderSubTotal +
            (cart.discountedPrice * cart.quantity) +
            variationTotal +
            addonsTotal;
        foodAmount = (cart.discountedPrice * cart.quantity) +
            variationTotal +
            addonsTotal;
        if (restaurant.discountType == 'Percent') {
          double tempDiscountPercent = _discountController.text.isEmpty
              ? 0
              : double.parse(_discountController.text ?? '0');
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
              gstAmount = gstAmount +
                  ((tempAmount * double.parse(cart.product.tax.toString())) /
                      100);
            }
            discountedOrderSubTotal = discountedOrderSubTotal + tempAmount;
          } else if (cart.product.taxType.toString() == 'VAT') {
            if (Get.find<AuthController>().profileModel!.vatInfo!.status ==
                'true') {
              vatAmount = vatAmount +
                  ((tempAmount * double.parse(cart.product.tax.toString())) /
                      100);
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
      if (restaurant.discountType == 'No' ||
          restaurant.discountType == 'Fixed') {
        double tempFoodAmount = 0;
        double tempBarAmount = 0;
        double tempDiscountPercent = _discountController.text.isEmpty
            ? 0
            : double.parse(_discountController.text ?? '0') == 0
                ? 0
                : ((double.parse(_discountController.text) / gstTypeFood +
                        vatTypeFood) *
                    100);
        tempBarAmount =
            vatTypeFood - ((vatTypeFood * tempDiscountPercent) / 100);
        tempFoodAmount =
            gstTypeFood - ((gstTypeFood * tempDiscountPercent) / 100);
        orderDiscount = ((gstTypeFood * tempDiscountPercent) / 100) +
            ((vatTypeFood * tempDiscountPercent) / 100);
        discountedOrderSubTotal = tempBarAmount + tempFoodAmount;
        if (restaurant.gstStatus == 'true') {
          gstAmount = gstAmount + ((tempFoodAmount * restaurant.gstTax!) / 100);
        }

        if (Get.find<AuthController>().profileModel!.vatInfo!.status! ==
            'true') {
          vatAmount = vatAmount + ((tempBarAmount * restaurant.tax!) / 100);
        }
      }

      if (discountedOrderSubTotal >= 0) {
        ////final calculation for addition of gst, vat, service charge
        if (Get.find<PosController>().isAddServiceCharge) {
          showServiceChargeValue =
              (discountedOrderSubTotal * serviceChargePercentage) / 100;
          Get.find<PosController>().setcollectItemPrice(
              discountedOrderSubTotal +
                  (discountedOrderSubTotal * serviceChargePercentage / 100) +
                  gstAmount +
                  vatAmount +
                  (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
        } else {
          Get.find<PosController>().setcollectItemPrice(
              discountedOrderSubTotal +
                  gstAmount +
                  vatAmount +
                  (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
        }
      } else {
        showErrorToast('Please enter valid discount');
      }
    }

    if (mounted) setState(() {});
  }

  // void discountCalculator() {
  //   orderSubTotal = 0;
  //   discountedOrderSubTotal = 0;
  //   gstAmount = 0;
  //   vatAmount = 0;
  //   orderDiscount = 0;
  //   showServiceChargeValue = 0;
  //   if (_discountController.text.isEmpty) {
  //     for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
  //       CartModel cart = Get.find<CartController>().cartList[i];

  //       double variationTotal = 0;
  //       double addonsTotal = 0;
  //       double foodAmount = 0;
  //       List<int> ids = [];
  //       List<int> qtys = [];
  //       int index0 = 0;

  //       for (var addOn in cart.addOnIds) {
  //         ids.add(addOn.id);
  //         qtys.add(addOn.quantity);
  //       }
  //       for (var addOn in cart.product.addOns) {
  //         if (ids.contains(addOn.id)) {
  //           addonsTotal = addonsTotal + (addOn.price * qtys[index0]);
  //           index0 = index0 + 1;
  //         }
  //       }
  //       if (cart.variation.isNotEmpty) {
  //         for (int index = 0; index < cart.variation.length; index++) {
  //           if (cart.variation[index].isNotEmpty &&
  //               cart.variation[index].contains(true)) {
  //             for (int i = 0; i < cart.variation[index].length; i++) {
  //               if (cart.variation[index][i]) {
  //                 variationTotal += (double.parse(cart
  //                         .product.variations[index].values[i].optionPrice) *
  //                     cart.quantity);
  //               }
  //             }
  //           }
  //         }
  //       }
  //       foodAmount = (cart.discountedPrice * cart.quantity) +
  //           variationTotal +
  //           addonsTotal;
  //       orderSubTotal = orderSubTotal + foodAmount;
  //       double tempFoodAmount =
  //           foodAmount - (foodAmount * coummunityDiscountPercentage / 100);

  //       discountedOrderSubTotal = discountedOrderSubTotal + tempFoodAmount;
  //       if (Get.find<AuthController>()
  //                   .profileModel
  //                   .restaurants
  //                   .first
  //                   .gstStatus ==
  //               'true' &&
  //           cart.product.taxType == 'GST' &&
  //           cart.product.taxCalculate == 'Exclusive')
  //         gstAmount = gstAmount + ((tempFoodAmount * cart.product.tax) / 100);
  //       if (Get.find<AuthController>()
  //                   .profileModel
  //                   .restaurants
  //                   .first
  //                   .gstStatus ==
  //               'true' &&
  //           cart.product.taxType == 'VAT' &&
  //           cart.product.taxCalculate == 'Exclusive')
  //         vatAmount = vatAmount + ((tempFoodAmount * cart.product.tax) / 100);
  //     }

  //     ////final
  //     if (Get.find<PosController>().isAddServiceCharge) {
  //       showServiceChargeValue =
  //           (discountedOrderSubTotal * serviceChargePercentage) / 100;
  //       Get.find<PosController>().setcollectItemPrice(discountedOrderSubTotal +
  //           (discountedOrderSubTotal * serviceChargePercentage / 100) +
  //           gstAmount +
  //           vatAmount +
  //           (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
  //     } else {
  //       Get.find<PosController>().setcollectItemPrice(discountedOrderSubTotal +
  //           gstAmount +
  //           vatAmount +
  //           (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
  //     }
  //   } else {
  //     for (var i = 0; i < Get.find<CartController>().cartList.length; i++) {
  //       CartModel cart = Get.find<CartController>().cartList[i];

  //       double variationTotal = 0;
  //       double tempDiscountPercent = 0;
  //       double addonsTotal = 0;
  //       double foodAmount = 0;
  //       List<int> ids = [];
  //       List<int> qtys = [];
  //       int index0 = 0;

  //       for (var addOn in cart.addOnIds) {
  //         ids.add(addOn.id);
  //         qtys.add(addOn.quantity);
  //       }
  //       for (var addOn in cart.product.addOns) {
  //         if (ids.contains(addOn.id)) {
  //           addonsTotal = addonsTotal + (addOn.price * qtys[index0]);
  //           index0 = index0 + 1;
  //         }
  //       }
  //       if (cart.variation.isNotEmpty) {
  //         for (int index = 0; index < cart.variation.length; index++) {
  //           if (cart.variation[index].isNotEmpty &&
  //               cart.variation[index].contains(true)) {
  //             for (int i = 0; i < cart.variation[index].length; i++) {
  //               if (cart.variation[index][i]) {
  //                 variationTotal += double.parse(cart
  //                         .product.variations[index].values[i].optionPrice) *
  //                     cart.quantity;
  //               }
  //             }
  //           }
  //         }
  //       }
  //       foodAmount = (cart.discountedPrice * cart.quantity) +
  //           variationTotal +
  //           addonsTotal;
  //       orderSubTotal = orderSubTotal + foodAmount;

  //       if (Get.find<AuthController>()
  //               .profileModel
  //               .restaurants
  //               .first
  //               .discountType ==
  //           'Fixed') {
  //         if (foodAmount == 0) {
  //           tempDiscountPercent = 0;
  //         } else {
  //           tempDiscountPercent =
  //               (double.parse(_discountController.text) / foodAmount) * 100;
  //         }
  //       } else {
  //         tempDiscountPercent = double.parse(_discountController.text);
  //       }
  //       orderDiscount = orderDiscount +
  //           (foodAmount *
  //               (coummunityDiscountPercentage + tempDiscountPercent) /
  //               100);
  //       double tempFoodAmount = foodAmount -
  //           (foodAmount *
  //               (coummunityDiscountPercentage + tempDiscountPercent) /
  //               100);

  //       discountedOrderSubTotal = discountedOrderSubTotal + tempFoodAmount;
  //       if (Get.find<AuthController>()
  //                   .profileModel
  //                   .restaurants
  //                   .first
  //                   .gstStatus ==
  //               'true' &&
  //           cart.product.taxType == 'GST' &&
  //           cart.product.taxCalculate == 'Exclusive')
  //         gstAmount = gstAmount + ((tempFoodAmount * cart.product.tax) / 100);
  //       if (Get.find<AuthController>()
  //                   .profileModel
  //                   .restaurants
  //                   .first
  //                   .gstStatus ==
  //               'true' &&
  //           cart.product.taxType == 'VAT' &&
  //           cart.product.taxCalculate == 'Exclusive')
  //         vatAmount = vatAmount + ((tempFoodAmount * cart.product.tax) / 100);

  //       print('-----$tempFoodAmount');
  //       print('------discountedOrderSubTotal---$discountedOrderSubTotal');
  //     }
  //     if (mounted) setState(() {});

  //     if (discountedOrderSubTotal >= 0) {
  //       ////final
  //       if (Get.find<PosController>().isAddServiceCharge) {
  //         showServiceChargeValue =
  //             (discountedOrderSubTotal * serviceChargePercentage) / 100;
  //         Get.find<PosController>().setcollectItemPrice(
  //             discountedOrderSubTotal +
  //                 (discountedOrderSubTotal * serviceChargePercentage / 100) +
  //                 gstAmount +
  //                 vatAmount +
  //                 (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
  //       } else {
  //         Get.find<PosController>().setcollectItemPrice(
  //             discountedOrderSubTotal +
  //                 gstAmount +
  //                 vatAmount +
  //                 (_addTips.text.isEmpty ? 0 : double.parse(_addTips.text)));
  //       }
  //     } else {
  //       showErrorToast('Please enter valid discount');
  //     }
  //   }
  // }

  Widget productWidget({
    required CartModel cart,
    required int cartIndex,
    required List<AddOns> addOns,
    required bool isAvailable,
    required double variationTotal,
    required Function onIncrease,
  }) {
    String addOnText = '';
    double addonsTotal = 0;
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
              variationTotal += double.parse(
                  cart.product.variations![index].values![i].optionPrice!);
              // print(variationTotal);
              variationText +=
                  '${variationText.endsWith('(') ? '' : ', '}${cart.product.variations![index].values![i].level}';
            }
          }
          variationText += ')';
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
                              onIncrease(true);
                            }
                          },
                          product: cart.product,
                          cartIndex: cartIndex,
                          cart: cart),
                    ),
                    // backgroundColor: Colors.transparent,
                    // isScrollControlled: true,
                    // ignoreSafeArea: false
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
                              onIncrease(true);
                            }
                          },
                          product: cart.product,
                          cartIndex: cartIndex,
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
                              cart.product.name!,
                              style: poppinsSemiBold.copyWith(
                                  color: Colors.black, fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (cart.product.description != '')
                              const SizedBox(height: 2),
                            if (cart.product.description != '')
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
                                textDirection: TextDirection.ltr,
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
                                              .removeFromCart(cartIndex);
                                          if (Get.find<CartController>()
                                              .cartList
                                              .isEmpty) {
                                            Navigator.pop(context);
                                          }
                                        }
                                        onIncrease(true);
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
                                          Get.find<CartController>()
                                              .setQuantity(true, cart);
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

  generateOrderId() async {
    ProfileModel profileModel = Get.find<AuthController>().profileModel!;
    String? lastOrderIdFromLocal =
        await Get.find<CartController>().getLastOrderIdFromLocal();
    int newId = 0;
    if (widget.orderList.isEmpty) {
      if (lastOrderIdFromLocal != '') {
        newId = int.parse(lastOrderIdFromLocal!.split('/').last) + 1;
      } else if (profileModel.lastOrderId == '') {
        newId = 1;
      } else {
        newId = int.parse(profileModel.lastOrderId!.split('/').last) + 1;
      }
    } else {
      newId = int.parse(widget.orderList.last.orderId.split('/').last) + 1;
    }
    String newOrderId = newId.toString().padLeft(6, '0');

    orderId =
        '${profileModel.restaurants!.first.id}/${profileModel.empId}/$newOrderId';
    print(orderId);
    if (mounted) setState(() {});
  }
}
