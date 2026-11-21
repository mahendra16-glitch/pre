import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/edit_walkin_order_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/get_waiter_order_list_response.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';

import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/waiter/walkIn/widget/walk_in_edit_cart_product.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkInEditOrder extends StatefulWidget {
  final OrderList editOrder;
  const WalkInEditOrder({required this.editOrder});

  @override
  State<WalkInEditOrder> createState() => _WalkInEditOrderState();
}

class _WalkInEditOrderState extends State<WalkInEditOrder> {
  // String _port = '9100';
  double foodTotal = 0;
  double coummunityDiscountPercentage = 0;
  double variationTotal = 0;
  bool isPrintKot = false;
  double gstAmount = 0;
  double vatAmount = 0;
  double gstTaxPercentage = 0;
  double orderSubTotal = 0;
  double discountedOrderSubTotal = 0;
  double orderItemTotal = 0;
  double showServiceChargeValue = 0;
  double serviceChargePercentage = 0;
  double gstServiceChargeTax = 0;
  List<Map<String, dynamic>> jsonCartList = [];
  String selectedDiscountType='No';

double deliveryCharge=0;
  // final TextEditingController _nameController = TextEditingController();
  TextEditingController _addNoteController = TextEditingController();
  TextEditingController _discountController = TextEditingController(text: '0');
  // PrinterManager _printerManager = PrinterManager.instance;
  // StreamSubscription<BTStatus> _subscriptionBtStatus;
  // List<int> pendingTask;
  // BTStatus _currentStatus = BTStatus.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
                  discountCalculator();

