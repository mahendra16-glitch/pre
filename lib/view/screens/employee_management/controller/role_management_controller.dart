
import 'package:mygenie_restaurant/data/api/api_checker.dart';
// import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/response/role_management_list_model.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/response/get_all_role_types_modules_model.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/repo/role_management_repo.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoleManagementController extends GetxController implements GetxService {
  final RoleManagementRepo roleManagementRepo;
  RoleManagementController({required this.roleManagementRepo});

  Map<String, dynamic> roleIdMap = {};
  Map<String, dynamic> roleMasterIdMap = {};

  List<String> roleList = [];
  List<Role> roleMngmtList = [];
  List<Role> systemRoleMngmtList = [];
  List<Role> filteredRoleMngmtList = [];
  List<String> roleTypeList = [];
  List<RoleType> selectedRoleTypeList = [];
  List<RoleModule> reportModuleList = [];
  List<RoleModule> defaultModuleList = [];
  List<RoleModule> frontendModuleList = [];
  List<RoleModule> backendModuleList = [];
  List<String> selectedReportModules = [];
  List<String> selectedDefaultModules = [];
  List<String> selectedFrontendModules = [];
  List<String> selectedBackendModules = [];

  String selectedRole = 'All Role';

  int? status;

  TextEditingController roleNameController = TextEditingController();

  bool isLoading = false;
  bool isSubmitting = false;
  bool isReseting = false;

  List<bool> isReportCheckList = [];
  List<bool> isDefaultCheckList = [];
  List<bool> isFrontendCheckList = [];
  List<bool> isBackendCheckList = [];

  TextEditingController roleSearchController = TextEditingController();

  List<String> coreModules = [];

  List<dynamic> masterRoles = [];
  Map<String, String> nameToMapRole = {};

  Future<void> onInitCall(
      {required bool isEdit, required Map<String, dynamic> roleDate}) async {
    await getRoleMngmtList();
    await getAllRole();
    if (isEdit) {
      final data = roleDate;
      roleNameController.text = data['name'];
      selectedRole = data['role_master_name'] ?? '';
      print('role_master_name role:${data['role_master_name']}');
      status = data['status'] ?? 1;
      final List<String> allModules = List<String>.from(data['modules']);
      selectedFrontendModules = allModules
          .where((module) => frontendModuleList.any((roleModule) =>
              roleModule.rolePassValue.toLowerCase() == module.toLowerCase()))
          .toList();
      setFrontendChecklistFromSelected();
      selectedBackendModules = allModules
          .where((module) => backendModuleList.any((roleModule) =>
              roleModule.rolePassValue.toLowerCase() == module.toLowerCase()))
          .toList();
      setBackendChecklistFromSelected();
      selectedReportModules = allModules
          .where((module) => reportModuleList.any((roleModule) =>
              roleModule.rolePassValue.toLowerCase() == module.toLowerCase()))
          .toList();
      setReportChecklistFromSelected();
      selectedDefaultModules = allModules
          .where((module) => defaultModuleList.any((roleModule) =>
              roleModule.rolePassValue.toLowerCase() == module.toLowerCase()))
          .toList();
      setDefaultChecklistFromSelected();
    } else {
      roleNameController.clear();
      selectedRole = 'All Role';
      selectedBackendModules.clear();
      selectedFrontendModules.clear();
      selectedReportModules.clear();
      selectedDefaultModules.clear();

      isReportCheckList = List.generate(reportModuleList.length, (_) => false);
      isDefaultCheckList =
          List.generate(defaultModuleList.length, (_) => false);
      isFrontendCheckList =
          List.generate(frontendModuleList.length, (_) => false);
      isBackendCheckList =
          List.generate(backendModuleList.length, (_) => false);
    }
    setCoreModules();
    update();
  }

  void onRoleTypeChanged(String? value) {
    selectedRole = value ?? 'All Role';
    selectedBackendModules.clear();
    selectedFrontendModules.clear();
    selectedReportModules.clear();
    selectedDefaultModules.clear();
    isReportCheckList = List.generate(reportModuleList.length, (_) => false);
    isDefaultCheckList = List.generate(defaultModuleList.length, (_) => false);
    isFrontendCheckList = List.generate(frontendModuleList.length, (_) => false);
    isBackendCheckList = List.generate(backendModuleList.length, (_) => false);
    setCoreModules();
    update();
  }

  void setCoreModules() {
    coreModules.clear();
    if (selectedRole != 'All Role') {
      var selectedMaster = masterRoles.firstWhere(
        (role) => role['name'] == selectedRole,
        orElse: () => {},
      );
      if (selectedMaster.isNotEmpty) {
        coreModules = (selectedMaster['default_modules'] as List? ?? [])
            .map((e) => e.toString().toLowerCase())
            .toList();
      }
    }
    setCoreInChecklists();
    onFrontendModuleSelected();
    onBackendModuleSelected();
    onReportModuleSelected();
    onDefaultModuleSelected();
    update();
  }

  void setCoreInChecklists() {
    for (int i = 0; i < frontendModuleList.length; i++) {
      if (coreModules
          .contains(frontendModuleList[i].rolePassValue.toLowerCase())) {
        isFrontendCheckList[i] = true;
      }
    }
    for (int i = 0; i < backendModuleList.length; i++) {
      if (coreModules
          .contains(backendModuleList[i].rolePassValue.toLowerCase())) {
        isBackendCheckList[i] = true;
      }
    }
    for (int i = 0; i < reportModuleList.length; i++) {
      if (coreModules
          .contains(reportModuleList[i].rolePassValue.toLowerCase())) {
        isReportCheckList[i] = true;
      }
    }
    for (int i = 0; i < defaultModuleList.length; i++) {
      if (coreModules
          .contains(defaultModuleList[i].rolePassValue.toLowerCase())) {
        isDefaultCheckList[i] = true;
      }
    }
  }

  Future<void> getRoleMngmtList() async {
    isLoading = true;
    update();
    Response response = await roleManagementRepo.getRoleMnmgtList();
    if (response.statusCode == 200) {
      final data = RoleMnmgtListodel.fromJson(response.body);
      roleMngmtList = data.roles;
      systemRoleMngmtList =
          data.roles.where((role) => role.isSystemRole == true).toList();
      filterRoles();
      roleList =
          ['All Role'] + roleMngmtList.map((role) => role.name ?? '').toList();
      roleIdMap = Map.fromIterable(
        roleMngmtList,
        key: (role) => role.name ?? '',
        value: (role) => role.id,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
  }

  Future<void> getAllRole() async {
    isLoading = true;
    update();
    Response response = await roleManagementRepo.getAllRole();

    if (response.statusCode == 200) {
      final data = RoleDataModel.fromJson(response.body);
      await getRoleMaster();
      // roleTypeList = ['All Role'] +
      //     data.roleTypes.map((roleType) => roleType.name).toSet().toList();
      reportModuleList = data.roleModules.reportModules ?? [];
      // defaultModuleList = data.roleModules.defaultModules ?? [];
      frontendModuleList = data.roleModules.frontendModules ?? [];
      backendModuleList = data.roleModules.backendModules ?? [];
      isReportCheckList =
          List.generate(reportModuleList.length, (index) => false);
      isDefaultCheckList =
          List.generate(defaultModuleList.length, (index) => false);
      isBackendCheckList =
          List.generate(backendModuleList.length, (index) => false);
      isFrontendCheckList =
          List.generate(frontendModuleList.length, (index) => false);
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
  }

  Future<void> getRoleMaster() async {
    isLoading = true;
    update();
    Response response = await roleManagementRepo.getRoleMaster();

    if (response.statusCode == 200) {
      final data = response.body;
      masterRoles = data['roles'];
      nameToMapRole = Map.fromIterable(
        masterRoles,
        key: (role) => role['name'],
        value: (role) => role['map_role'],
      );
      roleMasterIdMap = Map.fromIterable(
        masterRoles,
        key: (role) => role['name'] ?? '',
        value: (role) => role['id'],
      );
      roleTypeList = ['All Role'] +
          (data['roles'])
              .map((masterRole) => masterRole['name'].toString())
              .toSet()
              .toList()
              .cast<String>();
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
  }

  Future<void> addRoleMngmt(Map<String, dynamic> data) async {
    isLoading = true;
    isSubmitting = true;
    update();
    Response response = await roleManagementRepo.addRoleMngmt(data);
    if (response.statusCode == 201) {
      Get.back();
      await getRoleMngmtList();
      update();
      Get.snackbar(
        "Success",
        "New Role Added Successfully",
        colorText: Colors.white,
        backgroundColor: ColorTheme.green,
      );
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    isSubmitting = false;
    update();
  }

  Future<void> updateRoleMngmt(int id, Map<String, dynamic> data) async {
    isLoading = true;
    isSubmitting = true;
    update();
    // print('This id is going to change :$id');
    Response response = await roleManagementRepo.updaRoleMngmt(id, data);
    if (response.statusCode == 200) {
      Get.back();
      await getRoleMngmtList();
      update();
      Get.snackbar('Success', 'Role (id : $id) Updated Successfully',
          backgroundColor: ColorTheme.green, colorText: Colors.white);
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    isSubmitting = false;
    update();
  }

  Future<void> updateStatus(int id, Map<String, dynamic> data) async {
    isLoading = true;
    update();
    Response response = await roleManagementRepo.updateStatus(id, data);
    if (response.statusCode == 200) {
      await getRoleMngmtList();
      update();
      Get.snackbar('Success', 'Role (id : $id) Updated Successfully',
          backgroundColor: ColorTheme.green, colorText: Colors.white);
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
  }

  void filterRoles() {
    final query = roleSearchController.text.toLowerCase();
    if (query.isEmpty) {
      final customRoleList =
          roleMngmtList.where((role) => role.isSystemRole == false).toList();
      filteredRoleMngmtList = customRoleList;
    } else {
      final customRoleList =
          roleMngmtList.where((role) => role.isSystemRole == false).toList();

      filteredRoleMngmtList = customRoleList.where((role) {
        final name = (role.name ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    }
  }

  onSubmit({required bool isEdit, int? id}) {
    if (isEdit) {
      roleSubmit(isEdit: isEdit, id: id);
    } else {
      roleSubmit(isEdit: isEdit);
    }
  }

  roleSubmit({required bool isEdit, int? id}) {
    try {
      String mapRole = nameToMapRole[selectedRole] ?? '';
      int roleMasterId = roleMasterIdMap[selectedRole] ?? '';

      final data = {
        "name": roleNameController.text.trim(),
        // "parent_role": selectedRole,
        "modules": [mapRole] + selectedFrontendModules +
            selectedBackendModules +
            selectedReportModules +
            selectedDefaultModules,
        "role_type": [mapRole],
        "role_master_id": roleMasterId,
        if (isEdit) "status": status,
        // "printmodules": ["bill", "order"]
        "printmodules":
            null //printmodules passing null cuz we didn't use defaultprintingmodules
      };
      if (isEdit) {
        updateRoleMngmt(id!, data);
      } else {
        addRoleMngmt(data);
      }
    } catch (e) {
      print('Failed to submit :$e');
    }
  }

  void onReportModuleSelected() {
    selectedReportModules.clear();
    for (int i = 0; i < reportModuleList.length; i++) {
      bool isCore =
          coreModules.contains(reportModuleList[i].rolePassValue.toLowerCase());
      bool shouldSelect = isReportCheckList[i] || isCore;
      if (shouldSelect) {
        selectedReportModules
            // .add(reportModuleList[i].rolePassValue.toLowerCase());
            .add(reportModuleList[i].rolePassValue);
      }
      if (isCore) {
        isReportCheckList[i] = true;
      }
    }
    update();
    print("Selected Report Modules: $selectedReportModules");
  }

  void onDefaultModuleSelected() {
    selectedDefaultModules.clear();
    for (int i = 0; i < defaultModuleList.length; i++) {
      bool isCore = coreModules
          .contains(defaultModuleList[i].rolePassValue.toLowerCase());
      bool shouldSelect = isDefaultCheckList[i] || isCore;
      if (shouldSelect) {
        selectedDefaultModules
            // .add(defaultModuleList[i].rolePassValue.toLowerCase());
            .add(defaultModuleList[i].rolePassValue);
      }
      if (isCore) {
        isDefaultCheckList[i] = true;
      }
    }
    update();
    print("Selected Default Modules: $selectedDefaultModules");
  }

  void onFrontendModuleSelected() {
    selectedFrontendModules.clear();
    for (int i = 0; i < frontendModuleList.length; i++) {
      bool isCore = coreModules
          .contains(frontendModuleList[i].rolePassValue.toLowerCase());
      bool shouldSelect = isFrontendCheckList[i] || isCore;
      if (shouldSelect) {
        selectedFrontendModules
            // .add(frontendModuleList[i].rolePassValue.toLowerCase());
            .add(frontendModuleList[i].rolePassValue);

      }
      if (isCore) {
        isFrontendCheckList[i] = true;
      }
    }
    update();
    print("Selected Frontend Modules: $selectedFrontendModules");
  }

  void onBackendModuleSelected() {
    selectedBackendModules.clear();
    for (int i = 0; i < backendModuleList.length; i++) {
      bool isCore = coreModules
          .contains(backendModuleList[i].rolePassValue.toLowerCase());
      bool shouldSelect = isBackendCheckList[i] || isCore;
      if (shouldSelect) {
        selectedBackendModules
            // .add(backendModuleList[i].rolePassValue.toLowerCase());
            .add(backendModuleList[i].rolePassValue);
      }
      if (isCore) {
        isBackendCheckList[i] = true;
      }
    }
    update();
    print("Selected Backend Modules: $selectedBackendModules");
  }

  void setFrontendChecklistFromSelected() {
    isFrontendCheckList = List.generate(frontendModuleList.length, (index) {
      final name = frontendModuleList[index].rolePassValue.toLowerCase();
      // return selectedFrontendModules.contains(name);
      return selectedFrontendModules.any((e) => e.toLowerCase() == name);
    });
    // selectedFrontendModules.clear();
    update();
  }

  void setBackendChecklistFromSelected() {
    isBackendCheckList = List.generate(backendModuleList.length, (index) {
      final name = backendModuleList[index].rolePassValue.toLowerCase();
      // return selectedBackendModules.contains(name);
      return selectedBackendModules.any((e) => e.toLowerCase() == name);
    });
    // selectedBackendModules.clear();
    update();
  }

  void setReportChecklistFromSelected() {
    isReportCheckList = List.generate(reportModuleList.length, (index) {
      final name = reportModuleList[index].rolePassValue.toLowerCase();
      // return selectedReportModules.contains(name);
      return selectedReportModules.any((e) => e.toLowerCase() == name);
    });
    // selectedReportModules.clear();
    update();
  }

  void setDefaultChecklistFromSelected() {
    isDefaultCheckList = List.generate(defaultModuleList.length, (index) {
      final name = defaultModuleList[index].rolePassValue.toLowerCase();
      // return selectedDefaultModules.contains(name);
      return selectedDefaultModules.any((e) => e.toLowerCase() == name);
    });
    // selectedDefaultModules.clear();
    update();
  }

  void resetRoleManagement() async {
    print('Resetting role management');
    isReseting = true;
    update();
    await Future.delayed(Duration(seconds: 1));
    roleNameController.clear();
    selectedRole = 'All Role';
    selectedBackendModules.clear();
    selectedDefaultModules.clear();
    selectedFrontendModules.clear();
    selectedReportModules.clear();
    isReportCheckList =
        List.generate(reportModuleList.length, (index) => false);
    isDefaultCheckList =
        List.generate(defaultModuleList.length, (index) => false);
    isFrontendCheckList =
        List.generate(frontendModuleList.length, (index) => false);
    isBackendCheckList =
        List.generate(backendModuleList.length, (index) => false);
    isReseting = false;
    setCoreModules();
    update();
  }
}