import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_cacel_reason_list_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';

class BuffetCancelOrderDialog extends StatelessWidget {
  final TextEditingController controller;
  final String orderId;
  final String itemId;
  final String foodId;
  final int foodStatus;
  const BuffetCancelOrderDialog(
      {required this.controller,
      required this.orderId,
      required this.itemId,
      required this.foodId,
      required this.foodStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE)),
            color: Colors.white),
        // height: Get.height * 0.4,
        child: Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: Dimensions.PADDING_SIZE_DEFAULT),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Cancel',
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
                  child: Divider(color: ColorTheme.borderGrey),
                ),
                SizedBox(height: 10),
                GetBuilder<KdsController>(builder: (kdsController) {
                  return kdsController.getCancelReasonList.isEmpty
                      ? SizedBox.shrink()
                      : Container(
                          margin: EdgeInsets.only(bottom: 15),
                          height: MediaQuery.of(context).size.width > 1600
                              ? 65
                              : 40,
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_SMALL),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorTheme.borderGrey),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: DropdownButton<Reasons>(
                            isExpanded: true,
                            value: kdsController.selectedReason,
                            items: kdsController.getCancelReasonList
                                .map((Reasons value) {
                              return DropdownMenuItem<Reasons>(
                                value: value,
                                child: Text(
                                  value.reason ?? '',
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
                            onChanged: (Reasons? value) {
                              kdsController.setCancelReason(value!);
                            },
                            underline: SizedBox(),
                          ),
                        );
                }),
                TextField(
                  controller: controller,
                  autofocus: false,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Type here..'.tr,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorTheme.borderGrey),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    hintStyle: poppinsMedium.copyWith(
                        fontSize:
                            MediaQuery.of(context).size.width > 1600 ? 17 : 13,
                        color: ColorTheme.hintText),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: poppinsMedium.copyWith(
                    color: Colors.black,
                    fontSize:
                        MediaQuery.of(context).size.width > 1600 ? 17 : 13,
                  ),
                  onChanged: (value) async {},
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GetBuilder<KdsController>(builder: (kdsController) {
                    return kdsController.isLoading
                        ? CircularProgressIndicator()
                        : InkWell(
                            onTap: () async {
                              if (kdsController.selectedReason!.id != 0) {
                                Map<String, dynamic> jsonBody = {
                                  'order_id': orderId,
                                  'order_food_id': foodId,
                                  'item_id': itemId,
                                  'order_status': 'cancelled',
                                  'reason_type': Get.find<KdsController>()
                                      .selectedReason!
                                      .id
                                      .toString(),
                                  'reason': controller.text.isEmpty
                                      ? ''
                                      : controller.text,
                                  'cancel_type': foodStatus == 5
                                      ? 'Post-Serve'
                                      : 'Pre-Serve'
                                };
                                Get.back();
                                await Get.find<KdsController>()
                                    .cancelFoodItem(jsonBody, callback);
                              }
                            },
                            child: Container(
                              height: 35,
                              width: 110,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.transparent),
                                  color: ColorTheme.appColor,
                                  // border:
                                  //     Border.all(color: Color.fromRGBO(229, 229, 229, 1)),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(
                                  'submit'.tr,
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
                          );
                  }),
                ),
              ]),
            ),
          ),
        ));
  }

  void callback(bool isSuccess, String message) async {
    if (isSuccess) {
      Get.find<KdsController>()
          .setCancelReason(Get.find<KdsController>().getCancelReasonList.first);
      // Get.back();
      // await Get.find<KdsController>().getWaiterPOSOrderList();
      // showCustomSnackBar(message, isError: false);
      // showToast(message);

      // Get.find<OrderController>().stopLoader();

      // Get.offNamed(
      //     RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
    } else {
      // showCustomSnackBar(message);
    }
  }
}
