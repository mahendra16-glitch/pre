import 'package:mygenie_restaurant/view/screens/employee_management/controller/employee_management_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/super_tooltip.dart';
import 'package:get/get.dart';

class AddEditEmployeeRoleScreen extends StatefulWidget {
  final Key? key;
  bool? isEdit = false;
  int? id;
  Map<String, dynamic> employeeRoleData;
  AddEditEmployeeRoleScreen(
      {this.key, this.isEdit, required this.employeeRoleData, this.id})
      : super(key: key);

  @override
  State<AddEditEmployeeRoleScreen> createState() =>
      _AddEditEmployeeRoleScreenState();
}

class _AddEditEmployeeRoleScreenState extends State<AddEditEmployeeRoleScreen> {
  final _accountKey = GlobalKey<FormState>();
  final _generalKey = GlobalKey<FormState>();

  bool _isTooltipVisible = false;
  bool _isTooltipVisible2 = false;
  bool _isTooltipVisible3 = false;

  SuperTooltipController? _tooltipController;
  SuperTooltipController? _tooltipController2;
  SuperTooltipController? _tooltipController3;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  FocusNode _firstNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final employeeMngmtController = Get.find<EmployeeManagementController>();

    employeeMngmtController.addEditInitCall(
        isEdit: widget.isEdit == null ? false : widget.isEdit,
        employeeData: widget.employeeRoleData);
    _tooltipController = SuperTooltipController();
    _tooltipController2 = SuperTooltipController();
    _tooltipController3 = SuperTooltipController();

