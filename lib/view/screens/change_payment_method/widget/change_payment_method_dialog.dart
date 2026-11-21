import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/model/response/get_paid_orders_response.dart';

class ChangePaymentMethodDialog extends StatefulWidget {
  final String orderId;
  final Orders order;
  const ChangePaymentMethodDialog({
    Key? key,
    required this.orderId,
    required this.order,
  }) : super(key: key);

  @override
  State<ChangePaymentMethodDialog> createState() =>
      _ChangePaymentMethodDialogState();
}

class _ChangePaymentMethodDialogState extends State<ChangePaymentMethodDialog> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Change Payment Method',
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
                GetBuilder<KdsController>(builder: (kdsController) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 15),
                          height: MediaQuery.of(context).size.width > 1600
                              ? 65
                              : 40,
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.PADDING_SIZE_SMALL,
                          ),
                          child: Text(
                            'Order Id : ${widget.order.restaurantOrderId}',
                            style: poppinsMedium.copyWith(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        margin: EdgeInsets.only(bottom: 15, left: 10),
                        height:
                            MediaQuery.of(context).size.width > 1600 ? 65 : 40,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_SMALL,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorTheme.borderGrey),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedPaymentMethod ??
                              widget.order.paymentMethod!.toLowerCase(),
                          items: ['cash', 'card', 'upi'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                maxLines: 1,
                                style: poppinsRegular.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.width > 1600
                                          ? 17
                                          : Dimensions.FONT_SIZE_SMALL,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedPaymentMethod = value;
                            });
                            kdsController.update();
                          },
                          underline: SizedBox(),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GetBuilder<KdsController>(builder: (kdsController) {
                    return kdsController.isLoading
                        ? CircularProgressIndicator()
                        : InkWell(
                            onTap: () async {
                              Map<String, dynamic> jsonBody = {
                                'order_id': widget.orderId.toString(),
                                'payment_method': selectedPaymentMethod ??
                                    widget.order.paymentMethod!.toLowerCase(),
                              };
                              Get.back();
                              Get.find<KdsController>()
                                  .changePaymentMethod(jsonBody, callback);
                            },
                            child: Container(
                              height: 35,
                              width: 110,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent),
                                color: ColorTheme.appColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'submit'.tr,
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
                          );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      widget.order.paymentMethod =
          selectedPaymentMethod ?? widget.order.paymentMethod!.toLowerCase();
    } else {
      showCustomSnackBar(message);
    }
  }
}
