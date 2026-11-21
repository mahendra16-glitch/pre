import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/printer_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/view/printer_management/printer_discovery_screen.dart';

class AddEditPrinterScreen extends StatefulWidget {
  final bool isEdit;

  const AddEditPrinterScreen({Key? key, required this.isEdit})
      : super(key: key);

  @override
  State<AddEditPrinterScreen> createState() => _AddEditPrinterScreenState();
}

class _AddEditPrinterScreenState extends State<AddEditPrinterScreen> {
  bool _basicExpanded = false;
  bool _advancedExpanded = true;

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
          widget.isEdit ? 'Edit Printer' : 'Add Printer',
          style: montserratSemiBold.copyWith(
            color: ColorTheme.black,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: GetBuilder<PrinterManagementController>(
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
              child: Row(
                children: [
                  // Update Mode Button
                  // Expanded(
                  //   flex: 2,
                  //   child: ElevatedButton(
                  //     onPressed: controller.isUpdatingPrintingOption
                  //         ? null
                  //         : () async {
                  //             if (controller.selectedMode == null ||
                  //                 controller.selectedMode!.isEmpty) {
                  //               showCustomSnackBar(
                  //                   'Please select a printing mode',
                  //                   isError: true);
                  //               return;
                  //             }

                  //             final restaurantId = Get.find<AuthController>()
                  //                 .profileModel!
                  //                 .restaurants![0]
                  //                 .id;

                  //             await controller.updatePrintingOption(
                  //                 restaurantId!, controller.selectedMode!);
                  //           },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: ColorTheme.blueColor,
                  //       padding: EdgeInsets.symmetric(vertical: 16),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(30),
                  //       ),
                  //       elevation: 0,
                  //     ),
                  //     child: controller.isUpdatingPrintingOption
                  //         ? SizedBox(
                  //             height: 20,
                  //             width: 20,
                  //             child: CircularProgressIndicator(
                  //               color: Colors.white,
                  //               strokeWidth: 2,
                  //             ),
                  //           )
                  //         : Text(
                  //             'Update Mode',
                  //             style: montserratSemiBold.copyWith(
                  //               color: Colors.white,
                  //               fontSize: 16,
                  //             ),
                  //           ),
                  //   ),
                  // ),

                  // SizedBox(width: 16),

                  // Add/Update Printer Button
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              bool success = await controller.savePrinter();
                              if (success) {
                                Get.back();
                              }
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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.isEdit ? 'Update Printer' : 'Add Printer',
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
          );
        },
      ),
      body: GetBuilder<PrinterManagementController>(
        init: Get.find<PrinterManagementController>(),
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Configuration Section
                // Container(
                //   decoration: BoxDecoration(
                //     color: ColorTheme.whiteColor,
                //     borderRadius: BorderRadius.circular(16),
                //     border: Border.all(color: ColorTheme.borderGrey2),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.04),
                //         blurRadius: 8,
                //         offset: Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: Theme(
                //     data: Theme.of(context)
                //         .copyWith(dividerColor: Colors.transparent),
                //     child: ExpansionTile(
                //       initiallyExpanded: _basicExpanded,
                //       onExpansionChanged: (value) {
                //         setState(() {
                //           _basicExpanded = value;
                //         });
                //       },
                //       tilePadding:
                //           EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //       childrenPadding: EdgeInsets.all(16),
                //       leading: Container(
                //         padding: EdgeInsets.all(8),
                //         decoration: BoxDecoration(
                //           color: ColorTheme.appColor.withOpacity(0.1),
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         child: Icon(
                //           Icons.settings,
                //           color: ColorTheme.appColor,
                //           size: 24,
                //         ),
                //       ),
                //       title: Text(
                //         'Basic Configuration',
                //         style: montserratSemiBold.copyWith(
                //           color: ColorTheme.black,
                //           fontSize: 16,
                //         ),
                //       ),
                //       subtitle: Text(
                //         'Configure printer mode',
                //         style: montserratRegular.copyWith(
                //           color: ColorTheme.grey1,
                //           fontSize: 12,
                //         ),
                //       ),
                //       children: [
                //         // Mode Dropdown
                //         _buildDropdown(
                //           label: 'Printer Mode',
                //           value: controller.selectedMode,
                //           items: controller.modeOptions,
                //           onChanged: (value) => controller.setMode(value),
                //           hint: 'Select mode',
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // SizedBox(height: 20),

                // Advanced Configuration Section
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
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: _advancedExpanded,
                      onExpansionChanged: (value) {
                        setState(() {
                          _advancedExpanded = value;
                        });
                      },
                      tilePadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      childrenPadding: EdgeInsets.all(16),
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorTheme.blueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: ColorTheme.blueColor,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        'Advanced Configuration',
                        style: montserratSemiBold.copyWith(
                          color: ColorTheme.black,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Detailed printer settings',
                        style: montserratRegular.copyWith(
                          color: ColorTheme.grey1,
                          fontSize: 12,
                        ),
                      ),
                      children: [
                        // Area/Printer For Dropdown
                        _buildDropdown(
                          label: 'Printer For',
                          value: controller.selectedArea,
                          items: controller.areaOptions,
                          onChanged: (value) => controller.setArea(value),
                          hint: 'Select area',
                        ),
                        SizedBox(height: 20),

                        // Printer Type Dropdown
                        _buildDropdown(
                          label: 'Printer Type',
                          value: controller.selectedPrinterType,
                          items: controller.printerTypeOptions,
                          onChanged: (value) =>
                              controller.setPrinterType(value),
                          hint: 'Select printer type',
                        ),
                        SizedBox(height: 20),

                        // Conditional fields based on printer type
                        if (controller.selectedPrinterType == 'bluetooth') ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Android IP',
                                  controller: controller.androidIpCtrl,
                                  hint: 'e.g., AB:0A:20:24:42:D3',
                                ),
                              ),
                              SizedBox(width: 12),
                              _buildScanButton('bluetooth', controller),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],

                        if (controller.selectedPrinterType == 'usb') ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Printer Name',
                                  controller: controller.wifiPrinterNameCtrl,
                                  hint: 'Enter printer name',
                                ),
                              ),
                              SizedBox(width: 12),
                              _buildScanButton('usb', controller),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            label: 'Product ID',
                            controller: controller.productIdCtrl,
                            hint: 'Enter product ID',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            label: 'Vendor ID',
                            controller: controller.vendorIdCtrl,
                            hint: 'Enter vendor ID',
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 20),
                        ],

                        if (controller.selectedPrinterType == 'wifi') ...[
                          _buildTextField(
                            label: 'Printer Name',
                            controller: controller.wifiPrinterNameCtrl,
                            hint: 'Enter printer name',
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Printer IP',
                                  controller: controller.wifiPrinterIpCtrl,
                                  hint: 'e.g., 192.168.1.100',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12),
                              _buildScanButton('wifi', controller),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],

                        // Paper Roll Size Dropdown
                        _buildPaperRollDropdown(
                          label: 'Paper Roll Size',
                          value: controller.selectedPaperRoll,
                          items: controller.paperRollOptions,
                          onChanged: (value) => controller.setPaperRoll(value),
                          hint: 'Select paper roll size',
                        ),
                        SizedBox(height: 20),

                        // Default Dropdown
                        _buildDropdown(
                          label: 'Default',
                          value: controller.selectedDefault ?? 'Select',
                          items: controller.defaultOptions,
                          onChanged: (value) => controller.setDefault(value),
                          hint: 'select',
                        ),
                        SizedBox(height: 20),

                        _buildAutoServeToggle(controller),
                        SizedBox(height: 20),

                        if (controller.showStationGst) ...[
                          _buildTextField(
                            label: 'Station GST',
                            controller: controller.stationGstCtrl,
                            hint: 'Enter station GST',
                          ),
                          SizedBox(height: 20),
                        ],

                        // Default Printer Switch
                        // Container(
                        //   padding: EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: ColorTheme.addressBoxGrey,
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(color: ColorTheme.borderGrey2),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             'Set as Default Printer',
                        //             style: montserratMedium.copyWith(
                        //               color: ColorTheme.black,
                        //               fontSize: 15,
                        //             ),
                        //           ),
                        //           SizedBox(height: 4),
                        //           Text(
                        //             'Use this printer by default',
                        //             style: montserratRegular.copyWith(
                        //               color: ColorTheme.grey1,
                        //               fontSize: 12,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       Switch(
                        //         value: controller.selectedDefault == '1',
                        //         onChanged: (value) {
                        //           controller.setDefault(value ? '1' : '0');
                        //         },
                        //         activeColor: ColorTheme.appColor,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
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

  Widget _buildPaperRollDropdown({
    required String label,
    required int? value,
    required List<int> items,
    required Function(int?) onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField2<int>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<int>(
          value: item,
          child: Text(
            '$item mm',
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

  Widget _buildAutoServeToggle(PrinterManagementController controller) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Auto Serve',
        labelStyle: montserratMedium.copyWith(
          color: ColorTheme.black,
          fontSize: 15,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.fromLTRB(20, 8, 12, 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Color(0xFFDCDCDC)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.autoServe ? 'Yes' : 'No',
            style: montserratMedium.copyWith(
              color: Color(0xFF828282),
              fontSize: 14,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: controller.autoServe,
              onChanged: controller.setAutoServe,
              activeColor: ColorTheme.appColor,
            ),
          ),
        ],
      ),
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

  Widget _buildScanButton(
      String printerType, PrinterManagementController controller) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: InkWell(
        onTap: () async {
          final result = await Get.to<DiscoveredPrinter>(
            () => PrinterDiscoveryScreen(printerType: printerType),
          );

          if (result != null) {
            // Auto-fill the controllers based on printer type
            if (printerType == 'bluetooth') {
              controller.androidIpCtrl.text = result.address ?? '';
              controller.setPrinterType('bluetooth');
              controller.update();
              showCustomSnackBar(
                  'Bluetooth printer data populated: ${result.deviceName}',
                  isError: false);
            } else if (printerType == 'usb') {
              controller.wifiPrinterNameCtrl.text = result.deviceName ?? '';
              if (result.vendorId != null && result.vendorId!.isNotEmpty) {
                controller.vendorIdCtrl.text = result.vendorId!;
              }
              if (result.productId != null && result.productId!.isNotEmpty) {
                controller.productIdCtrl.text = result.productId!;
              }
              controller.setPrinterType('usb');
              controller.update();
              showCustomSnackBar(
                  'USB printer data populated: ${result.deviceName}',
                  isError: false);
            } else if (printerType == 'wifi') {
              controller.wifiPrinterIpCtrl.text = result.address ?? '';
              controller.wifiPrinterNameCtrl.text = result.deviceName ?? '';
              controller.setPrinterType('wifi');
              controller.update();
              showCustomSnackBar(
                  'Network printer data populated: ${result.deviceName}',
                  isError: false);
            }
          }
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorTheme.appColor,
            borderRadius: BorderRadius.circular(12),
            // boxShadow: [
            //   BoxShadow(
            //     color: ColorTheme.appColor.withOpacity(0.3),
            //     blurRadius: 8,
            //     offset: Offset(0, 4),
            //   ),
            // ],
          ),
          child: Icon(
            Icons.radar,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