    _firstNameFocus.addListener(() {
      if (!_firstNameFocus.hasFocus &&
          employeeMngmtController.firstNameController.text.isNotEmpty) {
        employeeMngmtController.autoPopulateEmail();
      }
    });
  }

  void _toggleTooltip() {
    setState(() {
      // _isTooltipVisible = !_isTooltipVisible;
      if (_isTooltipVisible) {
        _tooltipController!.showTooltip();
      } else {
        _tooltipController!.hideTooltip();
      }
    });
  }

  void _toggleTooltip2() {
    setState(() {
      // _isTooltipVisible = !_isTooltipVisible;
      if (_isTooltipVisible2) {
        _tooltipController2!.showTooltip();
      } else {
        _tooltipController2!.hideTooltip();
      }
    });
  }

  void _toggleTooltip3() {
    setState(() {
      // _isTooltipVisible = !_isTooltipVisible;
      if (_isTooltipVisible3) {
        _tooltipController3!.showTooltip();
      } else {
        _tooltipController3!.hideTooltip();
      }
    });
  }

  // void checkPassword() {
  //   setState(() {
  //     isMatched = passwordController.text == passwordConfirmController.text;
  //   });
  // }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tooltipController?.dispose();
    _tooltipController2?.dispose();
    _tooltipController3?.dispose();
    _firstNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EmployeeManagementController>(
        builder: (employeeMngmtController) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: ColorTheme.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.orange),
            onPressed: () {
              Get.back();
            },
          ),
          titleSpacing: 0,
          scrolledUnderElevation: 0,
          title: Text(
            (widget.isEdit ?? false) ? 'Edit Employee' : 'Add New Employee',
            style: montserratSemiBold.copyWith(
                color: ColorTheme.green, fontSize: 18),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: GetBuilder<EmployeeManagementController>(
            builder: (employeeMngmtController) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, left: 0, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: _buildGeneralSection(),
                ),
                const SizedBox(height: 20),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: _buildAccountSection(),
                // ),
                const SizedBox(height: 30),
              ],
            ),
          );
        }),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
            decoration: BoxDecoration(color: ColorTheme.white),
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                  onTap: () {
                    (employeeMngmtController.selectedRole != 'All Role' ||
                            employeeMngmtController
                                .firstNameController.text.isNotEmpty ||
                            employeeMngmtController
                                .lastNameController.text.isNotEmpty ||
                            employeeMngmtController
                                .phoneController.text.isNotEmpty ||
                            employeeMngmtController
                                .emailController.text.isNotEmpty ||
                            employeeMngmtController
                                .passwordController.text.isNotEmpty ||
                            employeeMngmtController
                                .confirmPasswordController.text.isNotEmpty ||
                            employeeMngmtController.selectedBillUser != 'No' ||
                            employeeMngmtController.selectedFoodFor.isNotEmpty)
                        ? employeeMngmtController.resetController()
                        : null;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Center(
                      child: employeeMngmtController.isReset
                          ? SpinKitFadingCircle(
                              color: ColorTheme.borderGrey,
                              size: 25.0,
                            )
                          : Text(
                              'Reset',
                              style: montserratSemiBold.copyWith(
                                  color: ColorTheme.borderGrey, fontSize: 15),
                            ),
                    ),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    if (!_generalKey.currentState!.validate()) return;

                    if (employeeMngmtController.selectedRole == 'All Role') {
                      Get.snackbar('Select Role', 'Please select a role',
                          backgroundColor: ColorTheme.red,
                          colorText: Colors.white);
                    } else if (employeeMngmtController
                        .firstNameController.text.isEmpty) {
                      Get.snackbar('First Name', 'Please enter first name',
                          backgroundColor: ColorTheme.red,
                          colorText: Colors.white);
                    } else if (employeeMngmtController
                        .phoneController.text.isEmpty) {
                      Get.snackbar('Phone', 'Please enter phone number',
                          backgroundColor: ColorTheme.red,
                          colorText: Colors.white);
                    } else if (employeeMngmtController
                        .emailController.text.isEmpty) {
                      Get.snackbar('E-Mail', 'Please enter e-mail',
                          backgroundColor: ColorTheme.red,
                          colorText: Colors.white);
                    } else if (widget.isEdit == null) {
                      if (employeeMngmtController
                          .passwordController.text.isEmpty) {
                        Get.snackbar('Password', 'Please enter password',
                            backgroundColor: ColorTheme.red,
                            colorText: Colors.white);
                      } else if (employeeMngmtController
                          .confirmPasswordController.text.isEmpty) {
                        Get.snackbar(
                            'Confirm Password', 'Please enter confirm password',
                            backgroundColor: ColorTheme.red,
                            colorText: Colors.white);
                      } else if (!employeeMngmtController.isMatched) {
                        Get.snackbar(
                            'Password Mismatch', 'Passwords do not match',
                            backgroundColor: ColorTheme.red,
                            colorText: Colors.white);
                      } else {
                        if (widget.isEdit ?? false) {
                          employeeMngmtController.onSubmit(
                              isEdit: true, id: widget.id);
                        } else {
                          employeeMngmtController.onSubmit(isEdit: false);
                        }
                      }
                    } else {
                      final password = employeeMngmtController
                          .passwordController.text
                          .trim();
                      final confirmPassword = employeeMngmtController
                          .confirmPasswordController.text
                          .trim();

                      if (password.isEmpty && confirmPassword.isEmpty) {
                        if (widget.isEdit ?? false) {
                          employeeMngmtController.onSubmit(
                              isEdit: true, id: widget.id);
                        } else {
                          employeeMngmtController.onSubmit(isEdit: false);
                        }
                      } else if (!employeeMngmtController.isMatched) {
                        if (confirmPassword.isEmpty) {
                          Get.snackbar('Confirm Password',
                              'Please enter confirm password',
                              backgroundColor: ColorTheme.red,
                              colorText: Colors.white);
                        } else {
                          Get.snackbar(
                              'Password Mismatch', 'Passwords do not match',
                              backgroundColor: ColorTheme.red,
                              colorText: Colors.white);
                        }
                      } else {
                        if (widget.isEdit ?? false) {
                          employeeMngmtController.onSubmit(
                              isEdit: true, id: widget.id);
                        } else {
                          employeeMngmtController.onSubmit(isEdit: false);
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: (widget.isEdit ?? false)
                            ? ColorTheme.green
                            : employeeMngmtController.isMatched
                                ? ColorTheme.green
                                : Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Center(
                      child: employeeMngmtController.isSubmitted
                          ? SpinKitFadingCircle(
                              color: Colors.white,
                              size: 25.0,
                            )
                          : Text(
                              (widget.isEdit ?? false) ? 'Edit' : 'Submit',
                              style: montserratSemiBold.copyWith(
                                  color: (widget.isEdit ?? false)
                                      ? ColorTheme.white
                                      : employeeMngmtController.isMatched
                                          ? ColorTheme.white
                                          : ColorTheme.borderGrey,
                                  fontSize: 15),
                            ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGeneralSection() {
    return GetBuilder<EmployeeManagementController>(
        builder: (employeeMngmtController) {
      print(
          'selectedRole selectedRole: ${employeeMngmtController.selectedRole}');
      print('role list : ${employeeMngmtController.roleList}');
      return Form(
        key: _generalKey,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionPanelList.radio(
            initialOpenPanelValue: 'role',
            expandIconColor: ColorTheme.green,
            dividerColor: ColorTheme.whiteE4,
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            children: [
              ExpansionPanelRadio(
                value: 'role',
                backgroundColor: Colors.white,
                // canTapOnHeader: true,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      'General Information',
                      style: montserratSemiBold.copyWith(
                          color: ColorTheme.grey1, fontSize: 14),
                    ),
                  );
                },
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: ColorTheme.grey1,
                    ),
                    SizedBox(height: 15),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField2<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Select Role",
                                labelStyle: TextStyle(color: Color(0xFF828282)),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                                errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    borderSide:
                                        BorderSide(color: Color(0xFFDCDCDC))),
                              ),
                              value:
                                  employeeMngmtController.selectedRole.isEmpty
                                      ? null
                                      : employeeMngmtController.selectedRole,
                              items: employeeMngmtController.roleList
                                  .toSet()
                                  .map((type) => DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: montserratMedium.copyWith(
                                            color: Color(0xFF828282),
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                employeeMngmtController.selectedRole =
                                    value ?? 'All Role';
                              },
                              buttonStyleData: ButtonStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                // height: 48,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Color(0xFFDCDCDC),
                                  ),
                                ),
                              ),
                              menuItemStyleData: MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          ),
                          // SizedBox(width: 8),
                          // Expanded(
                          //   child: Builder(
                          //     builder: (context) {
                          //       return SuperTooltip(
                          //         controller: _tooltipController,
                          //         popupDirection: TooltipDirection.down,
                          //         arrowLength: 10,
                          //         arrowBaseWidth: 20,
                          //         borderColor: Colors.transparent,
                          //         borderWidth: 1,
                          //         shadowColor: Colors.transparent,
                          //         shadowBlurRadius: 0,
                          //         shadowSpreadRadius: 0,
                          //         content: Material(
                          //           child: Container(
                          //             width: 300,
                          //             padding: const EdgeInsets.all(12),
                          //             child: Column(
                          //               mainAxisSize: MainAxisSize.min,
                          //               crossAxisAlignment: CrossAxisAlignment.start,
                          //               children: [
                          //                 Text(
                          //                   "Setting a Password",
                          //                   style: TextStyle(
                          //                     fontSize: 16,
                          //                     fontWeight: FontWeight.bold,
                          //                     color: Colors.blue,
                          //                   ),
                          //                 ),
                          //                 SizedBox(height: 8),
                          //                 _buildBulletPoint(
                          //                     "It is a long established fact that a reader will be distracted by the readable content."),
                          //                 _buildBulletPoint(
                          //                     "It is a long established fact that a reader will be distracted by the readable content."),
                          //                 _buildBulletPoint(
                          //                     "It is a long established fact that a reader will be distracted by the readable content."),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //         child: InkWell(
                          //           onTap: () {
                          //             setState(() {
                          //               _isTooltipVisible = !_isTooltipVisible;
                          //             });
                          //             _toggleTooltip();
                          //           },
                          //           child: Icon(
                          //             Icons.help_outline,
                          //             color: ColorTheme.borderGrey,
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Food For",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(color: Color(0xFF828282)),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide:
                                  BorderSide(color: Color(0xFFDCDCDC))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide:
                                  BorderSide(color: Color(0xFFDCDCDC))),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide:
                                  BorderSide(color: Color(0xFFDCDCDC))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide:
                                  BorderSide(color: Color(0xFFDCDCDC))),
                        ),
                        hint: Text(
                          'Select Food For',
                          style: montserratMedium.copyWith(
                            color: Color(0xFF828282),
                            fontSize: 12,
                          ),
                        ),
                        value: employeeMngmtController.foodForList.contains(
                                employeeMngmtController.selectedFoodFor)
                            ? employeeMngmtController.selectedFoodFor
                            : null,
                        items: employeeMngmtController.foodForList
                            .map((type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: montserratMedium.copyWith(
                                      color: Color(0xFF828282),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          employeeMngmtController.selectedFoodFor = value ?? '';
                        },
                        buttonStyleData: ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Color(0xFFDCDCDC),
                            ),
                          ),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF8EE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFF0D3A2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFE8A317), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The selected menu will be reloaded. Please make sure you select the correct menu before saving.',
                                style: montserratMedium.copyWith(
                                  color: Color(0xFFC4841D),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: employeeMngmtController.firstNameController,
                        focusNode: _firstNameFocus,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter first name'
                            : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        // readOnly: true,
                        style: montserratMedium.copyWith(
                          color: Color(0xFF828282),
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          labelText: "First Name",
                          hintText: 'First Name',
                          labelStyle: TextStyle(color: ColorTheme.grey1),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: employeeMngmtController.lastNameController,
                        // readOnly: true,
                        style: montserratMedium.copyWith(
                          color: Color(0xFF828282),
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          hintText: 'Last Name',
                          labelStyle: TextStyle(color: ColorTheme.grey1),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: employeeMngmtController.phoneController,
                        keyboardType: TextInputType.phone,
                        // readOnly: true,
                        style: montserratMedium.copyWith(
                          color: Color(0xFF828282),
                          fontSize: 13,
                        ),
                        onChanged: (_) {
                          // if (_generalKey.currentState?.validate() ?? false) {
                          //   print('Phone number is valid');
                          // } else {
                          //   print('Phone number is invalid');
                          // }
                        },
                        validator: (value) =>
                            employeeMngmtController.validatePhone(value ?? ""),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: "Phone",
                          hintText: '9632xxxxxx',
                          labelStyle: TextStyle(color: ColorTheme.grey1),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: employeeMngmtController.emailController,
                        // readOnly: true,
                        style: montserratMedium.copyWith(
                          color: Color(0xFF828282),
                          fontSize: 13,
                        ),
                        validator: (Value) =>
                            employeeMngmtController.validateEmail(Value ?? ""),
                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        onChanged: (_) {
                          // if (_generalKey.currentState?.validate() ?? false) {
                          //   print('Email is valid');
                          // } else {
                          //   print('Email is invalid');
                          // }
                        },
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          hintText: 'ex@gmail.com',
                          labelStyle: TextStyle(color: ColorTheme.grey1),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         flex: 3,
                    //         child: DropdownButtonFormField2<String>(
                    //           isExpanded: true,
                    //           decoration: InputDecoration(
                    //             labelText: "User Bill Role",
                    //             labelStyle: TextStyle(color: Color(0xFF828282)),
                    //             border: OutlineInputBorder(
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(30)),
                    //                 borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                    //             focusedBorder: OutlineInputBorder(
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(30)),
                    //                 borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                    //             errorBorder: OutlineInputBorder(
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(30)),
                    //                 borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                    //             enabledBorder: OutlineInputBorder(
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(30)),
                    //                 borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                    //           ),
                    //           value: employeeMngmtController.selectedBillUser.isEmpty
                    //               ? null
                    //               : employeeMngmtController.selectedBillUser,
                    //           items: employeeMngmtController.billUserList
                    //               .map((type) => DropdownMenuItem<String>(
                    //                     value: type,
                    //                     child: Text(
                    //                       type,
                    //                       style: montserratMedium.copyWith(
                    //                         color: Color(0xFF828282),
                    //                         fontSize: 12,
                    //                       ),
                    //                       overflow: TextOverflow.ellipsis,
                    //                       maxLines: 1,
                    //                     ),
                    //                   ))
                    //               .toList(),
                    //           onChanged: (value) {
                    //             employeeMngmtController.selectedBillUser =
                    //                 value ?? 'All User';
                    //           },
                    //           buttonStyleData: ButtonStyleData(
                    //             padding: EdgeInsets.symmetric(horizontal: 0),
                    //             // height: 48,
                    //             width: double.infinity,
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(30),
                    //             ),
                    //             overlayColor:
                    //                 WidgetStateProperty.all(Colors.transparent),
                    //           ),
                    //           dropdownStyleData: DropdownStyleData(
                    //             maxHeight: 250,
                    //             decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(14),
                    //               border: Border.all(
                    //                 color: Color(0xFFDCDCDC),
                    //               ),
                    //             ),
                    //           ),
                    //           menuItemStyleData: MenuItemStyleData(
                    //             height: 40,
                    //           ),
                    //         ),
                    //       ),
                    //       SizedBox(width: 8),
                    //       Expanded(
                    //         child: Builder(
                    //           builder: (context) {
                    //             return SuperTooltip(
                    //               controller: _tooltipController2,
                    //               popupDirection: TooltipDirection.up,
                    //               arrowLength: 10,
                    //               arrowBaseWidth: 20,
                    //               borderColor: Colors.transparent,
                    //               borderWidth: 1,
                    //               shadowColor: Colors.transparent,
                    //               shadowBlurRadius: 0,
                    //               shadowSpreadRadius: 0,
                    //               content: Material(
                    //                 child: Container(
                    //                   width: MediaQuery.of(context).size.width * 0.8,
                    //                   padding: const EdgeInsets.all(12),
                    //                   child: Column(
                    //                     mainAxisSize: MainAxisSize.min,
                    //                     crossAxisAlignment: CrossAxisAlignment.start,
                    //                     children: [
                    //                       Center(
                    //                         child: Text(
                    //                           "Setting a Password",
                    //                           style: TextStyle(
                    //                             fontSize: 16,
                    //                             fontWeight: FontWeight.bold,
                    //                             color: Colors.blue,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                       SizedBox(height: 8),
                    //                       _buildBulletPoint(
                    //                           "It is a long established fact that a reader will be distracted by the readable content."),
                    //                       _buildBulletPoint(
                    //                           "It is a long established fact that a reader will be distracted by the readable content."),
                    //                       _buildBulletPoint(
                    //                           "It is a long established fact that a reader will be distracted by the readable content."),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //               child: InkWell(
                    //                 onTap: () {
                    //                   setState(() {
                    //                     _isTooltipVisible2 = !_isTooltipVisible2;
                    //                   });
                    //                   _toggleTooltip2();
                    //                 },
                    //                 child: Icon(
                    //                   Icons.help_outline,
                    //                   color: ColorTheme.borderGrey,
                    //                 ),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: employeeMngmtController.passwordController,
                        onChanged: (_) {
                          employeeMngmtController.checkPassword();
                        },
                        // readOnly: true,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscurePassword,
                        obscuringCharacter: '*',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => employeeMngmtController
                            .validatePassword(value ?? '',
                                isEditing: widget.isEdit ?? false),
                        style: montserratMedium.copyWith(
                          color: employeeMngmtController.isMatched
                              ? ColorTheme.green
                              : Color(0xFF828282),
                          // color: Color(0xFF828282),
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: '8+ Characters Required',
                          labelStyle: TextStyle(color: ColorTheme.grey1),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: ColorTheme.borderGrey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          // suffixIcon: Builder(
                          //   builder: (context) {
                          //     return SuperTooltip(
                          //       controller: _tooltipController3,
                          //       popupDirection: TooltipDirection.up,
                          //       arrowLength: 10,
                          //       arrowBaseWidth: 20,
                          //       borderColor: Colors.transparent,
                          //       borderWidth: 1,
                          //       shadowColor: Colors.transparent,
                          //       shadowBlurRadius: 0,
                          //       shadowSpreadRadius: 0,
                          //       content: Material(
                          //         child: Container(
                          //           width: 300,
                          //           padding: const EdgeInsets.all(12),
                          //           child: Column(
                          //             mainAxisSize: MainAxisSize.min,
                          //             crossAxisAlignment: CrossAxisAlignment.start,
                          //             children: [
                          //               Text(
                          //                 "Setting a Password",
                          //                 style: TextStyle(
                          //                   fontSize: 16,
                          //                   fontWeight: FontWeight.bold,
                          //                   color: Colors.blue,
                          //                 ),
                          //               ),
                          //               SizedBox(height: 8),
                          //               _buildBulletPoint(
                          //                   "It is a long established fact that a reader will be distracted by the readable content."),
                          //               _buildBulletPoint(
                          //                   "It is a long established fact that a reader will be distracted by the readable content."),
                          //               _buildBulletPoint(
                          //                   "It is a long established fact that a reader will be distracted by the readable content."),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //       child: InkWell(
                          //         onTap: () {
                          //           setState(() {
                          //             _isTooltipVisible3 = !_isTooltipVisible3;
                          //           });
                          //           _toggleTooltip3();
                          //         },
                          //         child: Icon(
                          //           Icons.help_outline,
                          //           color: ColorTheme.borderGrey,
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller:
                            employeeMngmtController.confirmPasswordController,
                        onChanged: (_) {
                          employeeMngmtController.checkPassword();
                        },
                        keyboardType: TextInputType.visiblePassword,
                        // readOnly: true,
                        obscureText: _obscureConfirmPassword,
                        obscuringCharacter: '*',
                        style: montserratMedium.copyWith(
                          color: employeeMngmtController.isMatched
                              ? ColorTheme.green
                              : Color(0xFF828282),
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          hintText: '8+ Characters Required',
                          labelStyle: TextStyle(color: ColorTheme.grey1),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: ColorTheme.borderGrey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Color(0xFFDCDCDC))),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Widget _buildAccountSection() {
  //   return GetBuilder<EmployeeManagementController>(
  //       builder: (employeeMngmtController) {
  //     return Form(
  //       key: _accountKey,
  //       child: Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.all(0),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SizedBox(height: 15),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: Text(
  //                 'Account Information',
  //                 style: montserratBold.copyWith(
  //                     color: ColorTheme.grey1, fontSize: 14),
  //               ),
  //             ),
  //             SizedBox(height: 10),
  //             Divider(
  //               color: ColorTheme.grey1,
  //             ),
  //             SizedBox(height: 15),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: TextFormField(
  //                 controller: employeeMngmtController.passwordController,

  //                 onChanged: (_) {
  //                   // setState(() {
  //                   if (_accountKey.currentState?.validate() ?? false) {
  //                     print('Password is valid');
  //                   } else {
  //                     print('Password is invalid');
  //                   }
  //                   // employeeMngmtController.checkPassword();
  //                   // });
  //                 },

  //                 // readOnly: true,
  //                 keyboardType: TextInputType.visiblePassword,
  //                 obscureText: true,
  //                 obscuringCharacter: '*',
  //                 validator: (value) =>
  //                     employeeMngmtController.validatePassword(value ?? ''),
  //                 style: montserratMedium.copyWith(
  //                   color: employeeMngmtController.isMatched
  //                       ? ColorTheme.green
  //                       : Color(0xFF828282),
  //                   // color: Color(0xFF828282),
  //                   fontSize: 13,
  //                 ),
  //                 decoration: InputDecoration(
  //                   labelText: "Password",
  //                   hintText: '8+ Characters Required',
  //                   labelStyle: TextStyle(color: ColorTheme.grey1),
  //                   // suffixIcon: Builder(
  //                   //   builder: (context) {
  //                   //     return SuperTooltip(
  //                   //       controller: _tooltipController3,
  //                   //       popupDirection: TooltipDirection.up,
  //                   //       arrowLength: 10,
  //                   //       arrowBaseWidth: 20,
  //                   //       borderColor: Colors.transparent,
  //                   //       borderWidth: 1,
  //                   //       shadowColor: Colors.transparent,
  //                   //       shadowBlurRadius: 0,
  //                   //       shadowSpreadRadius: 0,
  //                   //       content: Material(
  //                   //         child: Container(
  //                   //           width: 300,
  //                   //           padding: const EdgeInsets.all(12),
  //                   //           child: Column(
  //                   //             mainAxisSize: MainAxisSize.min,
  //                   //             crossAxisAlignment: CrossAxisAlignment.start,
  //                   //             children: [
  //                   //               Text(
  //                   //                 "Setting a Password",
  //                   //                 style: TextStyle(
  //                   //                   fontSize: 16,
  //                   //                   fontWeight: FontWeight.bold,
  //                   //                   color: Colors.blue,
  //                   //                 ),
  //                   //               ),
  //                   //               SizedBox(height: 8),
  //                   //               _buildBulletPoint(
  //                   //                   "It is a long established fact that a reader will be distracted by the readable content."),
  //                   //               _buildBulletPoint(
  //                   //                   "It is a long established fact that a reader will be distracted by the readable content."),
  //                   //               _buildBulletPoint(
  //                   //                   "It is a long established fact that a reader will be distracted by the readable content."),
  //                   //             ],
  //                   //           ),
  //                   //         ),
  //                   //       ),
  //                   //       child: InkWell(
  //                   //         onTap: () {
  //                   //           setState(() {
  //                   //             _isTooltipVisible3 = !_isTooltipVisible3;
  //                   //           });
  //                   //           _toggleTooltip3();
  //                   //         },
  //                   //         child: Icon(
  //                   //           Icons.help_outline,
  //                   //           color: ColorTheme.borderGrey,
  //                   //         ),
  //                   //       ),
  //                   //     );
  //                   //   },
  //                   // ),

  //                   border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                   focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                   errorBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                   enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(
  //               height: 20,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: TextField(
  //                 controller: employeeMngmtController.confirmPasswordController,

  //                 onChanged: (_) {
  //                   // setState(() {
  //                   employeeMngmtController.checkPassword();
  //                   // });
  //                 },
  //                 keyboardType: TextInputType.visiblePassword,
  //                 // readOnly: true,
  //                 style: montserratMedium.copyWith(
  //                   color: employeeMngmtController.isMatched
  //                       ? ColorTheme.green
  //                       : Color(0xFF828282),
  //                   fontSize: 13,
  //                 ),
  //                 decoration: InputDecoration(
  //                   labelText: "Confirm Password",
  //                   hintText: '8+ Characters Required',
  //                   labelStyle: TextStyle(color: ColorTheme.grey1),
  //                   border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                   focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                   errorBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                   enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(30)),
  //                       borderSide: BorderSide(color: Color(0xFFDCDCDC))),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 15),
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  // }
}
