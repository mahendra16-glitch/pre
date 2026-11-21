import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WastageMasterScreen extends StatefulWidget {
  @override
  State<WastageMasterScreen> createState() => _WastageMasterScreenState();
}

class _WastageMasterScreenState extends State<WastageMasterScreen> {
  InventoryController? inventoryController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    inventoryController = Get.find<InventoryController>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Clear list first to avoid cache issues
    inventoryController?.clearWastageMasterList();
    // Then fetch fresh data
    await inventoryController?.getWastageMasterList();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.whiteColor,
        appBar: AppBar(
          title: Text(
            'Wastage Reasons',
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
                inventoryController?.clearWastageMasterList();
                await inventoryController?.getWastageMasterList();
              },
              tooltip: 'Refresh',
            ),
            10.width
          ],
        ),
        body: Column(
          children: [
            // Add/Edit Reason Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: ColorTheme.grey200Color),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          inventoryController?.editingWastageReasonId.value ==
                                  -1
                              ? 'Add Wastage Reason'
                              : 'Edit Wastage Reason',
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
                    // 10.height,
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => TextFormField(
                                controller: inventoryController!
                                    .wastageMasterAddController,
                                autofocus: inventoryController
                                        ?.editingWastageReasonId.value !=
                                    -1,
                                decoration: InputDecoration(
                                  hintText: 'Enter wastage reason',
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
                        10.width,
                        Obx(() {
                          final isEditing = inventoryController
                                  ?.editingWastageReasonId.value !=
                              -1;
                          final isSubmitting = inventoryController
                                  ?.isWastageMasterSubmitting.value ==
                              true;
                          final isUpdating = inventoryController
                                  ?.isWastageMasterUpdating.value ==
                              true;

                          return ElevatedButton(
                            onPressed: (isSubmitting || isUpdating)
                                ? null
                                : () async {
                                    final text = inventoryController!
                                        .wastageMasterAddController.text
                                        .trim();

                                    if (text.isEmpty) {
                                      Get.snackbar(
                                        'Validation',
                                        'Please enter wastage reason',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }

                                    if (isEditing) {
                                      // Update mode
                                      final editingId = inventoryController
                                          ?.editingWastageReasonId.value;
                                      if (editingId != null &&
                                          editingId != -1) {
                                        await inventoryController
                                            ?.updateWastageReason(
                                          editingId,
                                          text,
                                        );
                                      }
                                    } else {
                                      // Add mode
                                      await inventoryController
                                          ?.addWastageMasterReason();
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
                  ]),
            ),

            // // Search Bar
            // Container(
            //   padding: EdgeInsets.all(20),
            //   decoration: BoxDecoration(color: ColorTheme.grey200Color),
            //   child: TextFormField(
            //     onChanged: (value) {
            //       inventoryController?.update();
            //     },
            //     controller: inventoryController!.wastageMasterSearchController,
            //     showCursor: true,
            //     cursorColor: ColorTheme.greyBE,
            //     cursorHeight: 15.0,
            //     cursorRadius: Radius.circular(10),
            //     cursorWidth: 2.0,
            //     decoration: InputDecoration(
            //       fillColor: ColorTheme.whiteColor,
            //       filled: true,
            //       hintText: 'Search wastage reasons',
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

            // Wastage Reason List Title and Divider
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            //   decoration: BoxDecoration(color: ColorTheme.white),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Wastage Reason List',
            //         style: montserratMedium.copyWith(
            //           fontSize: 13,
            //           color: ColorTheme.grey8C,
            //         ),
            //       ),
            //       10.height,
            //       SizedBox(
            //         height: 20,
            //         width: double.infinity,
            //         child: DottedLine(
            //           direction: Axis.horizontal,
            //           alignment: WrapAlignment.center,
            //           lineThickness: 1.0,
            //           dashLength: 2.5,
            //           dashColor: ColorTheme.greyColor,
            //         ),
            //       ),
            //     ],
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
                    flex: 3,
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

            // List of Wastage Reasons
            Expanded(
              child: GetBuilder<InventoryController>(
                builder: (controller) {
                  final filteredList =
                      controller.getFilteredWastageMasterList();

                  if (controller.isWastageMasterLoading.value) {
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
                            'No wastage reason found',
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

                      return GetBuilder<InventoryController>(
                        id: 'wastage_item_$reasonId', // Unique ID for each item
                        builder: (controller) {
                          // Get the latest status from the controller's list
                          final reason = filteredList[index];
                          final reasonId = reason['id'] as int? ?? 0;
                          final reasonText = reason['reason'] as String? ?? '';

                          // Get current status
                          final currentReason =
                              controller.wastageMasterList.firstWhere(
                            (r) => r['id'] == reasonId,
                            orElse: () => reason,
                          );
                          final currentStatus =
                              currentReason['status'] as int? ?? 0;
                          final currentIsActive = currentStatus == 1;

                          return Container(
                            key: ValueKey(reasonId), // Unique key for each item
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

                                // Status Column
                                Expanded(
                                  flex: 3,
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
                                                  .updatingWastageReasonId
                                                  .value ==
                                              reasonId;

                                          if (isThisItemUpdating) {
                                            // Show loader only for this specific item
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

                                          // Show switch for all other items
                                          return Transform.scale(
                                            scale: 0.7,
                                            child: Switch(
                                              value: currentIsActive,
                                              onChanged: (bool value) async {
                                                await controller
                                                    .updateWastageMasterStatus(
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
                                                  .editingWastageReasonId
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
                                                        .isWastageMasterStatusUpdating
                                                        .value ||
                                                    controller
                                                        .isWastageMasterUpdating
                                                        .value ||
                                                    controller
                                                        .isWastageMasterDeleting
                                                        .value)
                                                ? null
                                                : () {
                                                    if (isEditingThisItem) {
                                                      // Cancel edit mode
                                                      controller
                                                          .wastageMasterAddController
                                                          .clear();
                                                      controller
                                                          .editingWastageReasonId
                                                          .value = -1;
                                                    } else {
                                                      // Enter edit mode
                                                      controller
                                                          .wastageMasterAddController
                                                          .text = reasonText;
                                                      controller
                                                          .editingWastageReasonId
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
                                                          .isWastageMasterStatusUpdating
                                                          .value ||
                                                      controller
                                                          .isWastageMasterUpdating
                                                          .value ||
                                                      controller
                                                          .isWastageMasterDeleting
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
  void _showDeleteDialog(BuildContext context, InventoryController controller,
      int reasonId, String reasonText) {
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
                'Delete Wastage Reason',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to delete wastage reason "${reasonText}"?',
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
                          onPressed: controller.isWastageMasterDeleting.value
                              ? null
                              : () {
                                  controller.deleteWastageReason(reasonId);
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
                          child: controller.isWastageMasterDeleting.value
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
    inventoryController?.wastageMasterAddController.clear();
    inventoryController?.wastageMasterSearchController.clear();
    // Clear edit mode on dispose
    inventoryController?.editingWastageReasonId.value = -1;
    super.dispose();
  }
}
