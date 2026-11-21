import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/printer_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/printer_management/add_edit_printer.dart';

class PrinterManagementScreen extends StatefulWidget {
  const PrinterManagementScreen({Key? key}) : super(key: key);

  @override
  State<PrinterManagementScreen> createState() =>
      _PrinterManagementScreenState();
}

class _PrinterManagementScreenState extends State<PrinterManagementScreen> {
  bool _basicExpanded = false;
  @override
  void initState() {
    super.initState();
    // Fetch all printer data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<PrinterManagementController>();
      controller.getPrinterList();
      controller.getAreaOptions();
      controller.getPrintingOption();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.manageBgColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorTheme.green),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Printer Management',
          style: montserratSemiBold.copyWith(
            color: ColorTheme.black2E,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          GetBuilder<PrinterManagementController>(
            builder: (controller) {
              return IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: ColorTheme.appColor,
                ),
                tooltip: 'Refresh',
                onPressed: controller.isLoading
                    ? null
                    : () {
                        controller.getPrinterList();
                        controller.getAreaOptions();
                        controller.getPrintingOption();
                      },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: ColorTheme.appColor,
            ),
            tooltip: 'Add Printer',
            onPressed: () {
              Get.find<PrinterManagementController>().clearForm();
              Get.find<PrinterManagementController>().getPrintingOption();
              Get.to(() => AddEditPrinterScreen(isEdit: false));
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: GetBuilder<PrinterManagementController>(
        init: Get.find<PrinterManagementController>(),
        builder: (controller) {
          if (controller.isLoading && controller.printerList.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorTheme.appColor,
              ),
            );
          }

          return Column(
            children: [
              20.height,
              // Basic Configuration Section
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
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
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: _basicExpanded,
                    onExpansionChanged: (value) {
                      setState(() {
                        _basicExpanded = value;
                      });
                    },
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: EdgeInsets.all(16),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorTheme.appColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: ColorTheme.appColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Basic Configuration',
                      style: montserratSemiBold.copyWith(
                        color: ColorTheme.black,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Configure printer mode',
                      style: montserratRegular.copyWith(
                        color: ColorTheme.grey1,
                        fontSize: 12,
                      ),
                    ),
                    children: [
                      // Mode Dropdown
                      _buildDropdown(
                        label: 'Printer Mode',
                        value: controller.selectedMode,
                        items: controller.modeOptions,
                        onChanged: (value) => controller.setMode(value),
                        hint: 'Select mode',
                      ),
                      SizedBox(height: 15),
                      // Update Mode Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isUpdatingPrintingOption
                              ? null
                              : () async {
                                  if (controller.selectedMode == null ||
                                      controller.selectedMode!.isEmpty) {
                                    showCustomSnackBar(
                                        'Please select a printing mode',
                                        isError: true);
                                    return;
                                  }

                                  final restaurantId =
                                      Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants![0]
                                          .id;

                                  await controller.updatePrintingOption(
                                      restaurantId!, controller.selectedMode!);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.blueColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isUpdatingPrintingOption
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Update Mode',
                                  style: montserratSemiBold.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Table Header
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                decoration: BoxDecoration(
                  color: ColorTheme.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border.all(color: ColorTheme.borderGrey2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                  decoration: BoxDecoration(
                    // color: ColorTheme.appColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(right: 12, left: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: ColorTheme.borderGrey2,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Area Name',
                            style: montserratBold.copyWith(
                              color: ColorTheme.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          // padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: ColorTheme.borderGrey2,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Printer Type',
                              style: montserratBold.copyWith(
                                color: ColorTheme.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Actions',
                            style: montserratBold.copyWith(
                              color: ColorTheme.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Table Body
              controller.printerList.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.print_disabled,
                              size: 80,
                              color: ColorTheme.grey1.withOpacity(0.3),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No printers configured',
                              style: montserratMedium.copyWith(
                                color: ColorTheme.grey1,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add a printer to get started',
                              style: montserratRegular.copyWith(
                                color: ColorTheme.grey1.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : controller.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                          color: ColorTheme.appColor,
                        ))
                      : Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 10, right: 10, bottom: 20),
                            decoration: BoxDecoration(
                              color: ColorTheme.whiteColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              border: Border(
                                left: BorderSide(color: ColorTheme.borderGrey2),
                                right:
                                    BorderSide(color: ColorTheme.borderGrey2),
                                bottom:
                                    BorderSide(color: ColorTheme.borderGrey2),
                              ),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: controller.printerList.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: ColorTheme.borderGrey2,
                              ),
                              itemBuilder: (context, index) {
                                final printer = controller.printerList[index];
                                final isLast =
                                    index == controller.printerList.length - 1;

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? ColorTheme.whiteColor
                                        : ColorTheme.addressBoxGrey
                                            .withOpacity(0.3),
                                    borderRadius: isLast
                                        ? BorderRadius.only(
                                            bottomLeft: Radius.circular(11),
                                            bottomRight: Radius.circular(11),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // Area Name
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              right: 12, left: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: ColorTheme.borderGrey2,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            printer['area_name'] ?? 'N/A',
                                            style: montserratMedium.copyWith(
                                              color: ColorTheme.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Printer Type
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          // padding: EdgeInsets.symmetric(
                                          //     horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: ColorTheme.borderGrey2,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getPrinterTypeDisplay(
                                                  printer['printer_name']),
                                              textAlign: TextAlign.center,
                                              style: montserratMedium.copyWith(
                                                color: _getPrinterTypeColor(
                                                    printer['printer_name']),
                                                fontSize: 12,
                                              ),
                                            ),
                                            // child: Container(
                                            //   padding: EdgeInsets.symmetric(
                                            //     horizontal: 10,
                                            //     vertical: 5,
                                            //   ),
                                            //   decoration: BoxDecoration(
                                            //     color: _getPrinterTypeColor(
                                            //             printer['printer_name'])
                                            //         .withOpacity(0.1),
                                            //     borderRadius:
                                            //         BorderRadius.circular(16),
                                            //     border: Border.all(
                                            //       color: _getPrinterTypeColor(
                                            //               printer['printer_name'])
                                            //           .withOpacity(0.3),
                                            //     ),
                                            //   ),
                                            //   child: Text(
                                            //     _getPrinterTypeDisplay(
                                            //         printer['printer_name']),
                                            //     textAlign: TextAlign.center,
                                            //     style: montserratMedium.copyWith(
                                            //       color: _getPrinterTypeColor(
                                            //           printer['printer_name']),
                                            //       fontSize: 12,
                                            //     ),
                                            //   ),
                                            // ),
                                          ),
                                        ),
                                      ),

                                      // Actions
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Edit Button
                                            InkWell(
                                              onTap: () {
                                                controller.getPrintingOption();
                                                controller
                                                    .setEditingPrinter(printer);
                                                Get.to(
                                                    () => AddEditPrinterScreen(
                                                          isEdit: true,
                                                        ));
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: ColorTheme.blueColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: ColorTheme.blueColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            // Delete Button
                                            InkWell(
                                              onTap: () {
                                                _showDeleteConfirmationBottomSheet(
                                                    context,
                                                    printer,
                                                    controller);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: ColorTheme.redColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.delete_outline,
                                                  color: ColorTheme.redColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }

  String _getPrinterTypeDisplay(String? type) {
    if (type == null) return 'N/A';
    // if (type == 'online') return 'WiFi/LAN';
    return type.toUpperCase();
  }

  Color _getPrinterTypeColor(String? type) {
    if (type == null) return ColorTheme.grey1;
    switch (type) {
      case 'bluetooth':
        return ColorTheme.blueColor;
      case 'usb':
        return ColorTheme.greenColor;
      case 'wifi/LAN':
        return ColorTheme.appColor;
      default:
        return ColorTheme.grey1;
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
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

  // Delete Confirmation Bottom Sheet
  void _showDeleteConfirmationBottomSheet(BuildContext context,
      Map<String, dynamic> printer, PrinterManagementController controller) {
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
                'Delete Printer',
                style: montserratSemiBold.copyWith(
                  color: ColorTheme.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to delete printer "${printer['area_name'] ?? 'N/A'}" with type "${_getPrinterTypeDisplay(printer['printer_name'])}"?',
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
                        controller.deletePrinter(printer['id']);
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