      if (Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .printKot ==
          'Yes') {
        if (mounted)
          setState(() {
            isPrintKot = true; // Example: Set the initial state
          });
      }
    });
    // _subscriptionBtStatus =
    //     PrinterManager.instance.stateBluetooth.listen((status) {
    //   log(' ----------------- status bt $status ------------------ ');
    //   _currentStatus = status;

    //   if (status == BTStatus.connected && pendingTask != null) {
    //     if (Platform.isAndroid) {
    //       Future.delayed(const Duration(milliseconds: 1000), () async {
    //         PrinterManager.instance
    //             .send(type: PrinterType.bluetooth, bytes: pendingTask);
    //         pendingTask = null;
    //       });
    //     } else if (Platform.isIOS) {
    //       PrinterManager.instance
    //           .send(type: PrinterType.bluetooth, bytes: pendingTask);
    //       pendingTask = null;
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    // _subscriptionBtStatus?.cancel();
    super.dispose();
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
                  height: Get.height / 10.72,
                )
              : Image.asset(
                  logoHelper.appLogo!,
                  width: Get.width * 0.25,
                ),
        ),
        body: SafeArea(
          child: GetBuilder<CartController>(
                builder: (c) {
              return GetBuilder<EditWalkInOrderController>(
                builder: (cartController) {
                  return c.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : cartController.cartList.length > 0
                          ? SingleChildScrollView(
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
                                    // Product
                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: cartController.cartList.length,
                                      itemBuilder: (context, index) {
                                        return WalkInEditCartProductWidget(
                                          variationTotal: variationTotal,
                                          cart: cartController.cartList[index],
                                          cartIndex: index,
                                          addOns: cartController.addOnsList[index],
                                          isAvailable:
                                              cartController.availableList[index],
                                        );
                                        // return PosProductWidget(
                                        //   cart: posController
                                        //       .cartList[index],
                                        //   cartIndex: index,
                                        //   addOns: _addOnsList[index],
                                        //   isAvailable:
                                        //       _availableList[index],
                                        // );
                                      },
                                    ),
                                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          
                          Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              children: [
                               Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                            Text('Item Total',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11)),
                                            Text(
                                                ' :   ' +
                              PriceConverter.convertPrice(orderItemTotal,
                                  isHideCurrency: true, asFixed: 2),
                                                style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11)),
                            
                            
                                          ]),
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
                            '${Get.find<AuthController>().profileModel!.restaurants!.first.settings!.serviceChrgTaxt}',
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
                                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                            Text('Sub Total',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11)),
                                            Text(
                                                ' :   ' +
                              PriceConverter.convertPrice(
                                  orderSubTotal +
                                      deliveryCharge +
                                      showServiceChargeValue 
                                    ,
                                  isHideCurrency: true,
                                  asFixed: 2),
                                                style: poppinsMedium.copyWith(
                              fontSize: MediaQuery.of(context).size.shortestSide > 570
                                  ? 15
                                  : 11)),
                                          ]),
                                          if ((gstAmount  + gstServiceChargeTax) != 0)
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
                              Text(
                                  ' :   ${((gstAmount  + gstServiceChargeTax) / 2).toStringAsFixed(2)}',
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
                              Text(
                                  ' :   ${((gstAmount  + gstServiceChargeTax) / 2).toStringAsFixed(2)}',
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
                                          if (vatAmount != 0)
                                            Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Column(
                                                children: [
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              Text('VAT',
                                  textAlign: TextAlign.right,
                                  style: poppinsMedium.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.shortestSide > 570
                                            ? 15
                                            : 11,
                                  )),
                              Text(' :   ${((vatAmount)).toStringAsFixed(2)}',
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
                              Text(
                                  ' :   ${((gstAmount  + gstServiceChargeTax) / 2).toStringAsFixed(2)}',
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
                                        
                            
                              ],
                            ),
                          ),
               
              
                                  ]),
                            )
                          : Center(child: Text('no_food_available'.tr));
                },
              );
            }
          ),
        ),
        bottomNavigationBar:
         GetBuilder<CartController>(builder: (c) {
                return GetBuilder<EditWalkInOrderController>(builder: (cartController) {
                          return c.isLoading
                  ? SizedBox(height: 2)
                  : cartController.cartList.isNotEmpty
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
                                          '${'Item'}: ${cartController.cartList.length}',
                                          style: poppinsMedium.copyWith(
                                              color: ColorTheme.blue,
                                              fontSize: 11)),
                                      // if (deliveryCharge != 0)
                                      //   const SizedBox(
                                      //       height: Dimensions
                                      //           .PADDING_SIZE_EXTRA_SMALL),
                                      // if (deliveryCharge != 0)
                                      //   Text('Delivery charge: $deliveryCharge',
                                      //       style: poppinsMedium.copyWith(
                                      //           color: ColorTheme.blue,
                                      //           fontSize: 11)),
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
                                          'Rs. ${PriceConverter.convertPrice(Get.find<PosController>().collectItemPrice, isHideCurrency: true)}',
                                          style: poppinsSemiBold.copyWith(
                                              fontSize: 15, color: Colors.black),
                                        ),
                                    ]),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      child: Checkbox(
                                        value: isPrintKot,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isPrintKot = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    Text(
                                      "Print KOT",
                                      style: poppinsMedium.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async {
                                    // await amountCalculation();
                                    // Get.find<EditWalkInOrderController>()
                                    //     .placeOrder(
                                    //         '',
                                    //         widget.editOrder.userName,
                                    //         _addNoteController.text.isEmpty
                                    //             ? ''
                                    //             : _addNoteController.text,
                                    //         PriceConverter.convertPrice(
                                    //             cartController.calculationCart(),
                                    //             isHideCurrency: true),
                                    //         widget.editOrder.orderType!,
                                    //         callback,
                                    //         isPrintKot: isPrintKot,
                                    //         tableId:
                                    //             widget.editOrder.tableId.toString(),
                                    //         order: widget.editOrder,
                                    //         gstTax: gstAmount,
                                    //         vatTax: vatAmount,
                                    //         orderId:
                                    //             widget.editOrder.id.toString());
                
                                    placeOrderFunction();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                        vertical: 6),
                                    decoration: BoxDecoration(
                                        color: ColorTheme.appColor,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      'Place Order',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ]),
                        ))
                      : const SizedBox();
                        });
              }
            ));
  }

  placeOrderFunction()async{
      double orderPay = Get.find<PosController>().collectItemPrice;

    Map<String, dynamic> jsonbody = {
     'order_id': widget.editOrder.id.toString()
   ,

      "payment_method":  'pending',
          
      "order_sub_total_without_tax": orderSubTotal +
          deliveryCharge +
          showServiceChargeValue 
         ,

      "paid_room":  '',
      "payment_status":widget.editOrder.paymentStatus, // "sucess", //paid, unpaid
      "tip_tax_amount": 0,
      "service_gst_tax_amount": gstServiceChargeTax,
      "cust_email": "",
      "payment_type": widget.editOrder.paymentType,
      "discount_type":
          '',
      "order_note":
          _addNoteController.text.isEmpty ? '' : _addNoteController.text,

      'delivery_charge': '$deliveryCharge',
      'use_wallet_balance':
0,
      "tax_amount": gstAmount + vatAmount + gstServiceChargeTax ,
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
      'gst_tax': gstAmount  + gstServiceChargeTax,

   
      'print_kot': isPrintKot ? 'Yes' : 'No',

      'self_discount': 0,
      'coupon_discount': 0,
      'coupon_title':  '',
      'coupon_type':  '',
      'round_up': getRoundUpAmount(orderPay),

      'order_type': widget.editOrder.orderType,
      'tip_amount': 0,
      'order_discount': 0,
    
      'service_tax': Get.find<PosController>().isAddServiceCharge
          ? showServiceChargeValue
          : 0,
  
      'room_id': '${Get.find<PosController>().selectedRoom?.table?.id ?? ''}',
      'auto_dispatch': Get.find<AuthController>()
              .profileModel!
              .restaurants
              ?.first
              .settings
              ?.autoDispatch ??
          'No',
      'discount_member_category_id':
          0,
      'discount_member_category_name':
          '',
      "usage_id": "",
     
    };
     await Get.find<CartController>().newPlaceOrder(callback,
          jsonBody: jsonbody,
          jsonFoodList: jsonCartList,
          isUpdate: true);
  }

  List<CartModel> barList = [];
  List<CartModel> kdsList = [];

  void callback(bool isSuccess, String message, String orderID) async {
    if (isSuccess) {
      // Get.offNamed(RouteHelper.getWaiterDashboardInitialRoute());
      // Get.until((route) =>
      //     route.settings.name == RouteHelper.getWaiterDashboardInitialRoute());
      if (GetPlatform.isWindows ||
          MediaQuery.of(context).size.shortestSide > 570) {
        Get.offNamed(RouteHelper.getTableViewHomeRoute());
        // Get.offNamed(RouteHelper.getTablateWaiterDashboardInitialRoute());
      } else {
        Get.offNamed(RouteHelper.getTableViewHomeRoute());
        // Get.offNamed(RouteHelper.getWaiterDashboardInitialRoute());
      }
      // for (var i = 0;
      //     i < Get.find<EditWalkInOrderController>().cartList.length;
      //     i++) {
      // CartModel cart = Get.find<EditWalkInOrderController>().cartList[i];
      // if (cart.product.foodType == 'BAR') {
      //   barList.add(cart);
      // } else {
      //   kdsList.add(cart);
      // }
      // }

      Get.find<EditWalkInOrderController>().clearCartList();

      // if (barList.isEmpty) {
      //   await kdsBytesConvert(kdsList, orderID);
      // } else {
      //   await barBytesConvert(barList, orderID);
      // }

      // Get.find<KdsController>().clearOrderList();
      Get.find<KdsController>().setSubMenuIndex(1);
    } else {
      showErrorToast(message);
    }
  }
  void discountCalculator() {
    serviceChargePercentage = Get.find<AuthController>()
        .profileModel!
        .restaurants!
        .first
        .serviceChargePercentage??0;
        deliveryCharge=widget.editOrder.deliveryCharge??0;
    orderItemTotal = 0;
    double discountableItemTotal = 0;
    orderSubTotal = 0;
    gstServiceChargeTax = 0;
    discountedOrderSubTotal = 0;

    gstAmount = 0;
    vatAmount = 0;
    showServiceChargeValue = 0;
    // double gstTypeFood = 0;
    // double vatTypeFood = 0;
    jsonCartList = [];
    Restaurant restaurant =
        Get.find<AuthController>().profileModel!.restaurants!.first;
    if (selectedDiscountType == 'Percent' &&
        _discountController.text.isNotEmpty &&
        double.parse(_discountController.text) > 100) {
      showErrorToast('Please enter valid discount');
    } else {
      for (var i = 0; i < Get.find<EditWalkInOrderController>().cartList.length; i++) {
        CartModel cart = Get.find<EditWalkInOrderController>().cartList[i];

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
        if (widget.editOrder.orderType == 'dinein' ||
            widget.editOrder.orderType == 'WalkIn' ||
            widget.editOrder.orderType == 'pos') {
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
        } else if (widget.editOrder.orderType == 'take_away') {
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
                      : (cart.product.price! +
                          cart.product.takeAwayFoodPrice!)) *
                  cart.quantity));
          if (cart.isComplementry)
            complementFoodTotal = twoDecimal(((cart.product.price == 1
                    ? cart.discountedPrice
                    : (cart.product.price! + cart.product.takeAwayFoodPrice!)) *
                cart.quantity));
        } else if (widget.editOrder.orderType == 'delivery') {
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
                      : (cart.product.price! +
                          cart.product.deliveryFoodPrice!)) *
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

        if (!cart.isComplementry &&
            cart.product.giveDiscount.toString() == 'Yes') {
          discountableItemTotal =
              twoDecimal(discountableItemTotal + foodAmount);
        }

        if (selectedDiscountType == 'Percent' || selectedDiscountType == 'No') {
          double tempDiscountPercent = selectedDiscountType == 'No'
              ? 0
              : _discountController.text.isEmpty
                  ? 0
                  : double.parse(_discountController.text);
          double tempAmount = 0;
          if (cart.product.giveDiscount.toString() == 'Yes') {
            tempAmount = twoDecimal(foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

            
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
              if (Get.find<PosController>().isAddServiceCharge) {
                gstAmount = twoDecimal(gstAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
                        100));
                showServiceChargeValue = twoDecimal(showServiceChargeValue +
                    ((tempAmount * serviceChargePercentage) / 100));
                foodGstAmount = twoDecimal((((tempAmount) *
                        double.parse(cart.product.tax.toString())) /
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
              if (Get.find<PosController>().isAddServiceCharge) {
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

              if (Get.find<PosController>().isAddServiceCharge) {
                vatAmount = twoDecimal(vatAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
                        100));
                foodVatAmount = twoDecimal((((tempAmount) *
                        double.parse(cart.product.tax.toString())) /
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
              if (Get.find<PosController>().isAddServiceCharge) {
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
        for (var i = 0; i < Get.find<EditWalkInOrderController>().cartList.length; i++) {
          CartModel cart = Get.find<EditWalkInOrderController>().cartList[i];

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
          if (widget.editOrder.orderType == 'dinein'||widget.editOrder.orderType == 'WalkIn'||widget.editOrder.orderType == 'pos') {
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
          } else if (widget.editOrder.orderType == 'take_away') {
       
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
                      : (cart.product.price! +
                          cart.product.takeAwayFoodPrice!)) *
                  cart.quantity);
            }
            if (cart.isComplementry) {
              complementFoodTotal = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.takeAwayFoodPrice!)) *
                  cart.quantity);
            }
          } else if (widget.editOrder.orderType == 'delivery') {
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
                      : (cart.product.price! +
                          cart.product.deliveryFoodPrice!)) *
                  cart.quantity);
            }
            if (cart.isComplementry) {
              complementFoodTotal = twoDecimal((cart.product.price == 1
                      ? cart.discountedPrice
                      : (cart.product.price! +
                          cart.product.deliveryFoodPrice!)) *
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

          double enteredDiscount = _discountController.text.isEmpty
              ? 0
              : double.parse(_discountController.text);
          if (enteredDiscount > discountableItemTotal) {
            enteredDiscount = discountableItemTotal;
          }
          double tempDiscountPercent =
              (_discountController.text.isEmpty || discountableItemTotal == 0)
                  ? 0
                  : double.parse(
                      ((enteredDiscount / discountableItemTotal) * 100)
                          .toStringAsFixed(2));
          double tempAmount = 0;
          if (cart.product.giveDiscount.toString() == 'Yes') {
            tempAmount = twoDecimal(foodAmount -
                (foodAmount *
                    (coummunityDiscountPercentage + tempDiscountPercent) /
                    100));
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);

            
            discountFood = twoDecimal((foodAmount *
                (coummunityDiscountPercentage + tempDiscountPercent) /
                100));
          } else {
            tempAmount = twoDecimal(foodAmount);
            orderSubTotal = twoDecimal(orderSubTotal + tempAmount);
          }
          if (cart.product.taxType.toString() == 'GST') {
            if (restaurant.gstStatus == 'true') {
    
              if (Get.find<PosController>().isAddServiceCharge) {
                gstAmount = twoDecimal(gstAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
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
              if (Get.find<PosController>().isAddServiceCharge) {
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

              if (Get.find<PosController>().isAddServiceCharge) {
                vatAmount = twoDecimal(vatAmount +
                    (((tempAmount) *
                            double.parse(cart.product.tax.toString())) /
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
              if (Get.find<PosController>().isAddServiceCharge) {
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
     

        if (Get.find<PosController>().isAddServiceCharge) {
          gstServiceChargeTax = twoDecimal(
              (showServiceChargeValue * restaurant.serviceChargeTaxPercent!) /
                  100);
        }
        if (deliveryCharge != 0 && restaurant.settings!.gstDeliveryCharge != 0)
          gstAmount = twoDecimal(gstAmount +
              ((deliveryCharge * restaurant.settings!.gstDeliveryCharge!) /
                  100));

        double addOrderAmount = discountedOrderSubTotal +
            showServiceChargeValue +
            gstAmount +
            vatAmount +
            gstServiceChargeTax +
            
            deliveryCharge 
           ;
   
        double payable = twoDecimal(addOrderAmount);

    
        // Round to 2 decimals if you'd like
        payable = double.parse(payable.toStringAsFixed(2));

        Get.find<PosController>().setcollectItemPrice(
            twoDecimal(payable)); // existing method you already call
        // Get.find<PosController>().setcollectItemPrice(addOrderAmount);
        // }
      } else {
        showErrorToast('Please enter valid discount');
      }
    }

    if (mounted) setState(() {});
  }

}
