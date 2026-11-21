import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/delivery_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';

deliveryChargeBottomSheet(BuildContext context,
    {required DeliveryManagementController deliveryManagementController,
    void Function()? onTap}) {
  deliveryManagementController.clearDeliveryCharge();

  return showModalBottomSheet(
    context: context,
    backgroundColor: ColorTheme.whiteColor,
    isScrollControlled: true,
    isDismissible: false,
    constraints: BoxConstraints(maxWidth: double.infinity),
    shape: RoundedRectangleBorder(),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Delivery Charge',
                            style: AppStyle.addCategoryTextStyle.copyWith(
                                color: ColorTheme.grey105,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(
                              Icons.close,
                              color: ColorTheme.grey105,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: ColorTheme.grey.withOpacity(.3),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextformField(
                                    onChanged: (value) {},
                                    labelText: 'Min Distance (km)',
                                    controller: deliveryManagementController
                                        .minDistanceController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*')),
                                    ],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    errorBorder: AppBorder.errorBorder,
                                    focusedErrorBorder: AppBorder.errorBorder,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: CustomTextformField(
                                    onChanged: (value) {},
                                    labelText: 'Max Distance (km)',
                                    controller: deliveryManagementController
                                        .maxDistanceController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*')),
                                    ],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    errorBorder: AppBorder.errorBorder,
                                    focusedErrorBorder: AppBorder.errorBorder,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            CustomTextformField(
                              onChanged: (value) {},
                              labelText: 'Min Order Value',
                              controller: deliveryManagementController
                                  .minOrderValueController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*')),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              errorBorder: AppBorder.errorBorder,
                              focusedErrorBorder: AppBorder.errorBorder,
                            ),
                            SizedBox(height: 10),
                            CustomTextformField(
                              onChanged: (value) {},
                              labelText: 'Charge',
                              controller:
                                  deliveryManagementController.chargeController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*')),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              errorBorder: AppBorder.errorBorder,
                              focusedErrorBorder: AppBorder.errorBorder,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
                GetBuilder<DeliveryManagementController>(
                  builder: (controller) {
                    return GestureDetector(
                      onTap: controller.isAdding ? null : onTap,
                      child: Container(
                        height: 60,
                        color: ColorTheme.greenColor,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: controller.isAdding
                            ? CircularProgressIndicator() // Assuming AppLoader is CircularProgressIndicator
                            : Text(
                                'Add Delivery Charge',
                                style: AppStyle.addCategoryTextStyle,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
