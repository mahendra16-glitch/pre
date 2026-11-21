import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CancellationMasterScreen extends StatefulWidget {
  @override
  State<CancellationMasterScreen> createState() =>
      _CancellationMasterScreenState();
}

class _CancellationMasterScreenState extends State<CancellationMasterScreen> {
  MenuManagementController? menuManagementController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    menuManagementController = Get.find<MenuManagementController>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Clear list first to avoid cache issues
    menuManagementController?.clearCancellationMasterList();
    // Then fetch fresh data
    await menuManagementController?.getCancellationMasterList();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.whiteColor,
        appBar: AppBar(
          title: Text(
            'Cancellation Reasons',
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
                menuManagementController?.clearCancellationMasterList();
                await menuManagementController?.getCancellationMasterList();
              },
              tooltip: 'Refresh',
            ),
            10.width
          ],
        ),
        body: Column(
          children: [
            // Add Reason Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: ColorTheme.grey200Color),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        menuManagementController
                                    ?.editingCancellationReasonId.value ==
                                -1
                            ? 'Add Cancellation Reason'
                            : 'Edit Cancellation Reason',
                        style: montserratMedium.copyWith(
                          fontSize: 13,
                          color: ColorTheme.grey8C,
                        ),
                      )),
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
                        child: Obx(() => TextFormField(
                              controller: menuManagementController!
                                  .cancellationMasterAddController,
                              autofocus: menuManagementController
                                      ?.editingCancellationReasonId.value !=
                                  -1,
                              decoration: InputDecoration(
                                hintText: 'Enter cancellation reason',
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
                            )),
                      ),
                      // 10.width,
                      // GetBuilder<MenuManagementController>(
                      //   builder: (controller) {
                      //     return Container(
                      //       width: 140,
                      //       height: 48,
                      //       padding: EdgeInsets.symmetric(horizontal: 12),
                      //       decoration: BoxDecoration(
                      //         color: ColorTheme.whiteColor,
                      //         borderRadius: BorderRadius.circular(8),
                      //         border: Border.all(
                      //           color: ColorTheme.transparent,
                      //           width: 2,
                      //         ),
                      //       ),
                      //       child: DropdownButtonHideUnderline(
                      //         child: DropdownButton<String>(
                      //           value: controller.selectedUserType,
                      //           hint: Text(
                      //             'User Type',
                      //             style: montserratMedium.copyWith(
                      //               fontSize: 14,
                      //               color: ColorTheme.greyBE,
                      //             ),
                      //           ),
                      //           isExpanded: true,
                      //           icon: Icon(
                      //             Icons.keyboard_arrow_down,
                      //             color: ColorTheme.greyBE,
                      //           ),
                      //           items: controller.userTypeOptions
                      //               .map<DropdownMenuItem<String>>(
                      //             (String value) {
                      //               return DropdownMenuItem<String>(
                      //                 value: value,
                      //                 child: Text(
                      //                   value.toUpperCase(),
                      //                   style: montserratMedium.copyWith(
                      //                     fontSize: 14,
                      //                     color: Colors.black,
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           ).toList(),
                      //           onChanged: (String? newValue) {
                      //             controller.selectedUserType = newValue;
                      //             controller.update();
                      //           },
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),

                      10.width,
                      Obx(() {
                        final isEditing = menuManagementController
                                ?.editingCancellationReasonId.value !=
                            -1;
                        final isSubmitting = menuManagementController
                                ?.isCancellationMasterSubmitting.value ==
                            true;
                        final isUpdating = menuManagementController
                                ?.isCancellationMasterUpdating.value ==
                            true;

                        return ElevatedButton(
                          onPressed: (isSubmitting || isUpdating)
                              ? null
                              : () async {
                                  final text = menuManagementController!
                                      .cancellationMasterAddController.text
                                      .trim();

                                  if (text.isEmpty) {
                                    Get.snackbar(
                                      'Validation',
                                      'Please enter cancellation reason',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }

                                  if (isEditing) {
                                    // Update mode
                                    final editingId = menuManagementController
                                        ?.editingCancellationReasonId.value;
                                    if (editingId != null && editingId != -1) {
                                      // Get the current reason to get user_type
                                      final currentReason =
                                          menuManagementController!
                                              .cancellationMasterList
                                              .firstWhere(
                                        (r) => r['id'] == editingId,
                                        orElse: () => {},
                                      );
                                      final userType =
                                          currentReason['user_type']
                                                  ?.toString() ??
                                              'restaurant';
                                      await menuManagementController
                                          ?.updateCancellationReason(
                                        editingId,
                                        text,
                                        userType,
                                      );
                                    }
                                  } else {
                                    // Add mode
                                    await menuManagementController
                                        ?.addCancellationMasterReason();
                                  }
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
                          child: (isSubmitting || isUpdating)
                              ? SizedBox(
                                  width: 30,
                                  height: 20,
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                )
                              : Text(
                                  isEditing ? 'Update' : 'Add',
                                  style: poppinsMedium.copyWith(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                        );
                      }),
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
            //       menuManagementController?.update();
            //     },
            //     controller: menuManagementController!
            //         .cancellationMasterSearchController,
            //     showCursor: true,
            //     cursorColor: ColorTheme.greyBE,
            //     cursorHeight: 15.0,
            //     cursorRadius: Radius.circular(10),
            //     cursorWidth: 2.0,
            //     decoration: InputDecoration(
            //       fillColor: ColorTheme.whiteColor,
            //       filled: true,
            //       hintText: 'Search cancellation reasons',
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
                          'REASON',
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
                          'TYPE',
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
                        'ACTION',
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

            // List of Cancellation Reasons
            Expanded(
              child: GetBuilder<MenuManagementController>(
                builder: (controller) {
                  final filteredList =
                      controller.getFilteredCancellationMasterList();

                  if (controller.isCancellationMasterLoading.value) {
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
                            'No cancellation reason found',
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
                    controller: _scrollController,
                    itemCount: filteredList.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final reason = filteredList[index];
                      final reasonId = reason['id'] as int? ?? 0;
                      final reasonText = reason['reason'] as String? ?? '';

                      return GetBuilder<MenuManagementController>(
                        id: 'cancellation_item_$reasonId',
                        builder: (controller) {
                          // Get current status from the controller's list
                          final currentReason =
                              controller.cancellationMasterList.firstWhere(
                            (r) => r['id'] == reasonId,
                            orElse: () => reason,
                          );
                          final currentStatus =
                              currentReason['status'] as int? ?? 0;
                          final currentIsActive = currentStatus == 1;
                          final userType =
                              currentReason['user_type'] as String? ?? '';

                          return Container(
                            key: ValueKey(reasonId),
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
                                // Reason Column
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
                                      reasonText,
                                      style: montserratMedium.copyWith(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),

                                // Type Column
                                Expanded(
                                  flex: 2,
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
                                      userType,
                                      textAlign: TextAlign.center,
                                      style: montserratMedium.copyWith(
                                        fontSize: 13,
                                        color: Colors.blue,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),

                                // Status Column
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color:
                                              ColorTheme.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        child: Obx(() {
                                          final isThisItemUpdating = controller
                                                  .updatingCancellationReasonId
                                                  .value ==
                                              reasonId;

                                          if (isThisItemUpdating) {
                                            return Transform.scale(
                                              scale: 0.7,
                                              child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child:
                                                    CircularProgressIndicator(
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
                                                    .updateCancellationMasterStatus(
                                                        reasonId,
                                                        currentStatus);
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
                                ),

                                // Actions Column
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Edit Button
                                        Obx(() {
                                          final isEditingThisItem = controller
                                                  .editingCancellationReasonId
                                                  .value ==
                                              reasonId;
                                          return IconButton(
                                            icon: Icon(
                                              isEditingThisItem
                                                  ? Icons.close
                                                  : Icons.edit_outlined,
                                              color: isEditingThisItem
                                                  ? Colors.red
                                                  : ColorTheme.appColor,
                                              size: 22,
                                            ),
                                            onPressed: (controller
                                                        .isCancellationMasterStatusUpdating
                                                        .value ||
                                                    controller
                                                        .isCancellationMasterUpdating
                                                        .value ||
                                                    controller
                                                        .isCancellationMasterDeleting
                                                        .value)
                                                ? null
                                                : () {
                                                    if (isEditingThisItem) {
                                                      // Cancel edit mode
                                                      controller
                                                          .cancellationMasterAddController
                                                          .clear();
                                                      controller
                                                              .selectedUserType =
                                                          null;
                                                      controller
                                                          .editingCancellationReasonId
                                                          .value = -1;
                                                    } else {
                                                      // Enter edit mode
                                                      controller
                                                          .cancellationMasterAddController
                                                          .text = reasonText;
                                                      controller
                                                              .selectedUserType =
                                                          userType;
                                                      controller
                                                          .editingCancellationReasonId
                                                          .value = reasonId;
                                                      // Scroll to top
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        if (_scrollController
                                                            .hasClients) {
                                                          _scrollController.animateTo(
                                                              0,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      300),
                                                              curve: Curves
                                                                  .easeInOut);
                                                        }
                                                      });
                                                    }
                                                  },
                                            tooltip: isEditingThisItem
                                                ? 'Cancel Edit'
                                                : 'Edit',
                                          );
                                        }),
                                        // Delete Button
                                        Obx(() => IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                              onPressed: (controller
                                                          .isCancellationMasterStatusUpdating
                                                          .value ||
                                                      controller
                                                          .isCancellationMasterUpdating
                                                          .value ||
                                                      controller
                                                          .isCancellationMasterDeleting
                                                          .value)
                                                  ? null
                                                  : () {
                                                      _showDeleteDialog(
                                                          context,
                                                          controller,
                                                          reasonId,
                                                          reasonText);
                                                    },
                                              tooltip: 'Delete',
                                            )),
                                      ],
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

  /// Show delete confirmation bottom sheet
  void _showDeleteDialog(BuildContext context,
      MenuManagementController controller, int reasonId, String reasonText) {
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
                'Delete Cancellation Reason',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to delete cancellation reason "${reasonText}"?',
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
                    child: Obx(() => ElevatedButton(
                          onPressed: controller
                                  .isCancellationMasterDeleting.value
                              ? null
                              : () {
                                  controller.deleteCancellationReason(reasonId);
                                  Navigator.of(context).pop();
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
                          child: controller.isCancellationMasterDeleting.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Delete',
                                  style: montserratSemiBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                        )),
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
    _scrollController.dispose();
    menuManagementController?.cancellationMasterAddController.clear();
    menuManagementController?.cancellationMasterSearchController.clear();
    // Clear edit mode on dispose
    menuManagementController?.editingCancellationReasonId.value = -1;
    super.dispose();
  }
}
