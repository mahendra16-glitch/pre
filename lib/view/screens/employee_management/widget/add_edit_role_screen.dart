import 'package:mygenie_restaurant/view/screens/employee_management/controller/role_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/response/get_all_role_types_modules_model.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/widget/module_permission_widget.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddEditRoleScreen extends StatefulWidget {
  final Key? key;
  final bool isEdit;
  final Map<String, dynamic>? roleData;
  final int? id;
  const AddEditRoleScreen(
      {this.key, this.id, required this.isEdit, this.roleData})
      : super(key: key);

  @override
  State<AddEditRoleScreen> createState() => _AddEditRoleScreenState();
}

class _AddEditRoleScreenState extends State<AddEditRoleScreen> {
  bool _isTooltipVisible = false;
  // final bool _isTooltipVisible2 = false;
  bool _isTooltipVisible3 = false;

  SuperTooltipController? _tooltipController;
  SuperTooltipController? _tooltipController2;
  SuperTooltipController? _tooltipController3;

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  bool isMatched = false;

  @override
  void initState() {
    super.initState();
    _tooltipController = SuperTooltipController();
    _tooltipController2 = SuperTooltipController();
    _tooltipController3 = SuperTooltipController();

    final roleManagementController = Get.find<RoleManagementController>();
    Future.delayed(Duration.zero, () {
      roleManagementController.onInitCall(
          isEdit: widget.isEdit, roleDate: widget.roleData ?? {});
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   roleManagementController.onInitCall(
    //       isEdit: widget.isEdit, roleDate: widget.roleData ?? {});
    // });
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

  // void _toggleTooltip2() {
  //   setState(() {
  //     // _isTooltipVisible = !_isTooltipVisible;
  //     if (_isTooltipVisible2) {
  //       _tooltipController2!.showTooltip();
  //     } else {
  //       _tooltipController2!.hideTooltip();
  //     }
  //   });
  // }

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleManagementController>(
        builder: (roleManagementController) {
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
              widget.isEdit ? 'Edit Role' : 'Add New Role',
              style: montserratSemiBold.copyWith(
                  color: ColorTheme.green, fontSize: 18),
            ),
            centerTitle: false,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
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
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          'Role Details',
                          style: montserratMedium.copyWith(
                              color: ColorTheme.grey1, fontSize: 14),
                        ),
                      );
                    },
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Divider(color: ColorTheme.grey1),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller:
                                roleManagementController.roleNameController,
                            style: montserratMedium.copyWith(
                              color: Color(0xFF828282),
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              labelText: "Role Name",
                              hintText: 'Ex : Store',
                              labelStyle: TextStyle(color: ColorTheme.grey1),
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
                          ),
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField2<String>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: "Role Type",
                                    labelStyle:
                                        TextStyle(color: Color(0xFF828282)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        borderSide: BorderSide(
                                            color: Color(0xFFDCDCDC))),
                                  ),
                                  value: roleManagementController.roleTypeList
                                          .contains(roleManagementController
                                              .selectedRole)
                                      ? roleManagementController.selectedRole
                                      : null,
                                  items: roleManagementController.roleTypeList
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
                                    // roleManagementController
                                    //     .resetRoleManagement();
                                    roleManagementController
                                        .onRoleTypeChanged(value);
                                    roleManagementController.update();
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
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
                            ],
                          ),
                        ),
                        if (roleManagementController.selectedRole !=
                                'All Role' &&
                            roleManagementController.coreModules.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 15.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                  'Core Modules: ${roleManagementController.coreModules.join(', ')}',
                                  maxLines: 3,
                                  style: montserratMedium.copyWith(
                                      fontSize: 14, color: ColorTheme.grey1)),
                            ),
                          ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                  ExpansionPanelRadio(
                    value: 'frontend',
                    canTapOnHeader: true,
                    backgroundColor: Colors.white,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          'Frontend Module Permission',
                          style: montserratMedium.copyWith(
                              color: ColorTheme.grey1, fontSize: 14),
                        ),
                      );
                    },
                    body: modulePermissionWidget(
                      moduleName: 'Frontend',
                      moduleList: roleManagementController.frontendModuleList,
                      isModuleCheckList:
                          roleManagementController.isFrontendCheckList,
                      onModuleSelected:
                          roleManagementController.onFrontendModuleSelected,
                      coreModuleSet:
                          roleManagementController.coreModules.toSet(),
                    ),
                  ),
                  ExpansionPanelRadio(
                    value: 'backend',
                    canTapOnHeader: true,
                    backgroundColor: Colors.white,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          'Backend Module Permission',
                          style: montserratMedium.copyWith(
                              color: ColorTheme.grey1, fontSize: 14),
                        ),
                      );
                    },
                    body: modulePermissionWidget(
                      moduleName: 'Backend',
                      moduleList: roleManagementController.backendModuleList,
                      isModuleCheckList:
                          roleManagementController.isBackendCheckList,
                      onModuleSelected:
                          roleManagementController.onBackendModuleSelected,
                      coreModuleSet:
                          roleManagementController.coreModules.toSet(),
                    ),
                  ),
                  ExpansionPanelRadio(
                    value: 'report',
                    canTapOnHeader: true,
                    backgroundColor: Colors.white,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          'Report Module Permission',
                          style: montserratMedium.copyWith(
                              color: ColorTheme.grey1, fontSize: 14),
                        ),
                      );
                    },
                    body: modulePermissionWidget(
                      moduleName: 'Report',
                      moduleList: roleManagementController.reportModuleList,
                      isModuleCheckList:
                          roleManagementController.isReportCheckList,
                      onModuleSelected:
                          roleManagementController.onReportModuleSelected,
                      coreModuleSet:
                          roleManagementController.coreModules.toSet(),
                    ),
                  ),
                  // ExpansionPanelRadio(
                  //   value: 'default',
                  //   canTapOnHeader: true,
                  //   backgroundColor: Colors.white,
                  //   headerBuilder: (BuildContext context, bool isExpanded) {
                  //     return ListTile(
                  //       title: Text(
                  //         'Default Module Permission',
                  //         style: montserratMedium.copyWith(
                  //             color: ColorTheme.grey1, fontSize: 14),
                  //       ),
                  //     );
                  //   },
                  //   body: modulePermissionWidget(
                  //     moduleName: 'Default',
                  //     moduleList: roleManagementController.defaultModuleList,
                  //     isModuleCheckList:
                  //         roleManagementController.isDefaultCheckList,
                  //     onModuleSelected:
                  //         roleManagementController.onDefaultModuleSelected,
                  //     coreModuleSet:
                  //         roleManagementController.coreModules.toSet(),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              height: 80,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
              decoration: BoxDecoration(color: ColorTheme.white),
              child: Row(
                children: [
                  Expanded(
                      child: InkWell(
                    onTap: () => roleManagementController.resetRoleManagement(),
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: Color(0xFFEFEFEF),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: roleManagementController.isReseting
                            ? SpinKitFadingCircle(
                                color: ColorTheme.borderGrey,
                                size: 25.0,
                              )
                            : Center(
                                child: Text(
                                  'Reset',
                                  style: poppinsBold.copyWith(
                                      color: ColorTheme.borderGrey,
                                      fontSize: 15),
                                ),
                              )),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      roleManagementController.roleNameController.text.isEmpty
                          ? Get.snackbar(
                              'Check Again',
                              "Please Fill The Role Name",
                              colorText: Colors.white,
                              backgroundColor: ColorTheme.red,
                            )
                          : roleManagementController.selectedRole == 'All Role'
                              ? Get.snackbar(
                                  'Check Again',
                                  "Please Select Roletype",
                                  colorText: Colors.white,
                                  backgroundColor: ColorTheme.red,
                                )
                              : (roleManagementController
                                          .selectedFrontendModules.isEmpty &&
                                      roleManagementController
                                          .selectedBackendModules.isEmpty &&
                                      roleManagementController
                                          .selectedDefaultModules.isEmpty &&
                                      roleManagementController
                                          .selectedReportModules.isEmpty)
                                  ? Get.snackbar(
                                      'Check Again',
                                      "Please Select At least One Module",
                                      colorText: Colors.white,
                                      backgroundColor: ColorTheme.red,
                                    )
                                  : widget.isEdit
                                      ? roleManagementController.onSubmit(
                                          isEdit: true, id: widget.id)
                                      : roleManagementController.onSubmit(
                                          isEdit: false);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: (roleManagementController.selectedRole !=
                                      'All Role' &&
                                  roleManagementController
                                      .roleNameController.text.isNotEmpty)
                              ? ColorTheme.green
                              : Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: !roleManagementController.isSubmitting
                          ? Center(
                              child: Text(
                                widget.isEdit ? 'Edit' : "Submit",
                                style: poppinsBold.copyWith(
                                    color:
                                        roleManagementController.selectedRole !=
                                                'All Role'
                                            ? ColorTheme.white
                                            : ColorTheme.borderGrey,
                                    fontSize: 15),
                              ),
                            )
                          : SpinKitFadingCircle(
                              color: Colors.white,
                              size: 20.0,
                            ),
                    ),
                  )),
                ],
              ),
            ),
          ));
    });
  }
}
