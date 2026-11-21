import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_appbar.dart';
import 'package:mygenie_restaurant/admin/widget/keyboard_disable.dart';
import 'package:mygenie_restaurant/admin/widget/remove_string_point00.dart';
import 'package:mygenie_restaurant/admin/widget/search_field.dart';
import 'package:mygenie_restaurant/admin/widget/upload_icon/upload_icon.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mygenie_restaurant/util/styles.dart';

import '../controller/inventory_controller.dart';
import 'add_stock_screen.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  InventoryController? inventoryController;

  @override
  void initState() {
    inventoryController = Get.find<InventoryController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inventoryController?.purchaseSearchController.clear();
      callPurchaseApis();
    });
    super.initState();
  }

  callPurchaseApis() async {
    inventoryController?.purchaseReportFilterValue = "All Time";
    inventoryController?.purchaseFromDate = null;
    inventoryController?.purchaseToDate = null;
    inventoryController?.totalPurchaseAmount = '0';
    await inventoryController?.getPurchaseReport(
        purchaseFromDate: inventoryController?.purchaseFromDate ?? "",
        purchaseToDate: inventoryController?.purchaseToDate ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDisable(
      child: Scaffold(
        backgroundColor: ColorTheme.grey200Color,
        appBar: CustomAppBar(
          titleText: AppString.purchaseReport,
          actions: [
            GetBuilder<InventoryController>(
              builder: (controller) => Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: ColorTheme.appColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'Total: ${controller.totalPurchaseAmount ?? '0'}',
                    style: poppinsMedium.copyWith(
                      fontSize: 14,
                      color: ColorTheme.white,
                    ),
                  )),
            ),
            5.width,
            uploadIconWidget(
                isPLusShow: false,
                onDownLoadTap: () async {
                  await inventoryController?.purchaseExportPurchaseReport();
                },
                onPlusTap: () {
                  Get.to(() =>
                      AddStockScreen(stock: {}, isAddMultipleStock: true));
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                isUpNotShow: false),
          ],
        ),
        body: GetBuilder<InventoryController>(
          builder: (controller) => Column(
            children: [
              Divider(color: ColorTheme.grey8C.withOpacity(.4), height: 1),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                                width: double.infinity,
                                child: DropdownButton<String>(
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: ColorTheme.whiteColor,
                                  isExpanded: true,
                                  icon: Icon(Icons.keyboard_arrow_down_outlined,
                                      size: 15, color: ColorTheme.grey8C),
                                  value: inventoryController!
                                          .purchaseReportFilterValue.isEmpty
                                      ? null
                                      : inventoryController!
                                          .purchaseReportFilterValue,
                                  underline: SizedBox.shrink(),
                                  onChanged: (newValue) async {
                                    inventoryController!
                                        .onChangePurchaseFilter(newValue ?? "");
                                  },
                                  items: [
                                    ...inventoryController!
                                        .purchaseReportFilterList
                                        .map<DropdownMenuItem<String>>(
                                      (value) {
                                        String purchaseValue = value.toString();
                                        return DropdownMenuItem<String>(
                                          value: purchaseValue,
                                          child: Text(purchaseValue.toString(),
                                              style: montserratMedium.copyWith(
                                                fontSize: 13.7,
                                                color: ColorTheme.foodValue,
                                              )).paddingOnly(left: 20),
                                        );
                                      },
                                    ).toList(),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  9.width,
                  Container(
                      width: 0.5,
                      height: 40,
                      color: ColorTheme.grey8C.withOpacity(.4)),
                  9.width,
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await inventoryController?.picFromDate();
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              inventoryController?.purchaseFromDate ??
                                  "DD-MM-YYYY",
                              style: montserratMedium.copyWith(
                                fontSize: 13.7,
                                color: ColorTheme.foodValue,
                              ),
                            ),
                            10.width,
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: ColorTheme.black5F6368,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  9.width,
                  Container(
                      width: 0.5,
                      height: 40,
                      color: ColorTheme.grey8C.withOpacity(.4)),
                  9.width,
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await inventoryController?.picToDate();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              inventoryController?.purchaseToDate ??
                                  "DD-MM-YYYY",
                              style: montserratMedium.copyWith(
                                fontSize: 13.7,
                                color: ColorTheme.foodValue,
                              ),
                            ),
                            10.width,
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: ColorTheme.black5F6368,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  9.width,
                ],
              ),
              Divider(color: ColorTheme.grey.withOpacity(.4), height: 0.25),
              20.height,
              CustomSearchField(
                onChanged: (p0) {
                  inventoryController?.update();
                },
                controller: inventoryController!.purchaseSearchController,
                hitText: AppString.searchByVendor,
              ).paddingSymmetric(horizontal: 20),
              20.height,
              Container(
                height: 40,
                color: ColorTheme.whiteColor,
                child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          15.width,
                          Text(AppString.ingredient,
                              style: montserratMedium.copyWith(
                                fontSize: 13.7,
                                color: ColorTheme.foodValue,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              vertical: BorderSide(color: ColorTheme.whiteE7))),
                      child: Text(AppString.quantity,
                          style: montserratMedium.copyWith(
                            fontSize: 13.7,
                            color: ColorTheme.foodValue,
                          )),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              vertical: BorderSide(color: ColorTheme.whiteE7))),
                      child: Text(AppString.paymentType,
                          style: montserratMedium.copyWith(
                            fontSize: 13.7,
                            color: ColorTheme.foodValue,
                          )),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Text(AppString.amount,
                          style: montserratMedium.copyWith(
                            fontSize: 13.7,
                            color: ColorTheme.foodValue,
                          )),
                    ),
                  ),
                ]),
              ),
              Expanded(child: GetBuilder<InventoryController>(
                builder: (controller) {
                  var filteredPurchaseList = inventoryController
                      ?.getPurchaseReportList
                      .where((element) {
                    return element["Ingredient_Name"]
                        .toString()
                        .toLowerCase()
                        .contains(inventoryController!
                            .purchaseSearchController.text
                            .toLowerCase());
                  }).toList();
                  return inventoryController!.getPurchaseReportLoader
                      ? AppLoader()
                      : filteredPurchaseList!.isNotEmpty
                          ? Container(
                              color: ColorTheme.whiteColor,
                              child: ListView.builder(
                                itemCount: filteredPurchaseList.length ?? 0,
                                itemBuilder: (context, index) {
                                  final purchase = filteredPurchaseList[index];
                                  return Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              color: ColorTheme.whiteE7)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            child: SingleChildScrollView(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    // width: 120,
                                                    child: Text(
                                                      purchase[
                                                              "Ingredient_Name"]
                                                          .toString(),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: montserratMedium
                                                          .copyWith(
                                                        fontSize: 13,
                                                        color: ColorTheme
                                                            .foodValue,
                                                      ),
                                                    ),
                                                  ),
                                                  5.height,
                                                  if (purchase[
                                                              "Purchase_Date"] !=
                                                          null &&
                                                      purchase[
                                                              "Purchase_Date"] !=
                                                          "")
                                                    Container(
                                                      // width: 120,
                                                      child: Text(
                                                        purchase[
                                                            "Purchase_Date"],
                                                        style: montserratMedium
                                                            .copyWith(
                                                          fontSize: 11,
                                                          color:
                                                              ColorTheme.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  3.height,
                                                  if (purchase["Vendor_Name"] !=
                                                          null &&
                                                      purchase["Vendor_Name"] !=
                                                          "")
                                                    Text(
                                                      purchase["Vendor_Name"],
                                                      style: montserratMedium
                                                          .copyWith(
                                                        fontSize: 11,
                                                        color: ColorTheme.green,
                                                      ),
                                                    ),
                                                ],
                                              ).paddingOnly(
                                                  left: 15, top: 5, bottom: 5),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.symmetric(
                                                vertical: BorderSide(
                                                    color: ColorTheme.whiteE7),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 7),
                                              child: Center(
                                                child: Text(
                                                  purchase["Quantity"],
                                                  maxLines: 1,
                                                  style:
                                                      montserratMedium.copyWith(
                                                    fontSize: 13.7,
                                                    color: ColorTheme.foodValue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: Border.symmetric(
                                                    vertical: BorderSide(
                                                        color: ColorTheme
                                                            .whiteE7))),
                                            child: Text(
                                              purchase["Payment_Type"],
                                              style: montserratMedium.copyWith(
                                                fontSize: 13.7,
                                                color: ColorTheme.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '₹ ${removeEndPoint00(purchase["Amount"])}',
                                              style: montserratMedium.copyWith(
                                                fontSize: 13.7,
                                                color: ColorTheme.green,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }
}
