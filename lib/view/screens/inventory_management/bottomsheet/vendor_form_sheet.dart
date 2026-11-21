import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/admin/widget/custom_dropdown.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void vendorForm(BuildContext context,
    {required InventoryController inventoryController,
    required isEdit,
    int? id,
    Map<String, dynamic>? vendorData}) {
  inventoryController.vendorDataClear();
  inventoryController.vendorApiCalling(isEdit: isEdit, vendorData: vendorData);
  inventoryController.getVendorType();
  showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(maxWidth: double.infinity),
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: ColorTheme.whiteColor,
    shape: RoundedRectangleBorder(),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Form(
            key: inventoryController.vendorFormKey,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppString.vendorForm,
                              style: AppStyle.stockListStyle
                                  .copyWith(fontSize: 15)),
                          IconButton(
                            icon: Icon(Icons.close, color: ColorTheme.grey74),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ],
                      ).paddingOnly(left: 20, right: 20),
                      10.height,
                      Container(
                          height: 0.5,
                          color: Color(0xff747474).withOpacity(.5)),
                      15.height,
                      Column(
                        children: [
                          CustomTextformField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (p0) {
                              if (p0 == null || p0 == "") {
                                return AppString.pleaseEnterVendorName;
                              }
                              return null;
                            },
                            controller:
                                inventoryController.vendorNameController,
                            labelText: AppString.vendorName,
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (p0) {
                                    if (p0 == null || p0 == "") {
                                      return AppString.pleaseEnterContactPerson;
                                    }
                                    return null;
                                  },
                                  controller: inventoryController
                                      .contactPersonController,
                                  labelText: AppString.contactPersonName,
                                ),
                              ),
                              20.width,
                              Expanded(
                                child: CustomTextformField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (p0) {
                                    if (p0 == null || p0 == "") {
                                      return AppString.pleaseEnterContactNumber;
                                    }
                                    return null;
                                  },
                                  controller: inventoryController
                                      .contactNumberController,
                                  keyboardType: TextInputType.number,
                                  labelText: AppString.contactNumber,
                                ),
                              ),
                            ],
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CustomTextformField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (p0) {
                                    if (p0 == null || p0 == "") {
                                      return AppString.pleaseEnterAddress;
                                    }
                                    return null;
                                  },
                                  controller:
                                      inventoryController.addressController,
                                  labelText: AppString.address,
                                ),
                              ),
                              20.width,
                              Expanded(
                                child: CustomTextformField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (p0) {
                                    if (p0 == null || p0 == "") {
                                      return AppString.pleaseEnterEmail;
                                    }
                                    return null;
                                  },
                                  controller:
                                      inventoryController.vendorEmailController,
                                  labelText: AppString.email,
                                ),
                              ),
                            ],
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                             
                                child: CustomDropdownWidget(
                                  items: inventoryController.vendorTypeList
                                      .cast<Map<String, dynamic>>()
                                      .map<String?>((e) => e["name"] as String?)
                                      .where((name) => name != null)
                                      .map<DropdownMenuItem<String>>((name) {
                                    return DropdownMenuItem<String>(
                                      value: name!,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          // fontFamily: AppFonts.montserrat,
                                          fontSize: 12,
                                          color: ColorTheme.foodValue,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  hintText: AppString.vendorType,
                                  onChanged: (String? newValue) {
                                    inventoryController.vendorType = newValue;
                                    setState(() {});
                                  },
                                  value: inventoryController.vendorType != null
                                      ? inventoryController.vendorType
                                      : null,
                                ),
                              ),
                              20.width,
                              Expanded(
                                child: CustomTextformField(
                                  controller:
                                      inventoryController.gstNumberController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (p0) {
                                    if (p0 == null || p0 == "") {
                                      return AppString.pleaseEnterGstNumber;
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  labelText: AppString.gSTNumber,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).paddingOnly(left: 20, right: 20),
                    ],
                  ),
                  20.height,
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await inventoryController.importVendorSupplier();
                          },
                          child: Container(
                            height: 50,
                            decoration:
                                BoxDecoration(color: ColorTheme.appColor),
                            alignment: Alignment.center,
                            child: Text(AppString.bulkUpload,
                                style: AppStyle.txt14FoodValue.copyWith(
                                    color: ColorTheme.whiteColor,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      Obx(
                        () => Expanded(
                          child: GestureDetector(
                            onTap: inventoryController.isVendorSubmitting.value
                                ? null
                                : () async {
                                    if (isEdit) {
                                      await inventoryController
                                          .updateVendor(id!);
                                    } else {
                                      await inventoryController.addVendor();
                                    }
                                  },
                            child: Container(
                              height: 50,
                              decoration:
                                  BoxDecoration(color: ColorTheme.greenColor),
                              alignment: Alignment.center,
                              child: inventoryController.addVendorLoader.value
                                  ? AppLoader()
                                  : Text(
                                      AppString.submit,
                                      style: AppStyle.txt14FoodValue.copyWith(
                                          color: ColorTheme.whiteColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  20.height,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
