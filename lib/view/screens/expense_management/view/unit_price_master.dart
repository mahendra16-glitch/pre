import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';

class UnitPriceMasterScreen extends StatefulWidget {
  @override
  State<UnitPriceMasterScreen> createState() => _UnitPriceMasterScreenState();
}

class _UnitPriceMasterScreenState extends State<UnitPriceMasterScreen> {
  ExpenseManagementController? expenseController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _stockSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    expenseController = Get.find<ExpenseManagementController>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Clear list first to avoid cache issues
    expenseController?.clearUnitPriceMasterList();
    // Fetch expenses without unit prices for dropdown
    await expenseController?.getExpensesWithoutUnitPrices();
    // Then fetch fresh unit price data
    await expenseController?.getUnitPriceMasterList();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.whiteColor,
        appBar: AppBar(
          title: Text(
            'Unit Price Master',
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
            // Bulk Import/Export Icon Buttons
            GetBuilder<ExpenseManagementController>(builder: (controller) {
              return uploadIconWidget(
                onDownLoadTap: () async {
                  // Navigate to Bulk Import Screen for download operations
                  Get.to(() => BulkImportScreen(
                        tittleName: 'Unit Price Master',
                        isFunction: true,
                        onuploadTap: () {
                          // upload the unit price master stock
                          controller.importUnitPriceMaster();
                        },
                        onDownloadExistingDataTap: () {
                          // export the unit price master stock
                          controller.exportUnitPriceMaster(isSample: false);
                        },
                        onDownloadSampleDataTap: () {
                          // export the unit price master stock -- there is no sample it is same as existing
                          controller.exportUnitPriceMaster(isSample: true);
                        },
                        controller: Get.find<ExpenseManagementController>(),
                      ));
                },
                onUploadTap: () async {
                  // Navigate to Bulk Import Screen for upload operations
                  Get.to(() => BulkImportScreen(
                        tittleName: 'Unit Price Master',
                        isFunction: true,
                        onuploadTap: () {
                          // upload the unit price master stock
                          controller.importUnitPriceMaster();
                        },
                        onDownloadExistingDataTap: () {
                          // export the unit price master stock
                          controller.exportUnitPriceMaster(isSample: false);
                        },
                        onDownloadSampleDataTap: () {
                          // export the unit price master stock -- there is no sample it is same as existing
                          controller.exportUnitPriceMaster(isSample: true);
                        },
                        controller: Get.find<ExpenseManagementController>(),
                      ));
                },
                isPLusShow: false,
                onPlusTap: () {},
              );
            }),
            // 10.width,
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: ColorTheme.appColor,
                size: 28,
              ),
              onPressed: () async {
                expenseController?.clearUnitPriceMasterList();
                await expenseController?.getExpensesWithoutUnitPrices();
                await expenseController?.getUnitPriceMasterList();
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            // Add/Edit Unit Price Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: ColorTheme.grey200Color),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          expenseController?.editingUnitPriceMasterId.value ==
                                  -1
                              ? 'Add Unit Price'
                              : 'Edit Unit Price',
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
                    // Stock Name Dropdown (hidden in edit mode)
                    Obx(() {
                      final isEditing =
                          expenseController?.editingUnitPriceMasterId.value !=
                              -1;
                      if (isEditing) return SizedBox.shrink();

                      return Column(
                        children: [
                          // 10.height,
                          GetBuilder<ExpenseManagementController>(
                            builder: (controller) {
                              // Find selected stock from expensesWithoutUnitPricesList
                              Map<String, dynamic>? selectedStock;
                              if (controller.selectedStockId != null &&
                                  controller.expensesWithoutUnitPricesList
                                      .isNotEmpty) {
                                try {
                                  selectedStock = controller
                                      .expensesWithoutUnitPricesList
                                      .firstWhere(
                                    (element) =>
                                        element['id'] ==
                                        controller.selectedStockId,
                                  );
                                } catch (e) {
                                  selectedStock = null;
                                }
                              }

                              return DropdownButtonHideUnderline(
                                child: DropdownButtonFormField2<
                                    Map<String, dynamic>>(
                                  value: selectedStock,
                                  isExpanded: true,
                                  items: controller
                                      .expensesWithoutUnitPricesList
                                      .map((Map<String, dynamic> stock) {
                                    return DropdownMenuItem<
                                        Map<String, dynamic>>(
                                      value: stock,
                                      child: Text(
                                        stock['stock_title']?.toString() ?? '',
                                        style: montserratMedium.copyWith(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Map<String, dynamic>? newValue) {
                                    if (newValue != null) {
                                      controller.selectedStockId =
                                          newValue['id'] as int?;
                                      controller.selectedStockName =
                                          newValue['stock_title']?.toString();
                                      controller.update();
                                    }
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    height: 45,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight:
                                        300, // Increased to accommodate search field
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: ColorTheme.whiteColor,
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40,
                                  ),
                                  // ADD THIS - Searchable Dropdown Configuration
                                  dropdownSearchData: DropdownSearchData(
                                    searchController: _stockSearchController,
                                    searchInnerWidgetHeight: 50,
                                    searchInnerWidget: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 4,
                                        right: 8,
                                        left: 8,
                                      ),
                                      child: TextFormField(
                                        expands: true,
                                        maxLines: null,
                                        controller: _stockSearchController,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          hintText: 'Search stock name...',
                                          hintStyle: montserratMedium.copyWith(
                                            fontSize: 12,
                                            color: ColorTheme.grey8C,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: ColorTheme.appColor,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: ColorTheme.grey8C
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: ColorTheme.appColor,
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
                                    // Custom search function - case insensitive
                                    searchMatchFn: (item, searchValue) {
                                      final stockTitle = item
                                              .value?['stock_title']
                                              ?.toString() ??
                                          '';
                                      return stockTitle
                                          .toLowerCase()
                                          .contains(searchValue.toLowerCase());
                                    },
                                  ),
                                  // Clear search when dropdown closes
                                  onMenuStateChange: (isOpen) {
                                    if (!isOpen) {
                                      _stockSearchController.clear();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Select Stock Name',
                                    labelStyle: montserratMedium.copyWith(
                                      fontSize: 12,
                                      color: ColorTheme.grey8C,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    filled: true,
                                    isDense: false,
                                    fillColor: ColorTheme.whiteColor,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
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
                                ),
                              );
                            },
                          ),

                          10.height,
                          // Quantity and Price Fields in same row
                          Row(
                            children: [
                              // Expanded(
                              //   child: TextFormField(
                              //     controller: expenseController!
                              //         .unitPriceMasterQuantityController,
                              //     keyboardType: TextInputType.number,
                              //     decoration: InputDecoration(
                              //       labelText: 'Enter quantity',
                              //       labelStyle: montserratMedium.copyWith(
                              //         fontSize: 12,
                              //         color: ColorTheme.grey8C,
                              //       ),
                              //       floatingLabelBehavior:
                              //           FloatingLabelBehavior.auto,
                              //       filled: true,
                              //       fillColor: ColorTheme.whiteColor,
                              //       contentPadding: EdgeInsets.symmetric(
                              //         horizontal: 16,
                              //         vertical: 12,
                              //       ),
                              //       border: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(8),
                              //         borderSide: BorderSide(
                              //           color: ColorTheme.transparent,
                              //           width: 2,
                              //         ),
                              //       ),
                              //       enabledBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(8),
                              //         borderSide: BorderSide(
                              //           color: ColorTheme.transparent,
                              //           width: 2,
                              //         ),
                              //       ),
                              //       focusedBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(8),
                              //         borderSide: BorderSide(
                              //           color: ColorTheme.transparent,
                              //           width: 2,
                              //         ),
                              //       ),
                              //     ),
                              //     style: montserratMedium.copyWith(
                              //       fontSize: 14,
                              //       color: Colors.black,
                              //     ),
                              //   ),
                              // ),
                              // 10.width,
                              Expanded(
                                child: TextFormField(
                                  controller: expenseController!
                                      .unitPriceMasterPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Enter price',
                                    labelStyle: montserratMedium.copyWith(
                                      fontSize: 12,
                                      color: ColorTheme.grey8C,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
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
                            ],
                          ),
                        ],
                      );
                    }),
                    10.height,
                    // Price Field (only visible in edit mode)
                    Obx(() {
                      final isEditing =
                          expenseController?.editingUnitPriceMasterId.value !=
                              -1;
                      if (!isEditing) return SizedBox.shrink();

                      return TextFormField(
                        controller:
                            expenseController!.unitPriceMasterPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter price',
                          labelStyle: montserratMedium.copyWith(
                            fontSize: 12,
                            color: ColorTheme.grey8C,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                      );
                    }),
                    10.height,
                    Obx(() {
                      final isEditing =
                          expenseController?.editingUnitPriceMasterId.value !=
                              -1;
                      final isSubmitting = expenseController
                              ?.isUnitPriceMasterSubmitting.value ==
                          true;
                      final isUpdating =
                          expenseController?.isUnitPriceMasterUpdating.value ==
                              true;

                      return ElevatedButton(
                        onPressed: (isSubmitting || isUpdating)
                            ? null
                            : () async {
                                if (isEditing) {
                                  // Update mode - only price can be edited
                                  final editingId = expenseController
                                      ?.editingUnitPriceMasterId.value;
                                  if (editingId != null && editingId != -1) {
                                    await expenseController
                                        ?.updateUnitPriceMaster(
                                      editingId,
                                      expenseController!
                                          .unitPriceMasterPriceController.text,
                                    );
                                  }
                                } else {
                                  // Add mode
                                  await expenseController?.addUnitPriceMaster();
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
                  ]),
            ),

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
                    flex: 4,
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
                          'STOCK NAME',
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
                          'PRICE',
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

            // List of Unit Prices
            Expanded(
              child: GetBuilder<ExpenseManagementController>(
                builder: (controller) {
                  final filteredList =
                      controller.getFilteredUnitPriceMasterList();

                  if (controller.isUnitPriceMasterLoading.value) {
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
                            'No unit price found',
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
                      final item = filteredList[index];
                      final itemId = item['id'] as int? ?? 0;

                      return GetBuilder<ExpenseManagementController>(
                        id: 'unit_price_item_$itemId',
                        builder: (controller) {
                          final item = filteredList[index];
                          final itemId = item['id'] as int? ?? 0;
                          final stockName =
                              item['expense_name'] as String? ?? '';
                          final quantity = item['quantity'] as int? ?? 0;
                          final price = item['price'] as String? ?? '0.00';

                          return Container(
                            key: ValueKey(itemId),
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
                                // Stock Name Column with Quantity below
                                Expanded(
                                  flex: 4,
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stockName,
                                          style: montserratMedium.copyWith(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Qty: $quantity',
                                          style: montserratMedium.copyWith(
                                            fontSize: 12,
                                            color: ColorTheme.grey8C,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Price Column
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
                                        child: Text(
                                          '₹ $price',
                                          style: montserratMedium.copyWith(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
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
                                                  .editingUnitPriceMasterId
                                                  .value ==
                                              itemId;
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
                                                        .isUnitPriceMasterUpdating
                                                        .value ||
                                                    controller
                                                        .isUnitPriceMasterDeleting
                                                        .value)
                                                ? null
                                                : () {
                                                    if (isEditingThisItem) {
                                                      // Cancel edit mode
                                                      controller
                                                          .resetUnitPriceMasterForm();
                                                    } else {
                                                      // Enter edit mode
                                                      controller
                                                          .editingUnitPriceMasterId
                                                          .value = itemId;
                                                      controller
                                                          .unitPriceMasterPriceController
                                                          .text = price;
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
                                                          .isUnitPriceMasterUpdating
                                                          .value ||
                                                      controller
                                                          .isUnitPriceMasterDeleting
                                                          .value)
                                                  ? null
                                                  : () {
                                                      _showDeleteDialog(
                                                          context,
                                                          controller,
                                                          itemId,
                                                          stockName);
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
      ExpenseManagementController controller, int itemId, String stockName) {
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
                'Delete Unit Price',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to delete unit price for "$stockName"?',
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
                          onPressed: controller.isUnitPriceMasterDeleting.value
                              ? null
                              : () {
                                  controller.deleteUnitPriceMaster(itemId);
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
                          child: controller.isUnitPriceMasterDeleting.value
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
    expenseController?.resetUnitPriceMasterForm();
    _stockSearchController.dispose();
    super.dispose();
  }
}
