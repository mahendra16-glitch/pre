import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_border.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

categoryAddBottomSheet(
  BuildContext context, {
  required ExpenseManagementController expenseController,
  void Function()? onTap,
}) {
  expenseController.newCategoryNameController.clear();
  return showModalBottomSheet(
    context: context,
    backgroundColor: ColorTheme.whiteColor,
    isScrollControlled: true,
    isDismissible: false,
    constraints: BoxConstraints(maxWidth: double.infinity),
    shape: RoundedRectangleBorder(),
    builder: (context) {
      return Padding(
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
                          AppString.newCategory,
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
                  16.height,
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      child: TextFormField(
                        controller: expenseController.newCategoryNameController,
                        decoration: InputDecoration(
                          hintText: AppString.categoryName,
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: ColorTheme.grey.withOpacity(.5)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          border: AppBorder.selectStockNameFieldBorder,
                          enabledBorder: AppBorder.selectStockNameFieldBorder,
                          focusedBorder: AppBorder.selectStockNameFieldBorder,
                        ),
                      ),
                    ),
                  ),
                  20.height,
                ],
              ),
              Obx(
                () => GestureDetector(
                  onTap: expenseController.isCategorySubmitting.value
                      ? null
                      : onTap,
                  child: Container(
                    height: 60,
                    color: ColorTheme.greenColor,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: expenseController.isAddCategoryLoader.value
                        ? AppLoader()
                        : Text(
                            AppString.addCategory,
                            style: AppStyle.addCategoryTextStyle,
                          ),
                  ),
                ),
              ),
              20.height,
            ],
          ),
        ),
      );
    },
  );
}
