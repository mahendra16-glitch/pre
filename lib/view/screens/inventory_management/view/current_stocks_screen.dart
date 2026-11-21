import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_inventory.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/manage_vendor.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_bulk_import.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'add_stock_screen.dart';

class CurrentStocksScreen extends StatefulWidget {
  const CurrentStocksScreen({Key? key}) : super(key: key);

  @override
  State<CurrentStocksScreen> createState() => _CurrentStocksScreenState();
}

class _CurrentStocksScreenState extends State<CurrentStocksScreen> {
  InventoryController? inventoryController;
  ExpenseManagementController? expenseController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    inventoryController = Get.find<InventoryController>();
    expenseController = Get.find<ExpenseManagementController>();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        callStockInventory();
      },
    );

    super.initState();
  }

  callStockInventory() async {
    inventoryController?.searchController.clear();
    inventoryController?.stockFilter = 'All';
    inventoryController?.categoryFilter = null;
    await inventoryController?.getCurrentStock();
    await inventoryController?.getStockCategoryList();
    await inventoryController?.getVendor();
    await inventoryController?.getInventoryIngredients();
    await inventoryController?.getVendorType();
    await expenseController?.expensePaymentMethod(isShowAll: true);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          leadingValue: true,
          // leadingWidget: Padding(
          //   padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
          //   child: IconButton(
          //     icon: Image.asset(Images.menu,
          //         color: ColorTheme.appColor, height: 16),
          //     onPressed: () {
          //       scaffoldKey.currentState?.openDrawer();
          //     },
          //   ),
          // ),
          leadingWidget: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: ColorTheme.appColor,
              )),
          titleText: AppString.currentStocks,
          actions: [
            uploadIconWidget(
              onDownLoadTap: () async {
                // await inventoryController?.inventoryExportStock();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Current Stocks',
                      controller: Get.find<InventoryController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        inventoryController?.exportStockSample();
                      },
                      onDownloadExistingDataTap: () {
                        inventoryController?.inventoryExportStock();
                      },
                      onuploadTap: () {
                        inventoryController?.inventoryUploadStockExcel();
                      },
                    ));
              },
              onUploadTap: () async {
                // await inventoryController?.inventoryUploadStockExcel();
                Get.to(() => BulkImportScreen(
                      tittleName: 'Current Stocks',
                      controller: Get.find<InventoryController>(),
                      isFunction: true,
                      onDownloadSampleDataTap: () {
                        inventoryController?.exportStockSample();
                      },
                      onDownloadExistingDataTap: () {
                        inventoryController?.inventoryExportStock();
                      },
                      onuploadTap: () {
                        inventoryController?.inventoryUploadStockExcel();
                      },
                    ));
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: InkWell(
                onTap: () {
                  Get.to(() => AddStockScreen(
                        stock: {},
                        isAddPLusStock: false,
                        isEditStock: false,
                        isAddMultipleStock: true,
                      ));
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: SvgPicture.asset(
                  Images.add_icon,
                  color: Colors.deepOrangeAccent,
                  width: 28.7,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      onChanged: (value) {
                        inventoryController?.update();
                      },
                      showCursor: true,
                      controller: inventoryController?.searchController,
                      cursorColor: ColorTheme.greyBE,
                      cursorHeight: 15.0,
                      cursorRadius: Radius.circular(10),
                      cursorWidth: 2.0,
                      decoration: InputDecoration(
                        fillColor: ColorTheme.whiteColor,
                        filled: true,
                        hintText: AppString.search,
                        prefixIcon:
                            Icon(Icons.search, color: ColorTheme.greyBE),
                        hintStyle: AppStyle.searchTextStyle,
                        border: AppBorder.menuSearchBorder.copyWith(
                            borderSide: BorderSide(
                                width: 2, color: ColorTheme.transparent)),
                        enabledBorder: AppBorder.menuSearchBorder.copyWith(
                            borderSide: BorderSide(
                                width: 2, color: ColorTheme.transparent)),
                        focusedBorder: AppBorder.menuSearchBorder.copyWith(
                            borderSide:
                                BorderSide(color: ColorTheme.transparent)),
                      ),
                      style: AppStyle.searchTextStyle,
                    ),
                  ),
                  10.width,

                  // Category Filter Dropdown
                  GetBuilder<InventoryController>(
                    builder: (controller) => Expanded(
                      flex: 2,
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        style: montserratMedium.copyWith(
                            overflow: TextOverflow.ellipsis,
                            color: ColorTheme.grey8C,
                            fontSize: 12),
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: ColorTheme.greyCACACA.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: ColorTheme.greyCACACA.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: ColorTheme.greyCACACA.withOpacity(0.3)),
                          ),
                        ),
                        value: inventoryController?.categoryFilter ??
                            'All Categories',
                        items: [
                          'All Categories',
                          if (inventoryController?.categoryStockList != null)
                            ...inventoryController!.categoryStockList
                                .map((category) =>
                                    category['category_name']?.toString() ?? '')
                                .where((name) => name.isNotEmpty)
                                .toList()
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: montserratMedium.copyWith(
                                  color: ColorTheme.grey8C, fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            inventoryController?.setCategoryFilter(
                                newValue == 'All Categories' ? null : newValue);
                          } else {
                            inventoryController?.setCategoryFilter(null);
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorTheme.whiteColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.category),
                          iconSize: 20,
                          iconEnabledColor: ColorTheme.greyCACACA,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          width: 150,
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColorTheme.greyCACACA.withOpacity(0.3),
                            ),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                  10.width,

                  // Filter Dropdown
                  GetBuilder<InventoryController>(
                    builder: (controller) => Expanded(
                      flex: 2,
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        style: montserratMedium.copyWith(
                            overflow: TextOverflow.ellipsis,
                            color: ColorTheme.grey8C,
                            fontSize: 12),
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: ColorTheme.greyCACACA.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: ColorTheme.greyCACACA.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: ColorTheme.greyCACACA.withOpacity(0.3)),
                          ),
                        ),
                        value: inventoryController?.stockFilter ?? 'All',
                        items: ['All', 'Low Stock'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: montserratMedium.copyWith(
                                  color: ColorTheme.grey8C, fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            inventoryController?.setStockFilter(newValue);
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorTheme.whiteColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(Icons.filter_list),
                          iconSize: 20,
                          iconEnabledColor: ColorTheme.greyCACACA,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          width: 120,
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ColorTheme.greyCACACA.withOpacity(0.3),
                            ),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                  ),

                  5.width,
                  // 15.width,
                  // GetBuilder<InventoryController>(
                  //   builder: (controller) => IconButton(
                  //       highlightColor: ColorTheme.transparent,
                  //       onPressed: () {
                  //         inventoryController?.setStockOrderFilter();
                  //       },
                  //       icon: Icon(
                  //         inventoryController!.stockQuantityOrderFilter
                  //             ? Icons.arrow_circle_up
                  //             : Icons.arrow_circle_down_outlined,
                  //         size: 35,
                  //         color: ColorTheme.greyCACACA,
                  //       )),
                  // ),
                  IconButton(
                      onPressed: () async {
                        await inventoryController?.getCurrentStock();
                        await inventoryController?.getStockCategoryList();
                        await inventoryController?.getVendor();
                        await inventoryController?.getInventoryIngredients();
                        await inventoryController?.getVendorType();
                        await expenseController?.expensePaymentMethod(
                            isShowAll: true);
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: ColorTheme.greyCACACA,
                        size: 38,
                      ))
                ],
              ),
            ),
            15.height,
            Container(
              height: 40,
              color: ColorTheme.whiteColor,
              child: Row(children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        15.width,
                        Text(AppString.ingredient,
                            style: AppStyle.tx18mediumRed),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: ColorTheme.whiteE7))),
                    child:
                        Text(AppString.quantity, style: AppStyle.tx18mediumRed),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                        // AppString.status,
                        'Delete',
                        style: AppStyle.tx18mediumRed),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            vertical: BorderSide(color: ColorTheme.whiteE7))),
                    child:
                        Text(AppString.action, style: AppStyle.tx18mediumRed),
                  ),
                ),
              ]),
            ),
            Expanded(child: GetBuilder<InventoryController>(
              builder: (controller) {
                // var filteredStockList =
                //     inventoryController?.stockList.where((element) {
                //   return element["stock_title"]
                //       .toString()
                //       .toLowerCase()
                //       .contains(inventoryController!.searchController.text
                //           .toLowerCase());
                // }).toList();

                var filteredStockList =
                    inventoryController?.stockList.where((element) {
                  bool matchesSearch = element["stock_title"]
                      .toString()
                      .toLowerCase()
                      .contains(inventoryController!.searchController.text
                          .toLowerCase());

                  bool matchesFilter = true;
                  if (inventoryController!.stockFilter == 'Low Stock') {
                    matchesFilter = element["is_low_stock"] == true;
                  }

                  bool matchesCategory = true;
                  if (inventoryController!.categoryFilter != null &&
                      inventoryController!.categoryFilter!.isNotEmpty) {
                    matchesCategory = element["category_name"]?.toString() ==
                        inventoryController!.categoryFilter;
                  }

                  return matchesSearch && matchesFilter && matchesCategory;
                }).toList();

                // Sorting logic
                if (inventoryController!.stockFilter == 'Low Stock') {
                  // Low Stock filter: Negative quantities first, then lowest to highest
                  filteredStockList!.sort((a, b) {
                    double aQty =
                        double.tryParse(a["quantity"].toString()) ?? 0;
                    double bQty =
                        double.tryParse(b["quantity"].toString()) ?? 0;

                    // If both are negative, most negative comes first
                    if (aQty < 0 && bQty < 0) {
                      return aQty.compareTo(bQty);
                    }
                    // If one is negative and other is positive, negative comes first
                    if (aQty < 0 && bQty >= 0) {
                      return -1;
                    }
                    if (aQty >= 0 && bQty < 0) {
                      return 1;
                    }
                    // Both are positive, lowest comes first
                    return aQty.compareTo(bQty);
                  });
                }
                // if (inventoryController!.stockQuantityOrderFilter) {
                //   filteredStockList!.sort((a, b) {
                //     double aQty =
                //         double.tryParse(a["display_qty"].toString()) ?? 0;
                //     double bQty =
                //         double.tryParse(b["display_qty"].toString()) ?? 0;
                //     return bQty.compareTo(aQty);
                //   });
                // } else {
                //   filteredStockList!.sort((a, b) {
                //     double aQty =
                //         double.tryParse(a["display_qty"].toString()) ?? 0;
                //     double bQty =
                //         double.tryParse(b["display_qty"].toString()) ?? 0;
                //     return aQty.compareTo(bQty);
                //   });
                // }

                return inventoryController!.isStockLoader
                    ? Center(
                        child: Center(
                            child: CircularProgressIndicator(
                        backgroundColor: ColorTheme.whiteColor,
                        color: ColorTheme.greenColor,
                      )))
                    : filteredStockList!.isNotEmpty
                        ? Container(
                            color: ColorTheme.whiteColor,
                            child: ListView.builder(
                              itemCount: filteredStockList.length ?? 0,
                              itemBuilder: (context, index) {
                                final stock = filteredStockList[index];
                                return IntrinsicHeight(
                                  child: Container(
                                    // height: 60,
                                    decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              color: ColorTheme.whiteE7)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Container(
                                                width: double.infinity,
                                                color: ColorTheme.transparent,
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 10,
                                                          right: 5,
                                                          bottom: 10),
                                                  child: Row(
                                                    children: [
                                                      stock['type'] ==
                                                              'SubRecipe'
                                                          ? Container(
                                                              width: 15,
                                                              height: 15,
                                                              decoration: BoxDecoration(
                                                                  color: ColorTheme
                                                                      .blackColor,
                                                                  shape: BoxShape
                                                                      .circle),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                "SR",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: ColorTheme
                                                                        .whiteColor,
                                                                    fontSize:
                                                                        8),
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          stock["stock_title"],
                                                          softWrap: true,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Montserrat",
                                                            // fontFamily:
                                                            //     AppFonts.montserrat,
                                                            fontSize: 13.7,
                                                            color: ColorTheme
                                                                .foodValue,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              height: double.infinity,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                border: Border.symmetric(
                                                  vertical: BorderSide(
                                                      color:
                                                          ColorTheme.whiteE7),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 0),
                                                    child: Builder(
                                                        builder: (context) {
                                                      String qty =
                                                          stock["quantity"];
                                                      String quantity;

                                                      if (qty
                                                          .endsWith(".000")) {
                                                        quantity =
                                                            qty.replaceAll(
                                                                RegExp(
                                                                    r"\.0+$"),
                                                                "");
                                                      } else {
                                                        quantity = qty;
                                                      }

                                                      return Center(
                                                        child: Text(
                                                          "$quantity ${stock["display_unit"]}",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Montserrat",
                                                            // fontFamily:
                                                            //     AppFonts.montserrat,
                                                            fontSize: 13,
                                                            color: ColorTheme
                                                                .foodValue,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  Builder(builder: (context) {
                                                    String unitValue =
                                                        stock["min_qty_alert"];
                                                    String unit;
                                                    if (unitValue
                                                        .endsWith(".00")) {
                                                      unit =
                                                          unitValue.replaceAll(
                                                              RegExp(r"\.0+$"),
                                                              "");
                                                    } else {
                                                      unit = unitValue;
                                                    }
                                                    return Center(
                                                      child: Text(
                                                        "Min ${unit} ${stock["min_unit_alert"]}",
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "Montserrat",
                                                          // fontFamily:
                                                          //     AppFonts.montserrat,
                                                          fontSize: 10.5,
                                                          color: ColorTheme
                                                              .foodValue,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                  // Low Stock Indicator
                                                  if (stock["is_low_stock"] ==
                                                      true)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Center(
                                                        child: Text(
                                                          "Low Stock",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ).paddingOnly(top: 7),
                                            ),
                                          ),
                                          //status
                                          // Expanded(
                                          //   flex: 2,
                                          //   child: Container(
                                          //     height: double.infinity,
                                          //     alignment: Alignment.center,
                                          //     child: Transform.scale(
                                          //       scale: 0.7,
                                          //       child: Switch(
                                          //         inactiveTrackColor: ColorTheme
                                          //             .switchITrackColor,
                                          //         inactiveThumbColor: ColorTheme
                                          //             .switchIThumbColor,
                                          //         value: stock['status'] == "1"
                                          //             ? true
                                          //             : false,
                                          //         onChanged: (value) {
                                          //           final data = {
                                          //             "status": value ? 1 : 0
                                          //           };
                                          //           inventoryController!
                                          //               .updateStockStatus(
                                          //                   stock["id"],
                                          //                   data: data);
                                          //         },
                                          //         activeColor: ColorTheme.green,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),

                                          //delete
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              height: double.infinity,
                                              alignment: Alignment.center,
                                              child: Transform.scale(
                                                scale: 0.7,
                                                child: Obx(() {
                                                  final isThisItemDeleting =
                                                      inventoryController!
                                                              .deletingIngredientId
                                                              .value ==
                                                          stock["id"];

                                                  if (isThisItemDeleting) {
                                                    return SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          ColorTheme.appColor,
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  return IconButton(
                                                    icon: Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                      size: 30,
                                                    ),
                                                    onPressed: inventoryController!
                                                            .isDeletingIngredient
                                                            .value
                                                        ? null
                                                        : () {
                                                            _showDeleteConfirmationBottomSheet(
                                                                context,
                                                                stock,
                                                                inventoryController!);
                                                          },
                                                  );
                                                }),
                                              ),
                                            ),
                                          ),

                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.symmetric(
                                                    vertical: BorderSide(
                                                        color: ColorTheme
                                                            .whiteE7)),
                                              ),
                                              height: double.infinity,
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to(
                                                          () => AddStockScreen(
                                                                stock: stock,
                                                                // isActionStock: false,
                                                                isAddPLusStock:
                                                                    true,
                                                                isSubRecipeStock:
                                                                    stock['type'] ==
                                                                            'SubRecipe'
                                                                        ? true
                                                                        : false,
                                                              ));
                                                    },
                                                    child: Container(
                                                      height: 20,
                                                      width: 20,
                                                      child: SvgPicture.asset(
                                                          Images.plusIcon,
                                                          width: 20.7),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      stock['type'] ==
                                                              'SubRecipe'
                                                          ? null
                                                          : Get.to(() =>
                                                              AddStockScreen(
                                                                stock: stock,
                                                                isEditStock:
                                                                    true,
                                                                isAddPLusStock:
                                                                    false,
                                                              ));
                                                    },
                                                    child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        child: Icon(
                                                          Icons.edit,
                                                          color: stock[
                                                                      'type'] ==
                                                                  'SubRecipe'
                                                              ? ColorTheme
                                                                  .greyCACACA
                                                              : ColorTheme
                                                                  .green,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(child: Text(AppString.noDataFound));
                ;
              },
            ))
          ],
        ),
      ),
    );
  }

  // Delete Confirmation Bottom Sheet
  void _showDeleteConfirmationBottomSheet(BuildContext context,
      Map<String, dynamic> stock, InventoryController controller) {
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
                'Delete Ingredient',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to delete ingredient "${stock['stock_title'] ?? 'N/A'}"?',
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
                        controller.deleteIngredient(stock['id']);
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
}
