import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/custome management/controller/customer_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDesignationMasterScreen extends StatefulWidget {
  @override
  State<CustomerDesignationMasterScreen> createState() =>
      _CustomerDesignationMasterScreenState();
}

class _CustomerDesignationMasterScreenState
    extends State<CustomerDesignationMasterScreen> {
  CustomerManagementController? customerManagementController;

  @override
  void initState() {
    super.initState();
    customerManagementController = Get.find<CustomerManagementController>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Clear list first to avoid cache issues
    customerManagementController?.clearCustomerDesignationList();
    // Then fetch fresh data
    await customerManagementController?.getCustomerDesignationList();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.whiteColor,
        appBar: AppBar(
          title: Text(
            'Customer Designations',
            style: montserratSemiBold.copyWith(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          titleSpacing: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: ColorTheme.green,
            ),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.appColor,
                size: 24,
              ),
              onPressed: () async {
                customerManagementController?.clearCustomerDesignationList();
                await customerManagementController
                    ?.getCustomerDesignationList();
              },
              tooltip: 'Refresh',
            ),
            10.width
          ],
        ),
        body: Column(
          children: [
            // Add Designation Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: ColorTheme.grey200Color),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Customer Designation',
                    style: montserratMedium.copyWith(
                      fontSize: 13,
                      color: ColorTheme.grey8C,
                    ),
                  ),
                  10.height,
                  SizedBox(
                    height: 20,
                    width: double.infinity,
                    child: DottedLine(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      lineThickness: 1.0,
                      dashLength: 2.5,
                      dashColor: ColorTheme.greyColor,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: customerManagementController!
                              .customerDesignationAddController,
                          decoration: InputDecoration(
                            hintText: 'Enter designation name',
                            hintStyle: montserratMedium.copyWith(
                              fontSize: 14,
                              color: ColorTheme.greyBE,
                            ),
                            filled: true,
                            fillColor: ColorTheme.whiteColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: ColorTheme.transparent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: ColorTheme.transparent,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: ColorTheme.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          style: montserratMedium.copyWith(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      10.width,
                      Obx(() => ElevatedButton(
                            onPressed: customerManagementController
                                        ?.isCustomerDesignationSubmitting
                                        .value ==
                                    true
                                ? null
                                : () async {
                                    await customerManagementController
                                        ?.addCustomerDesignation();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTheme.appColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: customerManagementController
                                        ?.isCustomerDesignationSubmitting
                                        .value ==
                                    true
                                ? SizedBox(
                                    width: 30,
                                    height: 20,
                                    child: SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                  )
                                : Text(
                                    'Add',
                                    style: poppinsMedium.copyWith(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            // Container(
            //   padding: EdgeInsets.all(20),
            //   decoration: BoxDecoration(color: ColorTheme.grey200Color),
            //   child: TextFormField(
            //     onChanged: (value) {
            //       customerManagementController?.update();
            //     },
            //     controller: customerManagementController!
            //         .customerDesignationSearchController,
            //     showCursor: true,
            //     cursorColor: ColorTheme.greyBE,
            //     cursorHeight: 15.0,
            //     cursorRadius: Radius.circular(10),
            //     cursorWidth: 2.0,
            //     decoration: InputDecoration(
            //       fillColor: ColorTheme.whiteColor,
            //       filled: true,
            //       hintText: 'Search designations',
            //       prefixIcon: Icon(Icons.search, color: ColorTheme.greyBE),
            //       hintStyle: montserratMedium.copyWith(
            //         fontSize: 14,
            //         color: ColorTheme.greyBE,
            //       ),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8),
            //         borderSide: BorderSide(
            //           width: 2,
            //           color: ColorTheme.transparent,
            //         ),
            //       ),
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8),
            //         borderSide: BorderSide(
            //           width: 2,
            //           color: ColorTheme.transparent,
            //         ),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8),
            //         borderSide: BorderSide(
            //           color: ColorTheme.transparent,
            //         ),
            //       ),
            //     ),
            //     style: montserratMedium.copyWith(
            //       fontSize: 14,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),

            // Table Header
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: ColorTheme.whiteColor,
                border: Border(
                  top: BorderSide(
                    color: ColorTheme.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: ColorTheme.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: ColorTheme.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'DESIGNATION',
                          style: montserratSemiBold.copyWith(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: ColorTheme.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'STATUS',
                          style: montserratSemiBold.copyWith(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'DELETE',
                        style: montserratSemiBold.copyWith(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List of Customer Designations
            Expanded(
              child: GetBuilder<CustomerManagementController>(
                builder: (controller) {
                  final filteredList =
                      controller.getFilteredCustomerDesignationList();

                  if (controller.isCustomerDesignationLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: ColorTheme.green,
                      ),
                    );
                  }

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: ColorTheme.greyBE,
                          ),
                          16.height,
                          Text(
                            'No designation found',
                            style: montserratMedium.copyWith(
                              fontSize: 16,
                              color: ColorTheme.greyBE,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final designation = filteredList[index];
                      final designationId = designation['id'] as int? ?? 0;
                      final designationText =
                          designation['designation'] as String? ?? '';

                      return GetBuilder<CustomerManagementController>(
                        id: 'designation_item_$designationId',
                        builder: (controller) {
                          // Get current status from the controller's list
                          final currentDesignation =
                              controller.customerDesignationList.firstWhere(
                            (d) => d['id'] == designationId,
                            orElse: () => designation,
                          );
                          // List API doesn't return status initially, default to 1 (active)
                          // Status will be updated after toggle-status API call
                          final currentStatus =
                              currentDesignation['status'] as int? ?? 1;
                          final currentIsActive = currentStatus == 1;

                          return Container(
                            key: ValueKey(designationId),
                            decoration: BoxDecoration(
                              color: ColorTheme.whiteColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: ColorTheme.grey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Designation Column
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color:
                                              ColorTheme.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      designationText,
                                      style: montserratMedium.copyWith(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),

                                // Status Column
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Obx(() {
                                        final isThisItemUpdating = controller
                                                .updatingDesignationId.value ==
                                            designationId;

                                        if (isThisItemUpdating) {
                                          return Transform.scale(
                                            scale: 0.7,
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  ColorTheme.appColor,
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        return Transform.scale(
                                          scale: 0.7,
                                          child: Switch(
                                            value: currentIsActive,
                                            onChanged: (bool value) async {
                                              await controller
                                                  .toggleCustomerDesignationStatus(
                                                      designationId);
                                            },
                                            activeColor: ColorTheme.green,
                                            trackOutlineColor:
                                                WidgetStateProperty.all(
                                                    ColorTheme.green),
                                            inactiveThumbColor:
                                                ColorTheme.greenColor,
                                            inactiveTrackColor: ColorTheme
                                                .greyBE
                                                .withOpacity(0.3),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),

                                // Delete Column
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color:
                                              ColorTheme.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Obx(() {
                                        final isThisItemDeleting = controller
                                                .deletingDesignationId.value ==
                                            designationId;

                                        if (isThisItemDeleting) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  ColorTheme.appColor,
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        return IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          onPressed: controller
                                                  .isCustomerDesignationDeleting
                                                  .value
                                              ? null
                                              : () {
                                                  _showDeleteConfirmationBottomSheet(
                                                      context,
                                                      designation,
                                                      controller);
                                                },
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Delete Confirmation Bottom Sheet
  void _showDeleteConfirmationBottomSheet(
      BuildContext context,
      Map<String, dynamic> designation,
      CustomerManagementController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorTheme.redColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 40,
                  color: ColorTheme.redColor,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                'Delete Designation',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to delete designation "${designation['designation'] ?? 'N/A'}"?',
                textAlign: TextAlign.center,
                style: montserratRegular.copyWith(
                  color: ColorTheme.grey1,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: ColorTheme.whiteColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: ColorTheme.borderGrey2),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: montserratSemiBold.copyWith(
                          color: ColorTheme.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteCustomerDesignation(designation['id']);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: ColorTheme.redColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: montserratSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    customerManagementController?.customerDesignationAddController.clear();
    customerManagementController?.customerDesignationSearchController.clear();
    super.dispose();
  }
}
