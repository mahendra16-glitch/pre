// delivery_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/delivery_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/delivery_management/widget/delivery_charge_bottom_sheet.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';

class DeliverySettingsScreen extends StatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  @override
  void initState() {
    final DeliveryManagementController controller =
        Get.find<DeliveryManagementController>();
    controller.clearBasicSettings();
    controller.clearDeliveryCharge();
    controller.getSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle normalStyle = montserratMedium.copyWith(
      color: ColorTheme.grey1,
      fontSize: 15,
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorTheme.whiteColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: ColorTheme.green,
            onPressed: () {
              Get.back();
            },
          ),
          titleSpacing: 0,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Delivery Management',
            style: montserratSemiBold.copyWith(
                color: ColorTheme.black, fontSize: 16),
          ),
        ),
        body: GetBuilder<DeliveryManagementController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: ExpansionPanelList.radio(
                initialOpenPanelValue: 0,
                expandIconColor: ColorTheme.green,
                dividerColor: ColorTheme.whiteE4,
                elevation: 0,
                expandedHeaderPadding: EdgeInsets.zero,
                children: [
                  // Basic Settings Panel
                  ExpansionPanelRadio(
                    value: 0,
                    canTapOnHeader: true,
                    backgroundColor: Colors.white,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Basic Settings',
                            style: montserratMedium.copyWith(
                              color: ColorTheme.grey1,
                              fontSize: 15,
                            )),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextformField(
                            onChanged: (value) {},
                            labelText: 'Zone ID',
                            readOnly: true,
                            controller: controller.zoneIdController,
                            keyboardType: TextInputType.number,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            errorBorder: AppBorder.errorBorder,
                            focusedErrorBorder: AppBorder.errorBorder,
                          ),
                          const SizedBox(height: 20),
                          CustomTextformField(
                            onChanged: (value) {},
                            labelText: 'Latitude',
                            controller: controller.latitudeController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            errorBorder: AppBorder.errorBorder,
                            focusedErrorBorder: AppBorder.errorBorder,
                          ),
                          const SizedBox(height: 20),
                          CustomTextformField(
                            onChanged: (value) {},
                            labelText: 'Longitude',
                            controller: controller.longitudeController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            errorBorder: AppBorder.errorBorder,
                            focusedErrorBorder: AppBorder.errorBorder,
                          ),
                          const SizedBox(height: 20),
                          CustomTextformField(
                            onChanged: (value) {},
                            labelText: 'Delivery Person Name',
                            controller: controller.deliveryPersonNameController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            errorBorder: AppBorder.errorBorder,
                            focusedErrorBorder: AppBorder.errorBorder,
                          ),
                          const SizedBox(height: 20),
                          CustomTextformField(
                            onChanged: (value) {},
                            labelText: 'Delivery Contact No',
                            controller: controller.deliveryContactNoController,
                            keyboardType: TextInputType.phone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            errorBorder: AppBorder.errorBorder,
                            focusedErrorBorder: AppBorder.errorBorder,
                          ),
                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text('Delivery Fee', style: normalStyle),
                              trailing: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: controller.deliveryFee,
                                  onChanged: (val) {
                                    controller.deliveryFee = val;
                                    controller.update();
                                  },
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text('Surcharge', style: normalStyle),
                              trailing: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: controller.surcharge,
                                  onChanged: (val) {
                                    controller.surcharge = val;
                                    controller.update();
                                  },
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text('Validate Address from Google',
                                  style: normalStyle),
                              trailing: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: controller.validateAddressFromGoogle,
                                  onChanged: (val) {
                                    controller.validateAddressFromGoogle = val;
                                    controller.update();
                                  },
                                ),
                              ),
                            ),
                          ),

                          // const SizedBox(height: 15),

                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text('Show Real Status to Customer',
                                  style: normalStyle),
                              trailing: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: controller.showRealStatusToCustomer,
                                  onChanged: (val) {
                                    controller.showRealStatusToCustomer = val;
                                    controller.update();
                                  },
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title:
                                  Text('Delivery Assign', style: normalStyle),
                              trailing: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: controller.deliveryAssign,
                                  onChanged: (val) {
                                    controller.deliveryAssign = val;
                                    controller.update();
                                  },
                                ),
                              ),
                            ),
                          ),

                          // const SizedBox(height: 30),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: ElevatedButton(
                          //     onPressed: controller.updateBasicSettings,
                          //     style: ElevatedButton.styleFrom(
                          //       elevation: 0,
                          //       shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(8)),
                          //       backgroundColor: ColorTheme.greenColor,
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 20, vertical: 15),
                          //     ),
                          //     child: Text(
                          //       'Update Basic Settings',
                          //       style: montserratMedium.copyWith(
                          //         color: ColorTheme.whiteColor,
                          //         fontSize: 16,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // Delivery Charges Panel
                  ExpansionPanelRadio(
                    value: 1,
                    canTapOnHeader: true,
                    backgroundColor: Colors.white,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text('Delivery Charges',
                            style: montserratMedium.copyWith(
                              color: ColorTheme.grey1,
                              fontSize: 15,
                            )),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.symmetric(horizontal: 10.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(
                          //         'Add New Delivery Charge',
                          //         style: montserratSemiBold.copyWith(
                          //           color: ColorTheme.grey1,
                          //           fontSize: 14,
                          //         ),
                          //       ),
                          //       const Spacer(),
                          //       IconButton(
                          //           onPressed: () {
                          //             controller.clearDeliveryCharge();

                          //             deliveryChargeBottomSheet(
                          //               context,
                          //               deliveryManagementController:
                          //                   controller,
                          //               onTap: () {
                          //                 controller.addDeliveryCharge();
                          //                 Get.back();
                          //               },
                          //             );
                          //           },
                          //           icon: Icon(
                          //             Icons.add_circle_outline,
                          //             color: ColorTheme.appColor,
                          //             size: 30,
                          //           )),
                          //     ],
                          //   ),
                          // ),
                          // const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.deliveryCharges.length,
                            itemBuilder: (context, index) {
                              final charge = controller.deliveryCharges[index];
                              final Color bgColor = index % 2 == 0
                                  ? Color.fromARGB(255, 255, 251, 216)
                                  : Color.fromARGB(255, 255, 238, 238);

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: ColorTheme.whiteE4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              style: normalStyle,
                                              children: [
                                                TextSpan(
                                                    text: 'Min. Dist. : ',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text:
                                                        '${charge['min_distance_km'] ?? ''} km',
                                                    style: montserratMedium
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text:
                                                        '      ', // 6 letter spacing
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text: ' Max. Dist. : ',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text:
                                                        '${charge['max_distance_km'] ?? ''} km',
                                                    style: montserratMedium
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text: '      ',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text: 'Min Order : ',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text:
                                                        '${charge['min_order_value'] ?? ''}',
                                                    style: montserratMedium
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text: '      ',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text: 'Charge : ',
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                                TextSpan(
                                                    text:
                                                        '${charge['charge'] ?? ''}',
                                                    style: montserratMedium
                                                        .copyWith(
                                                      color: ColorTheme.grey1,
                                                      fontSize: 14,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.black87),
                                      onPressed: () => controller
                                          .deleteDeliveryCharge(charge['id']),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar:
            GetBuilder<DeliveryManagementController>(builder: (controller) {
          if (controller.isLoading) {
            return const SizedBox.shrink();
          }
          return Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
            decoration: BoxDecoration(color: ColorTheme.white),
            child: Row(
              children: [
                // Left: Update Basic Settings button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.updateBasicSettings();
                    },
                    child: Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorTheme.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Update Basic Setting',
                            style: montserratMedium.copyWith(
                              color: ColorTheme.white,
                              fontSize: 16,
                            ),
                          ),
                        )),
                  ),
                ),

                const SizedBox(width: 5),

                //  Add Delivery Charge
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.clearDeliveryCharge();
                      deliveryChargeBottomSheet(
                        context,
                        deliveryManagementController: controller,
                        onTap: () {
                          controller.addDeliveryCharge();
                          Get.back();
                        },
                      );
                    },
                    child: Container(
                        height: 48,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorTheme.appColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Add Delivery Charge',
                            style: montserratMedium.copyWith(
                              color: ColorTheme.white,
                              fontSize: 16,
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          );
        }));
  }
}
