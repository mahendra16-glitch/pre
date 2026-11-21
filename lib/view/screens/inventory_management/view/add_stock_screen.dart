import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart' show AppStyle;
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/remove_string_point00.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/bottomsheet/vendor_form_sheet.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/custom_auto_complete.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/widget/my_custom_button.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'add_Ingredients_screen.dart';

class AddStockScreen extends StatefulWidget {
  final bool? isEditStock, isAddPLusStock, isAddMultipleStock, isSubRecipeStock;
  final Map<String, dynamic> stock;

  const AddStockScreen({
    Key? key,
    this.isEditStock = false,
    this.isAddMultipleStock = false,
    required this.stock,
    this.isAddPLusStock = false,
    this.isSubRecipeStock = false,
  }) : super(key: key);

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  InventoryController? inventoryController;

  ExpenseManagementController? expenseController;

  @override
  void initState() {
    inventoryController = Get.find<InventoryController>();
    expenseController = Get.find<ExpenseManagementController>();
    super.initState();
    calling();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (widget.isEditStock == true) {
        getUnitInventoryCall();
        inventoryController?.addStockVendorController.text =
            widget.stock["vendor_name"];
        inventoryController?.purchaseList[0]["currentStock"].text =
            removeEndPoint00(widget.stock["quantity"].toString());
        inventoryController?.purchaseList[0]["unit"] =
            widget.stock["display_unit"].toString();
        inventoryController?.purchaseList[0]["ingredientsController"].text =
            widget.stock["stock_title"].toString();

        // Populate threshold fields
        inventoryController?.thresholdQtyController.text =
            widget.stock["min_qty_alert"]?.toString() ?? "";
        inventoryController?.thresholdUnitValue =
            widget.stock["min_unit_alert"]?.toString();

        if (inventoryController?.addStockVendorId != null) {
          inventoryController?.addStockVendorId =
              widget.stock["vendor_id"] ?? 0;
        }
      }
    });

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (widget.isAddPLusStock == true) {
        getUnitInventoryCall();
        inventoryController?.addStockVendorController.text =
            widget.stock["vendor_name"];

        inventoryController?.paymentTypeValue = null;
        inventoryController?.addStockTotalTaxController.clear();
        inventoryController?.addStockTotalFairController.clear();
        inventoryController?.addStockItemQuantityController.clear();
        inventoryController?.addStockTotalAmountController.clear();

        inventoryController?.addStockBrowseFilePath = null;
        inventoryController?.purchaseList[0]["currentStock"].text =
            removeEndPoint00(widget.stock["quantity"].toString());
        inventoryController?.purchaseList[0]["quantity"].clear();
        inventoryController?.purchaseList[0]["ingredientsController"].text =
            widget.stock["stock_title"];
        inventoryController?.purchaseList[0]["unit"] =
            widget.stock["display_unit"].toString();

        inventoryController?.purchaseList[0]["physicalQty"].clear();
        inventoryController?.purchaseList[0]["amount"].clear();
        if (widget.isSubRecipeStock == true) {
          inventoryController?.addStockubRecipeId =
              widget.stock['subrecipe_id'];
        }
      }
    });

    if (widget.isAddPLusStock == false && widget.isEditStock == false) {
      log("Main Stock.....");
      inventoryController?.clearStockData();
    }

    inventoryController?.addStockPurchaseDateController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  getUnitInventoryCall() async {
    Future.microtask(() async {
      await inventoryController?.getUnitInventory(widget.stock["id"] ?? 0);
    });
  }

  calling() async {
    inventoryController?.purchaseList.clear();
    inventoryController?.purchaseList.add(InventoryController.addPurchase());
    await expenseController?.expensePaymentMethod(isShowAll: true);
    await inventoryController?.getWastageReasons();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.bgColor,
        appBar: CustomAppBar(
          titleText: widget.isEditStock == true
              ? widget.isAddPLusStock == true
                  ? AppString.addStocks
                  : AppString.editStocks
              : AppString.addStocks,
          actions: [
            // uploadIconWidget(
            //   onDownLoadTap: () async {
            //     await inventoryController?.inventoryExportStock();
            //   },
            //   onUploadTap: () async {
            //     await inventoryController?.inventoryUploadStockExcel();
            //   },
            // ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: GetBuilder<InventoryController>(
                  builder: (controller) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MyCustomButton(
                          //   text: AppString.purchaseBulkImport,
                          //   onTap: () async {
                          //     await inventoryController
                          //         ?.inventoryUploadStockExcel();
                          //   },
                          // )
                          //     .paddingSymmetric(horizontal: 16)
                          //     .paddingOnly(top: 20),
                          2.height,
                          Container(
                            color: ColorTheme.whiteColor,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.isSubRecipeStock != true) ...[
                                    Row(
                                      children: [
                                        CustomAutoCompleteWidget(
                                          fillColor: widget.isEditStock == true
                                              ? ColorTheme.whiteF0F0F0
                                              : ColorTheme.whiteColor,
                                          filled: widget.isEditStock == true
                                              ? true
                                              : false,
                                          isEnabled:
                                              (widget.isEditStock == true)
                                                  ? false
                                                  : true,
                                          onSelected: (selection) {
                                            inventoryController
                                                ?.addStockVendorController
                                                .text = selection;

                                            final selectedAddon =
                                                inventoryController
                                                    ?.getVendorList
                                                    .firstWhere(
                                              (vendor) =>
                                                  vendor["vendor_name"]
                                                      .toString()
                                                      .toLowerCase() ==
                                                  selection.toLowerCase(),
                                            );
                                            final selectedId =
                                                selectedAddon!["id"];
                                            inventoryController
                                                ?.addStockVendorId = selectedId;
                                            log('selectedId :$selectedId');
                                          },
                                          appToastMessage:
                                              AppString.noVendorAvailable,
                                          customTextEditingController:
                                              controller
                                                  .addStockVendorController,
                                          hintText: AppString.vendor,
                                          list: controller.getVendorList
                                              .map(
                                                (e) => e["vendor_name"],
                                              )
                                              .toList(),
                                        ),
                                        20.width,
                                        GestureDetector(
                                          onTap: () {
                                            vendorForm(context,
                                                inventoryController:
                                                    inventoryController!,
                                                isEdit: false,
                                                vendorData: {});
                                          },
                                          child: Icon(Icons.add_circle_outline,
                                              size: 34,
                                              color: ColorTheme.grey8C),
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                border: Border.all(
                                                    color:
                                                        ColorTheme.transparent),
                                              ),
                                              child: CustomTextformField(
                                                fillColor:
                                                    widget.isEditStock == true
                                                        ? ColorTheme.whiteF0F0F0
                                                        : ColorTheme.whiteColor,
                                                suffixIcon: Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    size: 15,
                                                    color: ColorTheme.grey8C),
                                                labelText:
                                                    AppString.purchaseDate,
                                                readOnly: true,
                                                controller: inventoryController!
                                                    .addStockPurchaseDateController,
                                                onTap:
                                                    widget.isEditStock == true
                                                        ? null
                                                        : () async {
                                                            inventoryController!
                                                                .picPurchaseDate();
                                                          },
                                              )),
                                        ),
                                        20.width,
                                        GetBuilder<ExpenseManagementController>(
                                          builder: (controller) =>
                                              CustomDropdownWidget(
                                            labelText: 'Payment Type',
                                            color: widget.isEditStock == true
                                                // ? ColorTheme.whiteF0F0F0
                                                ? ColorTheme.transparent
                                                : ColorTheme.transparent,
                                            items: expenseController
                                                ?.getPaymentList
                                                .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                    // fontFamily: AppFonts.montserrat,
                                                    fontSize: 12,
                                                    color: ColorTheme.foodValue,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            hintText: AppString.paymentType,
                                            onChanged:
                                                widget.isEditStock == true
                                                    ? null
                                                    : (String? newValue) {
                                                        inventoryController
                                                                ?.paymentTypeValue =
                                                            newValue;
                                                        inventoryController
                                                            ?.update();
                                                      },
                                            value: inventoryController
                                                ?.paymentTypeValue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextformField(
                                            fillColor:
                                                widget.isEditStock == true
                                                    ? ColorTheme.whiteF0F0F0
                                                    : ColorTheme.whiteColor,
                                            readOnly: widget.isEditStock == true
                                                ? true
                                                : false,
                                            onChanged:
                                                widget.isEditStock == true
                                                    ? null
                                                    : (p0) {
                                                        inventoryController
                                                            ?.totalAmount();
                                                      },
                                            keyboardType: TextInputType.number,
                                            controller: inventoryController
                                                ?.addStockTotalTaxController,
                                            labelText: AppString.totalTax,
                                          ),
                                        ),
                                        20.width,
                                        Expanded(
                                          child: CustomTextformField(
                                            fillColor:
                                                widget.isEditStock == true
                                                    ? ColorTheme.whiteF0F0F0
                                                    : ColorTheme.whiteColor,
                                            readOnly: widget.isEditStock == true
                                                ? true
                                                : false,
                                            onChanged: (p0) {
                                              inventoryController
                                                  ?.totalAmount();
                                            },
                                            keyboardType: TextInputType.number,
                                            controller: inventoryController
                                                ?.addStockTotalFairController,
                                            labelText: AppString.totalFair,
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextformField(
                                            fillColor:
                                                widget.isEditStock == true
                                                    ? ColorTheme.whiteF0F0F0
                                                    : ColorTheme.whiteColor,
                                            keyboardType: TextInputType.number,
                                            controller: inventoryController
                                                ?.addStockItemQuantityController,
                                            labelText: AppString.itemQuantity,
                                          ),
                                        ),
                                        20.width,
                                        Expanded(
                                          child: CustomTextformField(
                                            fillColor:
                                                widget.isEditStock == true
                                                    ? ColorTheme.whiteF0F0F0
                                                    : ColorTheme.whiteColor,
                                            readOnly: true,
                                            keyboardType: TextInputType.number,
                                            controller: inventoryController
                                                ?.addStockTotalAmountController,
                                            labelText: AppString.totalAmount,
                                          ),
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: widget.isEditStock == true
                                            ? ColorTheme.whiteF0F0F0
                                            : ColorTheme.whiteColor,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: ColorTheme.whiteDC),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15.0),
                                              child: Text(
                                                inventoryController
                                                        ?.addStockBrowseFilePath
                                                        ?.split("/")
                                                        .last
                                                        .toString() ??
                                                    AppString.billPDFImage,
                                                style: AppStyle.stockListStyle
                                                    .copyWith(
                                                  fontSize: 15,
                                                  color: ColorTheme.foodValue,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 30,
                                            color: ColorTheme.whiteDC,
                                          ),
                                          GestureDetector(
                                            onTap: widget.isEditStock == true
                                                ? null
                                                : () => inventoryController
                                                    ?.pickPDF(),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15.0),
                                              child: Text(
                                                AppString.browse,
                                                style: AppStyle.stockListStyle
                                                    .copyWith(
                                                  fontSize: 15,
                                                  color: ColorTheme.foodValue,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    20.height,
                                    Divider(
                                        color: ColorTheme.whiteE4,
                                        thickness: 1),
                                    10.height,
                                  ],
                                  Text(
                                    AppString.purchaseItem,
                                    style: TextStyle(color: ColorTheme.grey74),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: inventoryController
                                        ?.purchaseList.length,
                                    itemBuilder: (context, index) {
                                      final purchase = inventoryController
                                          ?.purchaseList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                CustomAutoCompleteWidget(
                                                  fillColor: (widget
                                                                  .isEditStock ==
                                                              true ||
                                                          widget.isAddPLusStock ==
                                                              true)
                                                      ? ColorTheme.whiteF0F0F0
                                                      : ColorTheme.whiteColor,
                                                  filled: (widget.isEditStock ==
                                                              true ||
                                                          widget.isAddPLusStock ==
                                                              true)
                                                      ? true
                                                      : false,
                                                  isEnabled:
                                                      (widget.isAddPLusStock ==
                                                                  true ||
                                                              widget.isEditStock ==
                                                                  true)
                                                          ? false
                                                          : true,
                                                  customTextEditingController:
                                                      purchase?[
                                                          "ingredientsController"],
                                                  onSelected: (selection) {
                                                    purchase?[
                                                            "ingredientsController"]
                                                        .text = selection;

                                                    final selectedAddon =
                                                        inventoryController
                                                            ?.inventoryIngredientsList
                                                            .firstWhere(
                                                      (inventory) =>
                                                          inventory[
                                                                  "stock_title"]
                                                              .toString()
                                                              .toLowerCase() ==
                                                          selection
                                                              .toLowerCase(),
                                                    );
                                                    final selectedId =
                                                        selectedAddon?["id"];
                                                    inventoryController
                                                        ?.getUnitInventory(
                                                            selectedId ?? 0);

                                                    purchase?["ingredientsId"] =
                                                        selectedId;

                                                    purchase?["currentStock"]
                                                            .text =
                                                        removeEndPoint00(
                                                            selectedAddon![
                                                                    "quantity"]
                                                                .toString());

                                                    purchase?["unit"] =
                                                        selectedAddon?[
                                                                "display_unit"]
                                                            .toString();
                                                    inventoryController
                                                        ?.update();
                                                  },
                                                  appToastMessage: AppString
                                                      .noIngredientsAvailable,
                                                  hintText:
                                                      AppString.ingredients,
                                                  list: controller
                                                      .inventoryIngredientsList
                                                      .map(
                                                        (e) => e["stock_title"],
                                                      )
                                                      .toList(),
                                                ),
                                                20.width,
                                                widget.isAddPLusStock == true
                                                    ? SizedBox()
                                                    : GestureDetector(
                                                        onTap: () {
                                                          Get.to(() =>
                                                              AddIngredientsScreen());
                                                        },
                                                        child: Icon(
                                                            Icons
                                                                .add_circle_outline,
                                                            size: 34,
                                                            color: ColorTheme
                                                                .grey8C),
                                                      ),
                                              ],
                                            ),
                                            20.height,
                                            Row(
                                              children: [
                                                GetBuilder<InventoryController>(
                                                  builder: (controller) {
                                                    List<
                                                            DropdownMenuItem<
                                                                String>>
                                                        dropdownItems;

                                                    if (widget.isAddPLusStock ==
                                                            true ||
                                                        widget.isAddMultipleStock ==
                                                            true) {
                                                      dropdownItems = inventoryController!
                                                          .getUnitInventoryList
                                                          .toSet()
                                                          .map<
                                                                  DropdownMenuItem<
                                                                      String>>(
                                                              (dynamic value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "Montserrat",
                                                              // fontFamily: AppFonts
                                                              //     .montserrat,
                                                              fontSize: 12,
                                                              color: ColorTheme
                                                                  .foodValue,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        );
                                                      }).toList();
                                                    } else {
                                                      dropdownItems =
                                                          inventoryController!
                                                              .unitList
                                                              .toSet()
                                                              .map<
                                                                  DropdownMenuItem<
                                                                      String>>((String
                                                                  value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "Montserrat",
                                                              // fontFamily: AppFonts
                                                              //     .montserrat,
                                                              fontSize: 12,
                                                              color: ColorTheme
                                                                  .foodValue,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        );
                                                      }).toList();
                                                    }

                                                    final selectedValue =
                                                        purchase?["unit"];
                                                    final matchingItems =
                                                        dropdownItems
                                                            .where((DropdownMenuItem<
                                                                        String>
                                                                    item) =>
                                                                item.value ==
                                                                selectedValue)
                                                            .toList();
                                                    log("matchingItems :$matchingItems");

                                                    if (matchingItems.length >
                                                        1) {}

                                                    return CustomDropdownWidget(
                                                      items: dropdownItems,
                                                      hintText: AppString.unit,
                                                      onChanged:
                                                          (String? newValue) {
                                                        purchase?["unit"] =
                                                            newValue;
                                                        inventoryController
                                                            ?.update();
                                                      },
                                                      value: (selectedValue !=
                                                                  null &&
                                                              matchingItems
                                                                  .isNotEmpty)
                                                          ? selectedValue
                                                          : null,
                                                    );
                                                  },
                                                ),
                                                20.width,
                                                Expanded(
                                                  child: CustomTextformField(
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d*\.?\d*')),
                                                    ],
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                    readOnly:
                                                        widget.isEditStock ==
                                                                true
                                                            ? true
                                                            : false,
                                                    fillColor: widget
                                                                .isEditStock ==
                                                            true
                                                        ? ColorTheme.whiteF0F0F0
                                                        : ColorTheme.whiteColor,
                                                    controller:
                                                        purchase!["quantity"],
                                                    labelText: 'New Quantity',
                                                    // AppString.quantity,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            widget.isSubRecipeStock == false
                                                ? 20.height
                                                : SizedBox.shrink(),
                                            widget.isSubRecipeStock == false
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            CustomTextformField(
                                                          readOnly:
                                                              (widget.isEditStock ==
                                                                      true)
                                                                  ? true
                                                                  : false,
                                                          fillColor: (widget
                                                                      .isEditStock ==
                                                                  true)
                                                              ? ColorTheme
                                                                  .whiteF0F0F0
                                                              : ColorTheme
                                                                  .whiteColor,
                                                          onChanged: (value) {
                                                            inventoryController
                                                                ?.totalAmount();
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller: purchase[
                                                              "amount"],
                                                          labelText:
                                                              AppString.amount,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            4,
                                                      ),
                                                      IconButton(
                                                          onPressed: () {
                                                            if (widget.isEditStock ==
                                                                    true ||
                                                                widget.isAddPLusStock ==
                                                                    true) {
                                                              inventoryController
                                                                      ?.showMoreInfoPanel =
                                                                  false;
                                                            } else if (inventoryController
                                                                    ?.showMoreInfoPanel ==
                                                                true) {
                                                              inventoryController
                                                                      ?.showMoreInfoPanel =
                                                                  false;
                                                              inventoryController
                                                                  ?.update();
                                                            } else {
                                                              inventoryController
                                                                      ?.showMoreInfoPanel =
                                                                  true;
                                                              inventoryController
                                                                  ?.update();
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .arrow_drop_down_circle_outlined,
                                                            color: (widget
                                                                            .isEditStock ==
                                                                        true ||
                                                                    widget
                                                                            .isAddPLusStock ==
                                                                        true)
                                                                ? ColorTheme
                                                                    .whiteF0F0F0
                                                                : Colors.black,
                                                          ))
                                                    ],
                                                  )
                                                : SizedBox.shrink(),
                                            // Threshold fields - only visible in edit mode
                                            widget.isEditStock == true
                                                ? 20.height
                                                : SizedBox.shrink(),
                                            widget.isEditStock == true
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            CustomTextformField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              inventoryController
                                                                  ?.thresholdQtyController,
                                                          labelText:
                                                              'Threshold Qty',
                                                        ),
                                                      ),
                                                      20.width,
                                                      Expanded(
                                                        child: GetBuilder<
                                                            InventoryController>(
                                                          builder:
                                                              (controller) {
                                                            return DropdownButtonFormField2<
                                                                String>(
                                                              value: controller
                                                                  .thresholdUnitValue,
                                                              items: controller
                                                                  .threSholdUnitList
                                                                  .map((item) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: item,
                                                                  child: Text(
                                                                    item,
                                                                    style: montserratMedium
                                                                        .copyWith(
                                                                      color: Color(
                                                                          0xFF828282),
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              onChanged: (String?
                                                                  newValue) {
                                                                controller
                                                                        .thresholdUnitValue =
                                                                    newValue;
                                                                controller
                                                                    .update();
                                                              },
                                                              buttonStyleData:
                                                                  ButtonStyleData(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            0),
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                ),
                                                                overlayColor:
                                                                    WidgetStateProperty
                                                                        .all(Colors
                                                                            .transparent),
                                                              ),
                                                              dropdownStyleData:
                                                                  DropdownStyleData(
                                                                maxHeight: 400,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              14),
                                                                  border: Border
                                                                      .all(
                                                                    color: Color(
                                                                        0xFFDCDCDC),
                                                                  ),
                                                                ),
                                                              ),
                                                              menuItemStyleData:
                                                                  MenuItemStyleData(
                                                                height: 45,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Threshold Unit',
                                                                labelStyle:
                                                                    montserratMedium
                                                                        .copyWith(
                                                                  color:
                                                                      ColorTheme
                                                                          .black,
                                                                  fontSize: 15,
                                                                ),
                                                                hintText:
                                                                    'Select Unit',
                                                                hintStyle:
                                                                    montserratRegular
                                                                        .copyWith(
                                                                  color:
                                                                      ColorTheme
                                                                          .grey1,
                                                                  fontSize: 14,
                                                                ),
                                                                floatingLabelBehavior:
                                                                    FloatingLabelBehavior
                                                                        .auto,
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            16),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              30)),
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Color(0xFFDCDCDC)),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              30)),
                                                                  borderSide: BorderSide(
                                                                      color: Color(
                                                                          0xFFDCDCDC),
                                                                      width:
                                                                          1.5),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              30)),
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Color(0xFFDCDCDC)),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              30)),
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Color(0xFFDCDCDC)),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox.shrink(),
                                            20.height,
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextformField(
                                                    readOnly:
                                                        widget.isAddPLusStock ==
                                                                true
                                                            ? true
                                                            : false,
                                                    fillColor:
                                                        widget.isAddPLusStock ==
                                                                true
                                                            ? ColorTheme
                                                                .whiteF0F0F0
                                                            : ColorTheme
                                                                .whiteColor,
                                                    controller: purchase[
                                                        "currentStock"],
                                                    labelText: 'Old Quantity',
                                                    // AppString.currentStock,
                                                  ),
                                                ),
                                                if (Get.find<AuthController>()
                                                    .profileModel!
                                                    .role!
                                                    .contains(
                                                        'physicalqty_master')) ...[
                                                  20.width,
                                                  Expanded(
                                                    child: CustomTextformField(
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'^\d*\.?\d*')),
                                                        ],
                                                        keyboardType: TextInputType
                                                            .numberWithOptions(
                                                                decimal: true),
                                                        readOnly: (widget
                                                                    .isEditStock ==
                                                                true)
                                                            ? true
                                                            : false,
                                                        fillColor:
                                                            (widget.isEditStock ==
                                                                    true)
                                                                ? ColorTheme
                                                                    .whiteF0F0F0
                                                                : ColorTheme
                                                                    .whiteColor,
                                                        controller: purchase[
                                                            "physicalQty"],
                                                        labelText:
                                                            'Physical Qty in kitchen'
                                                        // AppString.physicalQty
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            10.height,

                                            // // Wastage Reason Dropdown - Always visible
                                            // if (widget.isAddPLusStock ==
                                            //         true ||
                                            //     widget.isAddMultipleStock ==
                                            //         true ||
                                            //     widget.isSubRecipeStock ==
                                            //         true ||
                                            //     widget.isEditStock ==
                                            //         true) // Show in all modes
                                            if (Get.find<AuthController>()
                                                .profileModel!
                                                .role!
                                                .contains(
                                                    'physicalqty_master')) ...[
                                              GetBuilder<InventoryController>(
                                                builder: (controller) {
                                                  // Parse quantities for comparison
                                                  final oldQty =
                                                      double.tryParse(purchase[
                                                                  "currentStock"]
                                                              .text) ??
                                                          0;
                                                  final physicalQty =
                                                      double.tryParse(purchase[
                                                                  "physicalQty"]
                                                              .text) ??
                                                          0;

                                                  // Check if dropdown should be mandatory (only when physicalQty < oldQty)
                                                  final isMandatory =
                                                      (physicalQty < oldQty &&
                                                          physicalQty > 0);
                                                  final isReadOnly =
                                                      widget.isEditStock ==
                                                          true;

                                                  return IgnorePointer(
                                                    ignoring:
                                                        isReadOnly, // Disable interaction in edit mode
                                                    child: Opacity(
                                                      opacity: isReadOnly
                                                          ? 0.6
                                                          : 1.0, // Visual feedback for readonly
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton2<
                                                            int>(
                                                          isExpanded: true,
                                                          style: montserratMedium
                                                              .copyWith(
                                                                  color:
                                                                      ColorTheme
                                                                          .grey8C,
                                                                  fontSize: 12,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                          hint: Text(
                                                              'Select Wastage Reason',
                                                              style: montserratMedium.copyWith(
                                                                  color:
                                                                      ColorTheme
                                                                          .grey8C,
                                                                  fontSize: 12,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis)),
                                                          items: controller
                                                              .wastageReasonsList
                                                              .map((Map<String,
                                                                      dynamic>
                                                                  reason) {
                                                            return DropdownMenuItem<
                                                                int>(
                                                              value:
                                                                  reason['id']
                                                                      as int,
                                                              child: Text(
                                                                  reason['reason']
                                                                      as String,
                                                                  style: montserratMedium.copyWith(
                                                                      color: ColorTheme
                                                                          .grey8C,
                                                                      fontSize:
                                                                          12,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis)),
                                                            );
                                                          }).toList(),
                                                          value: controller
                                                              .selectedWastageReasonId
                                                              .value,
                                                          onChanged: isReadOnly
                                                              ? null
                                                              : (int?
                                                                  newValue) {
                                                                  controller
                                                                      .setWastageReason(
                                                                          newValue);
                                                                },
                                                          buttonStyleData:
                                                              ButtonStyleData(
                                                            height: 50,
                                                            // width: double
                                                            //     .infinity,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 0,
                                                                    right: 14),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40),
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0xFFDCDCDC), // light grey border
                                                                width: 1,
                                                              ),
                                                              color: isReadOnly
                                                                  ? ColorTheme
                                                                      .whiteF0F0F0 // Same as readonly fields
                                                                  : Colors
                                                                      .white,
                                                            ),
                                                          ),
                                                          dropdownStyleData:
                                                              DropdownStyleData(
                                                            maxHeight: 200,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                          menuItemStyleData:
                                                              const MenuItemStyleData(
                                                            height: 40,
                                                          ),
                                                          // decoration:
                                                          //     InputDecoration(
                                                          //   labelText: 'Wastage Reason',
                                                          //   labelStyle: montserratMedium
                                                          //       .copyWith(
                                                          //           color:
                                                          //               ColorTheme
                                                          //                   .black,
                                                          //           fontSize: 17,
                                                          //           overflow:
                                                          //               TextOverflow
                                                          //                   .ellipsis),
                                                          //   floatingLabelBehavior:
                                                          //       FloatingLabelBehavior
                                                          //           .auto,
                                                          //   contentPadding:
                                                          //       EdgeInsets
                                                          //           .symmetric(
                                                          //               horizontal:
                                                          //                   0,
                                                          //               vertical:
                                                          //                   16),
                                                          //   border: OutlineInputBorder(
                                                          //       borderRadius: BorderRadius
                                                          //           .all(Radius
                                                          //               .circular(
                                                          //                   30)),
                                                          //       borderSide: BorderSide(
                                                          //           color: Color(
                                                          //               0xFFDCDCDC))),
                                                          //   focusedBorder: OutlineInputBorder(
                                                          //       borderRadius: BorderRadius
                                                          //           .all(Radius
                                                          //               .circular(
                                                          //                   30)),
                                                          //       borderSide: BorderSide(
                                                          //           color: Color(
                                                          //               0xFFDCDCDC))),
                                                          //   errorBorder: OutlineInputBorder(
                                                          //       borderRadius: BorderRadius
                                                          //           .all(Radius
                                                          //               .circular(
                                                          //                   30)),
                                                          //       borderSide: BorderSide(
                                                          //           color: Color(
                                                          //               0xFFDCDCDC))),
                                                          //   enabledBorder: OutlineInputBorder(
                                                          //       borderRadius: BorderRadius
                                                          //           .all(Radius
                                                          //               .circular(
                                                          //                   30)),
                                                          //       borderSide: BorderSide(
                                                          //           color: Color(
                                                          //               0xFFDCDCDC))),
                                                          // ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                            20.height,
                                            Visibility(
                                              visible: inventoryController
                                                      ?.showMoreInfoPanel ??
                                                  false,
                                              child: Column(
                                                children: [
                                                  20.height,
                                                  Divider(
                                                      color: ColorTheme.whiteE4,
                                                      thickness: 1),
                                                  15.height,
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: CustomTextformField(
                                                            readOnly: false,
                                                            fillColor:
                                                                ColorTheme
                                                                    .whiteColor,
                                                            controller:
                                                                inventoryController
                                                                    ?.batchController,
                                                            labelText: 'Batch'),
                                                      ),
                                                      20.width,
                                                      Expanded(
                                                        child: CustomTextformField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .name,
                                                            readOnly: false,
                                                            fillColor:
                                                                ColorTheme
                                                                    .whiteColor,
                                                            controller:
                                                                inventoryController
                                                                    ?.brandController,
                                                            labelText: 'Brand'),
                                                      ),
                                                    ],
                                                  ),
                                                  20.height,
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: CustomTextformField(
                                                            readOnly: false,
                                                            fillColor:
                                                                ColorTheme
                                                                    .whiteColor,
                                                            controller:
                                                                inventoryController
                                                                    ?.consumptionUnitController,
                                                            labelText:
                                                                'Consumption Unit'),
                                                      ),
                                                      20.width,
                                                      Expanded(
                                                        child: CustomTextformField(
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      r'^\d*\.?\d*')),
                                                            ],
                                                            keyboardType:
                                                                TextInputType
                                                                    .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                            readOnly: false,
                                                            fillColor:
                                                                ColorTheme
                                                                    .whiteColor,
                                                            controller:
                                                                inventoryController
                                                                    ?.conversionFactorController,
                                                            labelText:
                                                                'Conversion Factor'),
                                                      ),
                                                    ],
                                                  ),
                                                  20.height,
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: CustomTextformField(
                                                            readOnly: false,
                                                            fillColor:
                                                                ColorTheme
                                                                    .whiteColor,
                                                            controller:
                                                                inventoryController
                                                                    ?.expiryController,
                                                            labelText:
                                                                'Expiry'),
                                                      ),
                                                      20.width,
                                                      Expanded(
                                                        child: CustomTextformField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .name,
                                                            readOnly: false,
                                                            fillColor:
                                                                ColorTheme
                                                                    .whiteColor,
                                                            controller:
                                                                inventoryController
                                                                    ?.expiryDateController,
                                                            labelText:
                                                                'Expiry Date'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            widget.isEditStock == false
                                                ? widget.isAddPLusStock == true
                                                    ? SizedBox()
                                                    : Column(
                                                        children: [
                                                          15.height,
                                                          Divider(
                                                              color: ColorTheme
                                                                  .whiteE4,
                                                              thickness: 1),
                                                          GestureDetector(
                                                            onTap: () {
                                                              inventoryController
                                                                  ?.removePurchaseData(
                                                                      index);
                                                            },
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: SvgPicture
                                                                  .asset(
                                                                Images
                                                                    .deleteIcon,
                                                                height: 20,
                                                                color:
                                                                    ColorTheme
                                                                        .red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                : SizedBox()
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  (widget.isEditStock == false)
                                      ? widget.isAddPLusStock == true
                                          ? SizedBox()
                                          : GestureDetector(
                                              onTap: () => inventoryController
                                                  ?.addPurchaseData(),
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      Images.add_icon,
                                                      color: ColorTheme.grey,
                                                      height: 18),
                                                  8.width,
                                                  Text(AppString.addItem,
                                                      style: TextStyle(
                                                          color: ColorTheme
                                                              .greenColor,
                                                          fontSize: 13)),
                                                ],
                                              ).paddingOnly(
                                                  bottom: 20, top: 20),
                                            )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  GetBuilder<InventoryController>(
                    builder: (controller) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.clearStockData();
                          setState(() {});
                        },
                        child: Container(
                          height: 50,
                          color: ColorTheme.greyColor.withOpacity(0.2),
                          alignment: Alignment.center,
                          child: Text(AppString.Reset),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Expanded(
                      child: GestureDetector(
                        onTap: inventoryController!
                                .isAddInventorySubmitting.value
                            ? null
                            : () async {
                                // Validation only for non-edit modes
                                if ((widget.isSubRecipeStock == true ||
                                        widget.isAddPLusStock == true ||
                                        widget.isAddMultipleStock == true) &&
                                    widget.isEditStock != true) {
                                  // Check if wastage reason is needed
                                  for (var purchase
                                      in inventoryController!.purchaseList) {
                                    final oldQty = double.tryParse(
                                            purchase["currentStock"].text) ??
                                        0;
                                    final physicalQty = double.tryParse(
                                            purchase["physicalQty"].text) ??
                                        0;

                                    // Only validate when physicalQty < oldQty
                                    if (physicalQty < oldQty &&
                                        physicalQty > 0) {
                                      if (inventoryController!
                                              .selectedWastageReasonId.value ==
                                          null) {
                                        showCustomSnackBar(
                                          'Please select a wastage reason when physical quantity is less than old quantity',
                                          isError: true,
                                        );
                                        return;
                                      }
                                    }
                                  }
                                }
                                if ((widget.isSubRecipeStock != true ||
                                        widget.isAddPLusStock == true ||
                                        widget.isAddMultipleStock == true) &&
                                    widget.isEditStock != true) {
                                  if ((inventoryController
                                              ?.addStockTotalAmountController
                                              .text
                                              .isNotEmpty ??
                                          false) &&
                                      (inventoryController?.paymentTypeValue ==
                                              null ||
                                          inventoryController
                                                  ?.paymentTypeValue ==
                                              '')) {
                                    Get.snackbar(
                                      'Select',
                                      'Please select the payment type',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                }
                                if (widget.isSubRecipeStock == true &&
                                    widget.isAddPLusStock == true) {
                                  await inventoryController
                                      ?.addSubRecipeStock();
                                } else if (widget.isAddPLusStock == true) {
                                  await inventoryController
                                      ?.addSingleStock(widget.stock["id"]);
                                } else if (widget.isEditStock == true) {
                                  await inventoryController
                                      ?.updateStock(widget.stock["id"]);
                                } else {
                                  await inventoryController
                                      ?.addInventoryStock();
                                }
                              },
                        child: Container(
                          height: 50,
                          color: ColorTheme.greenColor,
                          alignment: Alignment.center,
                          child:
                              inventoryController!.addInventoryStockLoader.value
                                  ? AppLoader()
                                  : Text(AppString.submit,
                                      style: TextStyle(
                                          color: ColorTheme.whiteColor,
                                          fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
