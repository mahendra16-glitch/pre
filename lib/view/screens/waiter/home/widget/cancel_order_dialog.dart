import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/response/get_cacel_reason_list_response_model.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controller/auth_controller.dart';

class CancelOrderDialog extends StatefulWidget {
  final TextEditingController? controller;
  final String? orderId;
  final String? itemId;
  final String? foodId;
  final int? foodStatus;
  final String cancelType;
  List<int>? qtyList;
  /// Stations for the cancelled order/item — used to build printer_agent.
  final List<String>? stations;

  CancelOrderDialog({
    Key? key,
    this.controller,
    this.orderId,
    this.itemId,
    this.foodId,
    this.foodStatus,
    this.cancelType = 'food',
    this.qtyList,
    this.stations,
  }) : super(key: key);

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  late TextEditingController cancelReason;
  int selectedQty = 1;

  @override
  void initState() {
    super.initState();
    cancelReason = TextEditingController();
    if (widget.qtyList != null && widget.qtyList!.isNotEmpty) {
      selectedQty = widget.qtyList!.first;
    }
  }

  @override
  void dispose() {
    cancelReason.dispose();
    super.dispose();
  }

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
                    child: Divider(color: ColorTheme.borderGrey)),
                SizedBox(height: 10),
                GetBuilder<KdsController>(builder: (kdsController) {
                  return kdsController.getCancelReasonList.isEmpty
                      ? SizedBox.shrink()
                      : Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 15),
                                height: MediaQuery.of(context).size.width > 1600
                                    ? 65
                                    : 40,
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.PADDING_SIZE_SMALL),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: ColorTheme.borderGrey),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: DropdownButton<Reasons>(
                                  isExpanded: true,
                                  value: kdsController.selectedReason,
                                  items: kdsController.getCancelReasonList
                                      .where((reason) => widget.cancelType ==
                                              'food'
                                          ? (reason.itemType == null ||
                                              reason.itemType!.toUpperCase() ==
                                                  'FOOD')
                                          : (reason.itemType == null ||
                                              reason.itemType!.toUpperCase() ==
                                                  'ORDER'))
                                      .map((Reasons value) {
                                    return DropdownMenuItem<Reasons>(
                                      value: value,
                                      child: Text(
                                        value.reason ?? '',
                                        maxLines: 1,
                                        style: poppinsRegular.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  1600
                                              ? 17
                                              : Dimensions.FONT_SIZE_SMALL,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Reasons? value) {
                                    if (value != null) {
                                      kdsController.setCancelReason(value);
                                    }
                                  },
                                  underline: SizedBox(),
                                ),
                              ),
                            ),
                            if (widget.cancelType == 'food')
                              Container(
                                width: 70,
                                margin: EdgeInsets.only(bottom: 15, left: 10),
                                height: MediaQuery.of(context).size.width > 1600
                                    ? 65
                                    : 40,
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.PADDING_SIZE_SMALL),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: ColorTheme.borderGrey),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedQty,
                                  items: widget.qtyList!.map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        '$value',
                                        maxLines: 1,
                                        style: poppinsRegular.copyWith(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  1600
                                              ? 17
                                              : Dimensions.FONT_SIZE_SMALL,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (int? value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedQty = value;
                                      });
                                      kdsController.update();
                                    }
                                  },
                                  underline: SizedBox(),
                                ),
                              ),
                          ],
                        );
                }),
                TextField(
                  controller: cancelReason,
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
                              if (kdsController.selectedReason != null &&
                                  kdsController.selectedReason!.id != 0 &&
                                  widget.cancelType != 'order') {
                                Map<String, dynamic> jsonBody = {
                                  'order_id': widget.orderId,
                                  // if (widget.qtyList!.length == 1 ||
                                  //     widget.qtyList!.length == selectedQty)
                                    'item_id': widget.itemId,
                                  // if (widget.qtyList!.length == 1 ||
                                  //     widget.qtyList!.length == selectedQty)
                                    'order_food_id': widget.foodId,
                                  // if (widget.qtyList!.length != 1 &&
                                  //     widget.qtyList!.length != selectedQty)
                                    // 'order_food_id': widget.itemId,
                                  // if (widget.qtyList!.length != 1 &&
                                  //     widget.qtyList!.length != selectedQty)
                                    'cancel_qty': selectedQty,
                                  'order_status': 'cancelled',
                                  'reason_type': kdsController
                                      .selectedReason!.id
                                      .toString(),
                                  'reason': cancelReason.text.isEmpty
                                      ? ''
                                      : cancelReason.text,
                                  'cancel_type': widget.foodStatus == 5
                                      ? 'Post-Serve'
                                      : 'Pre-Serve',
                                  if (widget.stations != null &&
                                      widget.stations!.isNotEmpty)
                                    'stations': widget.stations,
                                };
                                Get.back();
                                await Get.find<KdsController>().cancelFoodItem(
                                    jsonBody, callback,
                                    isQty: widget.qtyList!.length != 1 &&
                                        widget.qtyList!.length != selectedQty);
                              } else if (kdsController.selectedReason != null &&
                                  kdsController.selectedReason!.id != 0 &&
                                  widget.cancelType == 'order') {
                                Map<String, dynamic> jsonBody = {
                                  'order_id': widget.orderId.toString(),
                                  'order_status': 'cancelled',
                                  'role_name': Get.find<AuthController>()
                                      .profileModel
                                      ?.role
                                      ?.first,
                                  'cancellation_note': cancelReason.text.isEmpty
                                      ? ''
                                      : cancelReason.text,
                                  'cancellation_reason':
                                      kdsController.selectedReason?.reason ?? '',
                                  if (widget.stations != null &&
                                      widget.stations!.isNotEmpty)
                                    'stations': widget.stations,
                                };
                                Get.back();
                                Get.find<KdsController>()
                                    .changeOrderStatus(jsonBody, callback);
                              }
                            },
                            child: Container(
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
    } else {
      // showCustomSnackBar(message);
    }
  }
}
