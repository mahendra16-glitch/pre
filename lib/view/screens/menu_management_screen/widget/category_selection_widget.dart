import 'package:mygenie_restaurant/admin/constant/app_string.dart'
    show AppString;
import 'package:mygenie_restaurant/admin/constant/app_style.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class CategorySelectionWidget extends StatelessWidget {
  final bool isEdit;

  CategorySelectionWidget({this.isEdit = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuManagementController>(
      builder: (controller) => Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return controller.productCategoryList
              .where((p0) => p0["name"]
                  .toString()
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()))
              .map((p0) => p0["name"].toString())
              .toList();
        },
        onSelected: (String selectedCategory) {
          controller.setSelectedCategory(selectedCategory);

          var selectedCategoryData = controller.productCategoryList.firstWhere(
            (category) =>
                category["name"].toString().toLowerCase() ==
                selectedCategory.toLowerCase(),
          );

          controller.categoryIndex = selectedCategoryData["id"];
          controller.add_Edit_Category_Value.value =
              selectedCategoryData["name"];
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          if (isEdit && controller.add_Edit_Category_Value.value.isNotEmpty) {
            textController.text = controller.add_Edit_Category_Value.value;
          } else {
            textController.text = controller.add_Edit_Category_Value.value;
          }
          return TextField(
            style: AppStyle.txt14FoodValue,
            textCapitalization: TextCapitalization.words,
            controller: textController,
            focusNode: focusNode,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              labelText: AppString.selectCategory,
              labelStyle: AppStyle.txt14FoodValue,
              enabledBorder: border,
              focusedBorder: border,
              disabledBorder: border,
              border: border,
            ),
            onChanged: (value) {
              controller.add_Edit_Category_Value.value = value;
            },
            onSubmitted: (value) {
              onFieldSubmitted();
            },
          );
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 250,
                    maxWidth: MediaQuery.of(context).size.width < 600
                        ? MediaQuery.of(context).size.width / 1.4
                        : MediaQuery.of(context).size.width / 1.2),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorTheme.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorTheme.grey.withOpacity(.3)),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: ColorTheme.blackColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
  );
}
