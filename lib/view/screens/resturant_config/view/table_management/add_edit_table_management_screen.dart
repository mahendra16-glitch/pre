import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/table_management_controller.dart';

class AddEditTableManagementScreen extends StatefulWidget {
  final bool isEdit;

  const AddEditTableManagementScreen({Key? key, required this.isEdit})
      : super(key: key);

  @override
  State<AddEditTableManagementScreen> createState() =>
      _AddEditTableManagementScreenState();
}

class _AddEditTableManagementScreenState
    extends State<AddEditTableManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorTheme.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isEdit ? 'Edit Table' : 'Add Table',
          style: montserratSemiBold.copyWith(
            color: ColorTheme.black,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: GetBuilder<TableManagementController>(
        builder: (controller) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorTheme.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        await controller.saveTable();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.appColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: SpinKitFadingCircle(
                          color: Colors.white,
                          size: 20.0,
                        ),
                      )
                    : Text(
                        widget.isEdit ? 'Update Table' : 'Add Table',
                        style: montserratSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
      body: GetBuilder<TableManagementController>(
        init: Get.find<TableManagementController>(),
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Configuration Section
                Container(
                  decoration: BoxDecoration(
                    color: ColorTheme.whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorTheme.borderGrey2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ColorTheme.appColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.table_restaurant,
                              color: ColorTheme.appColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Table Configuration',
                                style: montserratSemiBold.copyWith(
                                  color: ColorTheme.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Configure table details',
                                style: montserratRegular.copyWith(
                                  color: ColorTheme.grey1,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Area Field (Type or Select)
                      _buildAreaField(
                        label: 'Area',
                        controller: controller.areaCtrl,
                        items: controller.areaOptions,
                        onSelected: (value) => controller.setArea(value),
                        hint: 'Type or select area',
                      ),
                      SizedBox(height: 20),

                      // Table Number TextField
                      _buildTextField(
                        label: 'Table Number',
                        controller: controller.tableNoCtrl,
                        hint: 'e.g., T-01',
                      ),
                      SizedBox(height: 20),

                      // Waiter Dropdown
                      // _buildWaiterDropdown(
                      //   label: 'Waiter',
                      //   value: controller.selectedWaiterId,
                      //   items: controller.waiterList,
                      //   onChanged: (value) => controller.setWaiter(value),
                      //   hint: 'Select waiter',
                      // ),
                      // SizedBox(height: 20),

                      // Table/Room Toggle
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorTheme.addressBoxGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorTheme.borderGrey2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type',
                              style: montserratMedium.copyWith(
                                color: ColorTheme.black,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => controller.setType('TB'),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: controller.selectedType == 'TB'
                                            ? ColorTheme.greenColor
                                            : ColorTheme.whiteColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: controller.selectedType == 'TB'
                                              ? ColorTheme.greenColor
                                              : ColorTheme.borderGrey2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.table_restaurant,
                                            color:
                                                controller.selectedType == 'TB'
                                                    ? Colors.white
                                                    : ColorTheme.grey1,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Table',
                                            style: montserratSemiBold.copyWith(
                                              color: controller.selectedType ==
                                                      'TB'
                                                  ? Colors.white
                                                  : ColorTheme.grey1,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => controller.setType('RM'),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: controller.selectedType == 'RM'
                                            ? ColorTheme.greenColor
                                            : ColorTheme.whiteColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: controller.selectedType == 'RM'
                                              ? ColorTheme.greenColor
                                              : ColorTheme.borderGrey2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.meeting_room,
                                            color:
                                                controller.selectedType == 'RM'
                                                    ? Colors.white
                                                    : ColorTheme.grey1,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Room',
                                            style: montserratSemiBold.copyWith(
                                              color: controller.selectedType ==
                                                      'RM'
                                                  ? Colors.white
                                                  : ColorTheme.grey1,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaiterDropdown({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField2<int>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: Text(
            item['name'] ?? 'N/A',
            style: montserratMedium.copyWith(
              color: Color(0xFF828282),
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.symmetric(horizontal: 0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Color(0xFFDCDCDC),
          ),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: 45,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: montserratMedium.copyWith(
          color: ColorTheme.black,
          fontSize: 15,
        ),
        hintText: hint,
        hintStyle: montserratRegular.copyWith(
          color: ColorTheme.grey1,
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        // contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
      ),
    );
  }

  Widget _buildAreaField({
    required String label,
    required TextEditingController controller,
    required List<String> items,
    required Function(String?) onSelected,
    required String hint,
  }) {
    return TypeAheadField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        style: montserratMedium.copyWith(
          color: ColorTheme.black,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: montserratMedium.copyWith(
            color: ColorTheme.black,
            fontSize: 15,
          ),
          hintText: hint,
          hintStyle: montserratRegular.copyWith(
            color: ColorTheme.grey1,
            fontSize: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFDCDCDC)),
          ),
          filled: true,
          fillColor: ColorTheme.whiteColor,
        ),
        onChanged: (value) {
          onSelected(value);
        },
      ),
      suggestionsCallback: (pattern) {
        if (pattern.isEmpty) {
          return [];
        }

        final suggestions = items
            .where((element) =>
                element.toLowerCase().contains(pattern.toLowerCase()))
            .toList();

        // If no match found, show "Add" option
        if (suggestions.isEmpty) {
          return ["Add \"$pattern\""];
        }

        return suggestions;
      },
      noItemsFoundBuilder: (context) {
        return Container(
          padding: EdgeInsets.all(12),
          child: Text(
            "No results found",
            style: montserratRegular.copyWith(
              color: ColorTheme.grey1,
              fontSize: 14,
            ),
          ),
        );
      },
      loadingBuilder: (context) {
        return Container(
          padding: EdgeInsets.all(12),
          child: Text(
            "Loading...",
            style: montserratRegular.copyWith(
              color: ColorTheme.grey1,
              fontSize: 14,
            ),
          ),
        );
      },
      debounceDuration: Duration(milliseconds: 300),
      hideOnEmpty: true,
      hideOnLoading: false,
      itemBuilder: (context, String suggestion) {
        final isAddOption = suggestion.startsWith("Add ");

        return ListTile(
          leading: isAddOption
              ? Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: ColorTheme.appColor,
                )
              : SizedBox.shrink(),
          title: Text(
            suggestion,
            style: montserratMedium.copyWith(
              fontSize: 14,
              color: ColorTheme.black,
              fontWeight: isAddOption ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          tileColor: isAddOption
              ? ColorTheme.appColor.withOpacity(0.05)
              : Colors.transparent,
          dense: true,
        );
      },
      onSuggestionSelected: (String suggestion) {
        if (suggestion.startsWith("Add ")) {
          // Extract custom value from "Add "value""
          final customValue =
              suggestion.replaceFirst("Add \"", "").replaceFirst("\"", "");
          controller.text = customValue;
          onSelected(customValue);
        } else {
          controller.text = suggestion;
          onSelected(suggestion);
        }
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: montserratMedium.copyWith(
        color: ColorTheme.black,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: montserratMedium.copyWith(
          color: ColorTheme.black,
          fontSize: 15,
        ),
        hintText: hint,
        hintStyle: montserratRegular.copyWith(
          color: ColorTheme.grey1,
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
      ),
    );
  }
}
