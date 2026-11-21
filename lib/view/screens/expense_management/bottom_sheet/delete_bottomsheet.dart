import 'package:mygenie_restaurant/admin/app_loader/app_loader.dart';
import 'package:mygenie_restaurant/admin/constant/app_string.dart';
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

deleteBottomSheet(BuildContext context,
    {void Function()? onDeleteTap,
    required String expenseText,
    required ExpenseManagementController expenseController}) {
  expenseController.deleteReason = null;
  return showModalBottomSheet(
    context: context,
    backgroundColor: ColorTheme.whiteColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(),
    constraints: BoxConstraints(maxWidth: double.infinity),
    isDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppString.delete} $expenseText",
                        style: AppStyle.deleteTextStyle,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 43,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: ColorTheme.grey.withOpacity(.8)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: (expenseController.deleteReason?.isNotEmpty ??
                                false)
                            ? expenseController.deleteReason ?? ""
                            : null,
                        dropdownColor: ColorTheme.whiteColor,
                        isExpanded: true,
                        hint: Text(
                          AppString.selectReason,
                          style: TextStyle(
                              fontSize: 12,
                              color: ColorTheme.grey.withOpacity(.8)),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: ColorTheme.grey.withOpacity(.8),
                        ),
                        items: expenseController.deleteFoodReasonList
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          expenseController.deleteReason = newValue;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
                16.height,
                Obx(
                  () => GestureDetector(
                    onTap: expenseController.isDeleteSubmitting.value
                        ? null
                        : onDeleteTap,
                    child: Container(
                      height: 60,
                      color: ColorTheme.appColor,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: expenseController.isDeleteLoader.value
                          ? AppLoader()
                          : Text(
                              AppString.delete,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: ColorTheme.whiteColor,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
