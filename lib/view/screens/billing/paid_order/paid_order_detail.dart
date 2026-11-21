import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/save_local_oreder_response.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillingPaidOrderDetailPage extends StatelessWidget {
  final LocalOrderModel? order;

  const BillingPaidOrderDetailPage({this.order});

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
                    icon: Icon(Icons.arrow_back_ios),
                    color: ColorTheme.appColor,
                    onPressed: () {
                      Get.back();
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
                // toolbarHeight: Get.height / 10.72,
                backgroundColor: Colors.white,
                leading: IconButton(
                    icon: Icon(Icons.chevron_left),
                    iconSize: 40,
                    color: ColorTheme.green,
                    onPressed: () {
                      Get.back();
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
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order!.name != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 15, left: 15),
                      child: Text(
                        'Name: ${order!.name}',
                        style: poppinsSemiBold.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (order!.phoneNumber != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 15),
                      child: Text(
                        'Phone: ${order!.phoneNumber}',
                        style: poppinsSemiBold.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (order!.name != '' || order!.phoneNumber != '')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Divider(height: 1, color: Color(0xFFE6E6E6)),
                    ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFF9F9F9)),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Order Id: ${order!.orderId}',
                            style: poppinsSemiBold.copyWith(
                                fontSize:
                                    MediaQuery.of(context).size.shortestSide >
                                            570
                                        ? 17
                                        : 15,
                                color: ColorTheme.appColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                            itemCount: order!.cartList.length ?? 0,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, int i) {
                              CartModel cart = order!.cartList[i];
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
                                  addonsTotal = addonsTotal +
                                      (addOn.price! * qtys[index0]);
                                  index0 = index0 + 1;
                                }
                              }

                              String variationText = '';

                              if (cart.variation.isNotEmpty) {
                                for (int index = 0;
                                    index < cart.variation.length;
                                    index++) {
                                  if (cart.variation[index].isNotEmpty &&
                                      cart.variation[index].contains(true)) {
                                    variationText +=
                                        '${variationText.isNotEmpty ? ', ' : ''}${cart.product.variations![index].name} (';

                                    for (int i = 0;
                                        i < cart.variation[index].length;
                                        i++) {
                                      if (cart.variation[index][i]) {
                                        // print(variationTotal);
                                        variationText +=
                                            '${variationText.endsWith('(') ? '' : ', '}${cart.product.variations![index].values![i].level}';
                                      }
                                    }
                                    variationText += ')';
                                  }
                                }
                              }

                              return Padding(
                                padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${cart.product.name ?? ''} (${cart.quantity ?? ''})',
                                            style: poppinsMedium.copyWith(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .shortestSide >
                                                        570
                                                    ? 16
                                                    : 10),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          addOnText == ''
                                              ? SizedBox.shrink()
                                              : Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Add-Ons :',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
                                                                    570
                                                                ? 14
                                                                : 10,
                                                            color: ColorTheme
                                                                .blue),
                                                      ),
                                                      TextSpan(
                                                        text: ' $addOnText',
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .shortestSide >
                                                                  570
                                                              ? 14
                                                              : 10,
                                                          color:
                                                              ColorTheme.green,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          variationText == ''
                                              ? SizedBox.shrink()
                                              : Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Variants  :',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
                                                                    570
                                                                ? 14
                                                                : 10,
                                                            color: ColorTheme
                                                                .blue),
                                                      ),
                                                      TextSpan(
                                                        text: ' $variationText',
                                                        style: poppinsMedium.copyWith(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .shortestSide >
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
                                    SizedBox(width: 10),
                                    Text(
                                        '${((cart.price * cart.quantity) + addonsTotal) ?? ''}',
                                        style: poppinsSemiBold.copyWith(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
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

                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       left: Get.width * 0.4,
                      //       right:
                      //           Dimensions.PADDING_SIZE_LARGE),
                      //   child: Divider(color: Colors.grey),
                      // ),
                      SizedBox(height: 15),
                      DottedLine(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        lineThickness: 1.0,
                        dashLength: 2.5,
                        dashColor: ColorTheme.hintText,
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Sub Total'.tr,
                                  textAlign: TextAlign.right,
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                              Text(
                                  ' :   ' +
                                      PriceConverter.convertPrice(
                                          order!.subTotal,
                                          isHideCurrency: true,
                                          asFixed: 2),
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                            ]),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Discount'.tr,
                                  textAlign: TextAlign.right,
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                              Text(
                                  ' :   ' +
                                      PriceConverter.convertPrice(
                                          order!.discount,
                                          isHideCurrency: true,
                                          asFixed: 2),
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                            ]),
                      ),

                      if (order!.tips != 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, right: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Add Tips',
                                    textAlign: TextAlign.right,
                                    style: poppinsMedium.copyWith(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 15
                                            : 10)),
                                Text(
                                    ' :   ' +
                                        PriceConverter.convertPrice(order!.tips,
                                            isHideCurrency: true, asFixed: 2),
                                    style: poppinsMedium.copyWith(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 15
                                            : 10)),
                              ]),
                        ),
                      if (order!.serviceCharge != 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, right: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                    '${Get.find<AuthController>().profileModel!.restaurants!.first.settings?.serviceChrgTaxt ?? 'Service Charge'} ',
                                    textAlign: TextAlign.right,
                                    style: poppinsMedium.copyWith(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 15
                                            : 10)),
                                Text(
                                    ' :   ' +
                                        PriceConverter.convertPrice(
                                            order!.serviceCharge,
                                            isHideCurrency: true,
                                            asFixed: 2),
                                    style: poppinsMedium.copyWith(
                                        fontSize: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                570
                                            ? 15
                                            : 10)),
                              ]),
                        ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('CGST'.tr,
                                  textAlign: TextAlign.right,
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                              Text(' :   ${order!.gstTaxAmount / 2}',
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                            ]),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('SGST'.tr,
                                  textAlign: TextAlign.right,
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                              Text(' :   ${order!.gstTaxAmount / 2}',
                                  style: poppinsMedium.copyWith(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .shortestSide >
                                              570
                                          ? 15
                                          : 10)),
                            ]),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Total'.tr,
                                  textAlign: TextAlign.right,
                                  style: poppinsBold.copyWith(
                                    color: ColorTheme.green,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .shortestSide >
                                            570
                                        ? 17
                                        : 14,
                                  )),
                              Text(
                                  ' :  ' +
                                      PriceConverter.convertPrice(
                                          (order!.orderAmount),
                                          isHideCurrency: true,
                                          asFixed: 2),
                                  style: poppinsBold.copyWith(
                                      color: ColorTheme.green,
                                      fontSize: MediaQuery.of(context)
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
