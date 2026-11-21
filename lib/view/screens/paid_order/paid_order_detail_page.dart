import 'package:dotted_line/dotted_line.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_order_detail_response.dart';
import 'package:mygenie_restaurant/data/model/response/get_paid_room_order_detail_respose_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaidOrderDetailPage extends StatefulWidget {
  final String orderId;
  const PaidOrderDetailPage({required this.orderId, super.key});

  @override
  State<PaidOrderDetailPage> createState() => _PaidOrderDetailPageState();
}

class _PaidOrderDetailPageState extends State<PaidOrderDetailPage> {
  double orderSubtotal = 0;
  double roomCheckInPrice = 0;
  double roomOrders = 0;
  double couponDiscount = 0;
  double loyaltyPoint = 0;
  double usedWallet = 0;
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<KdsController>().getPaidOrderDetail(widget.orderId);
      await Get.find<KdsController>().getPaidRoomOrder('${widget.orderId}');
      for (var element in Get.find<KdsController>().getRoomPaidOrderList) {
        roomOrders = roomOrders + double.parse(element.orderAmount);
      }
      Orders orders =
          Get.find<KdsController>().paidOrderDetailResponse!.orders!;
      if (orders.orderDetailsOrder!.couponInfo != null &&
          orders.orderDetailsOrder!.couponInfo!.applied!) {
        couponDiscount =
            orders.orderDetailsOrder?.couponInfo?.couponAmount ?? 0;
      }
      if (orders.orderDetailsOrder!.loyaltyInfo != null &&
          orders.orderDetailsOrder!.loyaltyInfo!.redeemed!) {
        loyaltyPoint =
            orders.orderDetailsOrder?.loyaltyInfo?.redeemedAmount ?? 0;
      }
      if (orders.orderDetailsOrder!.walletInfo != null &&
          orders.orderDetailsOrder!.walletInfo!.applied!) {
        usedWallet = orders.orderDetailsOrder?.walletInfo?.amount ?? 0;
      }
      if (orders != null && orders.orderDetailsFood != null) {
        for (var orderDetailsFood in orders.orderDetailsFood!) {
          double variationTotal = 0;
          double halfVariationPrice = 0;
          double addonsTotal = 0;
          if (orderDetailsFood.variation != null &&
              orderDetailsFood.variation!.isNotEmpty) {
            for (int j = 0; j < orderDetailsFood.variation!.length; j++) {
              final variation = orderDetailsFood.variation![j];
              if (variation.values != null) {
                List<String> labelList = [];
                for (var element in variation.values!) {
                  labelList.add(element.label ?? '');
                  if ((variation.name ?? '').toUpperCase() == 'HALFNHALF') {
                    if (halfVariationPrice <
                        (double.tryParse(element.optionPrice ?? '0') ?? 0) *
                            (orderDetailsFood.quantity ?? 0)) {
                      if (orderDetailsFood.isComplementary != 1)
                        halfVariationPrice =
                            (double.tryParse(element.optionPrice ?? '0') ?? 0) *
                                (orderDetailsFood.quantity ?? 0);
                    }
                  } else {
                    if (orderDetailsFood.isComplementary != 1)
                      variationTotal = variationTotal +
                          ((double.tryParse(element.optionPrice ?? '0') ?? 0) *
                              (orderDetailsFood.quantity ?? 0));
                  }
                }
              }
              if (orderDetailsFood.isComplementary != 1)
                variationTotal = variationTotal + halfVariationPrice;
            }
          }

          if (orderDetailsFood.addOns != null) {
            for (var i = 0; i < orderDetailsFood.addOns!.length; i++) {
              final addOn = orderDetailsFood.addOns![i];
              if (orderDetailsFood.isComplementary != 1)
                addonsTotal =
                    addonsTotal + ((addOn.price ?? 0) * (addOn.quantity ?? 0));
            }
          }

          if (orderDetailsFood.isComplementary != 1)
            orderSubtotal = orderSubtotal +
                ((orderDetailsFood.unitPrice ?? 0) *
                    orderDetailsFood.quantity!) +
                variationTotal +
                (addonsTotal * orderDetailsFood.quantity!);
          Get.find<KdsController>().update();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MediaQuery.of(context).size.shortestSide > 570
            ? AppBar(
                toolbarHeight: Get.height / 10.72,
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: ColorTheme.appColor,
                    onPressed: () {
                      if (context.mounted) Get.back();
                    }),
                titleSpacing: 0,
                elevation: 0,
                centerTitle: true,
                title: Column(
                  children: [
                    Image.asset(
                      logoHelper.appLogo!,
                      height: Get.height / 10.72,
                    ),
                  ],
                ))
            : AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 40,
                    color: ColorTheme.green,
                    onPressed: () {
                      if (context.mounted) Get.back();
                    }),
                titleSpacing: 0,
                elevation: 0,
                centerTitle: false,
                title: Column(
                  children: [
                    Image.asset(logoHelper.appLogo!, width: Get.width * 0.3),
                  ],
                ),
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: GetBuilder<KdsController>(builder: (kdsController) {
                return kdsController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : kdsController.paidOrderDetailResponse == null
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (kdsController.paidOrderDetailResponse!.orders!
                                          .orderUser !=
                                      null &&
                                  kdsController.paidOrderDetailResponse!.orders!
                                          .orderUser!.fName !=
                                      '')
                                Padding(
                                  padding: EdgeInsets.only(top: 15, left: 15),
                                  child: Text(
                                    'Name: ${kdsController.paidOrderDetailResponse!.orders!.orderUser!.fName}',
                                    style:
                                        poppinsSemiBold.copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (kdsController.paidOrderDetailResponse!.orders!
                                          .orderUser !=
                                      null &&
                                  kdsController.paidOrderDetailResponse!.orders!
                                          .orderUser!.phone !=
                                      '')
                                Padding(
                                  padding: EdgeInsets.only(top: 10, left: 15),
                                  child: Text(
                                    'Phone: ${kdsController.paidOrderDetailResponse!.orders!.orderUser!.phone}',
                                    style:
                                        poppinsSemiBold.copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, left: 15),
                                child: Text(
                                  'Waiter Name: ${kdsController.paidOrderDetailResponse?.orders?.collectPaymentWaiter ?? ''}',
                                  style: poppinsSemiBold.copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: const Divider(
                                    height: 1, color: Color(0xFFE6E6E6)),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFF9F9F9)),
                                child: Column(children: [
                                  if (Get.find<KdsController>()
                                      .getRoomPaidOrderList
                                      .isNotEmpty)
                                    previousBill(),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Order Id: ${kdsController.paidOrderDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId == '0' ? kdsController.paidOrderDetailResponse?.orders?.orderDetailsOrder?.id : kdsController.paidOrderDetailResponse?.orders?.orderDetailsOrder?.restaurantOrderId}',
                                        style: poppinsSemiBold.copyWith(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .shortestSide >
                                                    570
                                                ? 17
                                                : 15,
                                            color: ColorTheme.appColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: ListView.builder(
                                        itemCount: kdsController
                                                .paidOrderDetailResponse
                                                ?.orders
                                                ?.mergeFoodList
                                                ?.length ??
                                            0,
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int i) {
                                          final orderDetailsFoodNullable =
                                              kdsController
                                                  .paidOrderDetailResponse
                                                  ?.orders
                                                  ?.mergeFoodList?[i];
                                          if (orderDetailsFoodNullable ==
                                              null) {
                                            return const SizedBox.shrink();
                                          }

                                          final orderDetailsFood =
                                              orderDetailsFoodNullable;

                                          String variationText = '';
                                          double variationTotal = 0;
                                          double halfVariationPrice = 0;
                                          double addonsTotal = 0;
                                          if (orderDetailsFood.variation !=
                                                  null &&
                                              orderDetailsFood
                                                  .variation!.isNotEmpty) {
                                            for (int j = 0;
                                                j <
                                                    (orderDetailsFood.variation
                                                            ?.length ??
                                                        0);
                                                j++) {
                                              final variation = orderDetailsFood
                                                  .variation![j];
                                              variationText +=
                                                  '${variationText.isNotEmpty ? ', ' : ''}${variation.name ?? ''} (';

                                              if (variation.values != null) {
                                                List<String> labelList = [];
                                                for (var element
                                                    in variation.values!) {
                                                  labelList
                                                      .add(element.label ?? '');
                                                  if ((variation.name ?? '')
                                                          .toUpperCase() ==
                                                      'HALFNHALF') {
                                                    final optionPrice =
                                                        double.tryParse(element
                                                                    .optionPrice ??
                                                                '0') ??
                                                            0;
                                                    final quantity =
                                                        orderDetailsFood
                                                                .quantity ??
                                                            0;
                                                    if (halfVariationPrice <
                                                        optionPrice *
                                                            quantity) {
                                                      if (orderDetailsFood
                                                              .isComplementary !=
                                                          1)
                                                        halfVariationPrice =
                                                            optionPrice *
                                                                quantity;
                                                    }
                                                  } else {
                                                    final optionPrice =
                                                        double.tryParse(element
                                                                    .optionPrice ??
                                                                '0') ??
                                                            0;
                                                    final quantity =
                                                        orderDetailsFood
                                                                .quantity ??
                                                            0;
                                                    if (orderDetailsFood
                                                            .isComplementary !=
                                                        1)
                                                      variationTotal = variationTotal +
                                                          ((double.tryParse(element
                                                                          .optionPrice ??
                                                                      '0') ??
                                                                  0) *
                                                              (orderDetailsFood
                                                                      .quantity ??
                                                                  0));
                                                  }
                                                }
                                                variationText +=
                                                    '${variationText.endsWith('(') ? '' : ', '}${labelList.join(',')}';
                                              }

                                              variationText += ')';
                                              variationTotal = variationTotal +
                                                  halfVariationPrice;
                                            }
                                          }

                                          String addons = '';
                                          if (orderDetailsFood.addOns != null) {
                                            for (var i = 0;
                                                i <
                                                    (orderDetailsFood
                                                            .addOns?.length ??
                                                        0);
                                                i++) {
                                              final addOn =
                                                  orderDetailsFood.addOns![i];
                                              final price = addOn.price ?? 0;
                                              final quantity =
                                                  addOn.quantity ?? 0;
                                              if (orderDetailsFood
                                                      .isComplementary !=
                                                  1)
                                                addonsTotal = addonsTotal +
                                                    (price * quantity);
                                              addons +=
                                                  '${addOn.name ?? ''} (${addOn.quantity ?? 0})';
                                            }
                                          }

                                          final foodName = orderDetailsFood
                                              .foodDetails?.name;
                                          if (roomCheckInPrice == 0 &&
                                              ((foodName?.toLowerCase() ??
                                                      '') ==
                                                  'check in')) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              roomCheckInPrice =
                                                  orderDetailsFood.unitPrice ??
                                                      0;
                                              kdsController.update();
                                            });
                                          }
                                          if (orderDetailsFood.foodStatus ==
                                              3) {
                                            return const SizedBox.shrink();
                                          }

                                          return Padding(
                                            padding: EdgeInsets.only(
                                                top: i == 0 ? 0 : 8),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        ((foodName?.toLowerCase() ??
                                                                    '') ==
                                                                'check in')
                                                            ? 'Room Check-In'
                                                            : '${orderDetailsFood.foodDetails?.name ?? ''} (${orderDetailsFood.quantity ?? ''})',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
                                                                    570
                                                                ? 16
                                                                : 10),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      addons == ''
                                                          ? const SizedBox
                                                              .shrink()
                                                          : Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Add-Ons :',
                                                                    style: poppinsMedium.copyWith(
                                                                        fontSize: MediaQuery.of(context).size.shortestSide >
                                                                                570
                                                                            ? 14
                                                                            : 10,
                                                                        color: ColorTheme
                                                                            .blue),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' $addons',
                                                                    style: poppinsMedium
                                                                        .copyWith(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontSize: MediaQuery.of(context).size.shortestSide >
                                                                              570
                                                                          ? 14
                                                                          : 10,
                                                                      color: ColorTheme
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                      variationText == ''
                                                          ? const SizedBox
                                                              .shrink()
                                                          : Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Variants  :',
                                                                    style: poppinsMedium.copyWith(
                                                                        fontSize: MediaQuery.of(context).size.shortestSide >
                                                                                570
                                                                            ? 14
                                                                            : 10,
                                                                        color: ColorTheme
                                                                            .blue),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' $variationText',
                                                                    style: poppinsMedium.copyWith(
                                                                        fontSize: MediaQuery.of(context).size.shortestSide >
                                                                                570
                                                                            ? 14
                                                                            : 10,
                                                                        color: ColorTheme
                                                                            .green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                                if ((Get.find<AuthController>()
                                                            .profileModel
                                                            ?.restaurants
                                                            ?.first
                                                            .isComplementry ??
                                                        '') !=
                                                    'Yes')
                                                  const SizedBox(width: 10),
                                                if (Get.find<AuthController>()
                                                        .profileModel
                                                        ?.restaurants
                                                        ?.first
                                                        .isComplementry !=
                                                    'Yes')
                                                  Text(
                                                      ((foodName?.toLowerCase() ??
                                                                  '') ==
                                                              'check in')
                                                          ? '${orderDetailsFood.unitPrice}'
                                                          : '${((orderDetailsFood.unitPrice! * orderDetailsFood.quantity!) + variationTotal + (addonsTotal * orderDetailsFood.quantity!))}',
                                                      style: poppinsSemiBold.copyWith(
                                                          color: Colors.black,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .shortestSide >
                                                                  570
                                                              ? 14
                                                              : 10)),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                  const SizedBox(height: 15),
                                  DottedLine(
                                    direction: Axis.horizontal,
                                    alignment: WrapAlignment.center,
                                    lineThickness: 1.0,
                                    dashLength: 2.5,
                                    dashColor: ColorTheme.hintText,
                                  ),
                                  const SizedBox(height: 15),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isComplementry !=
                                      'Yes')
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Item Total',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        orderSubtotal ,
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (Get.find<KdsController>()
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .orderDetailsOrder!
                                          .restaurantDiscountAmount !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Discount',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .restaurantDiscountAmount!,
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (couponDiscount != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                'Coupon Discount  :  ${couponDiscount.toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (Get.find<KdsController>()
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .orderDetailsOrder!
                                          .tipAmount !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Add Tips',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .tipAmount!,
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (double.parse(Get.find<KdsController>()
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .serviceTax!) !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                '${Get.find<AuthController>().profileModel!.restaurants!.first.settings?.serviceChrgTaxt ?? 'Service Charge'} ',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        double.parse(Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .serviceTax!),
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (Get.find<KdsController>()
                                          .paidOrderDetailResponse!
                                          .orders!
                                          .orderDetailsOrder!
                                          .deliveryCharge !=
                                      0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Delivery Charge'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .deliveryCharge!,
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                       Padding(
                                       padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Sub Total',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ' +
                                                    PriceConverter.convertPrice(
                                                        twoDecimal((orderSubtotal +
                                                            Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .deliveryCharge!+ Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .tipAmount!+ double.parse(Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .serviceTax!))- Get.find<
                                                                KdsController>()
                                                            .paidOrderDetailResponse!
                                                            .orders!
                                                            .orderDetailsOrder!
                                                            .restaurantDiscountAmount!),
                                                        isHideCurrency: true,
                                                        asFixed: 2),
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .isComplementry !=
                                          'Yes' &&
                                      double.parse(Get.find<KdsController>()
                                              .paidOrderDetailResponse!
                                              .orders!
                                              .gstTax!) !=
                                          0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('CGST'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ${(double.parse(Get.find<KdsController>().paidOrderDetailResponse!.orders!.gstTax!) / 2).toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (Get.find<AuthController>()
                                              .profileModel!
                                              .restaurants!
                                              .first
                                              .isComplementry !=
                                          'Yes' &&
                                      double.parse(Get.find<KdsController>()
                                              .paidOrderDetailResponse!
                                              .orders!
                                              .gstTax!) !=
                                          0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('SGST'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ${(double.parse(Get.find<KdsController>().paidOrderDetailResponse!.orders!.gstTax!) / 2).toStringAsFixed(2)}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (Get.find<KdsController>()
                                              .paidOrderDetailResponse!
                                              .orders!
                                              .vatTax !=
                                          '0' &&
                                      Get.find<KdsController>()
                                              .paidOrderDetailResponse!
                                              .orders!
                                              .vatTax! !=
                                          '0.00')
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('VAT'.tr,
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                            Text(
                                                ' :   ${Get.find<KdsController>().paidOrderDetailResponse!.orders!.vatTax}',
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (loyaltyPoint != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                'Used Loyalty Point  :  ${loyaltyPoint.toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (usedWallet != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                'Used wallet amount  :  ${usedWallet.toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: poppinsMedium.copyWith(
                                                    fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .shortestSide >
                                                            570
                                                        ? 15
                                                        : 10)),
                                          ]),
                                    ),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isComplementry !=
                                      'Yes')
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Total',
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
                                                ' :  ${convertRoundOff(
                                                  kdsController
                                                          .paidOrderDetailResponse!
                                                          .orders!
                                                          .orderDetailsOrder!
                                                          .orderAmount!,
                                                )}',
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
                                  if (roomOrders != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, right: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text('Grand Total',
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
                                                ' :   ${convertRoundOff(kdsController.paidOrderDetailResponse!.orders!.orderDetailsOrder!.orderAmount!  + roomOrders)}',
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
                                ]),
                              ),
                            ],
                          );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget previousBill() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 5, left: 15),
            child: Text(
              'Previous Bills',
              style: poppinsMedium.copyWith(
                  fontSize:
                      MediaQuery.of(context).size.shortestSide > 570 ? 17 : 15,
                  color: ColorTheme.appColor),
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 15, bottom: 20, right: 15, top: 10),
          child: ListView.builder(
              itemCount:
                  Get.find<KdsController>().getRoomPaidOrderList?.length ?? 0,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int i) {
                GetRoomPaidOrderDetailResponse customerData =
                    Get.find<KdsController>().getRoomPaidOrderList[i];
                return Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${i + 1}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${customerData.restaurantOrderId}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${convertRoundOff(double.parse(customerData.orderAmount))}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          customerData.createdAt == ''
                              ? ''
                              : '${DateFormat('dd-MMM').format(DateTime.parse(customerData.createdAt))}',
                          style: poppinsMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            Get.toNamed(RouteHelper.gePaidOrderDetailtRoute(
                                '${customerData.orderId}'));
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                horizontal: 13),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                                color: ColorTheme.appColor,
                                // border:
                                //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_DEFAULT)),
                            child: Center(
                              child: Text(
                                'Detail',
                                style: poppinsRegular.copyWith(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
