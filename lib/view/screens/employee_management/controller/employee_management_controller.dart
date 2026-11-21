// import 'dart:math';
import 'dart:convert';

import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/response/get_employee_management_list_model.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/repo/employee_management_repo.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeeManagementController extends GetxController
    implements GetxService {
  final EmployeeManagementRepo employeeManagementRepo;
  EmployeeManagementController({required this.employeeManagementRepo});

  List<Employee>? employeeMnmgtList = [];
  List<Employee>? filteredEmployeeMnmgtList = [];
  List<String> roleList = [];
  List<String> foodForList = [];
  Map<String, dynamic> roleIdMap = {};
  List<String> billUserList = ['No', 'Yes'];

  bool isLoading = false;
  bool isMatched = false;
  bool isSubmitted = false;
  bool isReset = false;

  String selectedRole = 'All Role';
  String selectedBillUser = 'No';
  String selectedFoodFor = '';
  String pendingFoodFor = '';

  TextEditingController employeeSearchController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  addEditInitCall(
      {required isEdit, required Map<String, dynamic> employeeData}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getRolelist();
      getFoodForList();
    });

    if (isEdit) {
      final data = employeeData;
      firstNameController.text = data['f_name'] ?? '';
      lastNameController.text = data['l_name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      emailController.text = data['email'] ?? '';
      passwordController.clear();
      confirmPasswordController.clear();
      selectedRole = data['role']?['name'] ?? 'All Role';
      selectedBillUser = data['bill_user_view'] ?? 'No';
      pendingFoodFor = data['food_for']?.toString() ?? '';
      selectedFoodFor = '';
    } else {
      firstNameController.clear();
      lastNameController.clear();
      phoneController.clear();
      phoneController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      selectedRole = 'All Role';
      selectedBillUser = 'No';
      pendingFoodFor = '';
      selectedFoodFor = '';
    }
  }

  Future<void> getEmployeeMnmgtList() async {
    isLoading = true;
    update();
    Response response = await employeeManagementRepo.getEmployeeMngmtList();
    if (response.statusCode == 200) {
      final data = GetEmployeeManagementListModel.fromJson(response.body);
      employeeMnmgtList = data.employees;
      filterEmployees();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      ApiChecker.checkApi(response);
    } else {
      Get.snackbar(response.body['errors'][0]['code'],
          response.body['errors'][0]['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading = false;
    update();
  }

  Future<void> getRolelist() async {
    try {
      isLoading = true;
      update();

      Response response = await employeeManagementRepo.getRoleList();

      if (response.statusCode == 200) {
        final data = response.body;
        final roles = data['roles'];

        if (roles is List) {
          print("Role List : $roles");

          roleList = ['All Role'] +
              roles
                  .map((role) => role['name'])
                  .whereType<String>() // removes nulls
                  .toSet()
                  .toList();

          for (var role in roles) {
            final name = role['name'];
            final id = role['id'];
            if (name != null && id != null && !roleIdMap.containsKey(name)) {
              roleIdMap[name] = id;
            }
          }

          print("Final Role List: $roleList");
          print("Final RoleId Map: $roleIdMap");
        } else {
          print("roles is not a list!");
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        ApiChecker.checkApi(response);
      } else {
        Get.snackbar(response.body['errors'][0]['code'],
            response.body['errors'][0]['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching role list : $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getFoodForList() async {
    try {
      Response response = await employeeManagementRepo.getMenuMasterLists();

      if (response.statusCode == 200) {
        final menus = response.body['menus'];
        foodForList = [];
        if (menus is List) {
          for (final menu in menus) {
            final name = menu['menu_name']?.toString() ?? '';
            if (name.isNotEmpty &&
                name != 'Aggregator' &&
                !foodForList.contains(name)) {
              foodForList.add(name);
            }
          }
        }
        if (selectedFoodFor.isEmpty &&
            pendingFoodFor.isNotEmpty &&
            foodForList.contains(pendingFoodFor)) {
          selectedFoodFor = pendingFoodFor;
        } else if (selectedFoodFor.isNotEmpty &&
            !foodForList.contains(selectedFoodFor)) {
          selectedFoodFor = '';
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        ApiChecker.checkApi(response);
      } else {
        Get.snackbar(response.body['errors'][0]['code'],
            response.body['errors'][0]['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching food for list : $e');
    } finally {
      update();
    }
  }

  Future<void> reloadProductsAfterEmployeeSave() async {
    try {
      Response response = await employeeManagementRepo.getProductList();
      if (response.statusCode == 200) {
        final products =
            ProductModel.fromJson(response.body).products ?? <Product>[];
        Get.find<RestaurantController>().getProductListFromLocal(products);
        Get.find<AuthController>().saveProductList(
          jsonEncode(products.map((product) => product.toJson()).toList()),
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print('Error reloading product list : $e');
    }
  }

  Future<void> addEmployeeMnmgtList({Map<String, dynamic>? data}) async {
    isLoading = true;
    isSubmitted = true;
    update();
    Response response = await employeeManagementRepo.addEmployeeMnmgtList(data);
    if (response.statusCode == 201) {
      await reloadProductsAfterEmployeeSave();
      Get.back();
      await getEmployeeMnmgtList();
      update();
      Get.snackbar(
        "Success",
        "New Employee Added Successfully",
        colorText: Colors.white,
        backgroundColor: ColorTheme.green,
      );
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 302) {
      ApiChecker.checkApi(response);
    } else {
      Get.snackbar(response.body['errors'][0]['code'],
          response.body['errors'][0]['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading = false;
    isSubmitted = false;
    update();
  }

  Future<void> updateEmployeeMnmgtList(
      {int? id, Map<String, dynamic>? data}) async {
    isLoading = true;
    isSubmitted = true;
    update();
    Response response =
        await employeeManagementRepo.updateEmployeeMngmtList(id, data);
    if (response.statusCode == 200) {
      await reloadProductsAfterEmployeeSave();
      Get.back();
      await getEmployeeMnmgtList();
      update();
      Get.snackbar('update ', 'Employee (id : $id) updated successfully',
          backgroundColor: ColorTheme.green, colorText: Colors.white);
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 302) {
      ApiChecker.checkApi(response);
    } else {
      Get.snackbar(response.body['errors'][0]['code'],
          response.body['errors'][0]['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading = false;
    isSubmitted = false;
    update();
  }

  Future<void> deleteEmployeeMnmgtList(int? id) async {
    try {
      isLoading = true;
      update();
      Response response =
          await employeeManagementRepo.deleteEmployeeMngmtList(id!);
      if (response.statusCode == 200) {
        // Get.back();
        await getEmployeeMnmgtList();
        update();
        Get.snackbar("Delete", 'Employee(id : $id) deleted successfully',
            colorText: Colors.white, backgroundColor: ColorTheme.red);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        ApiChecker.checkApi(response);
      } else {
        Get.snackbar(response.body['errors'][0]['code'],
            response.body['errors'][0]['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateEmployeeStatus(int id, Map<String, dynamic> data) async {
    isLoading = true;
    update();
    Response response =
        await employeeManagementRepo.updateEmployeeStatus(id, data);
    if (response.statusCode == 200) {
      await getEmployeeMnmgtList();
      update();
      Get.snackbar('Success', 'Role (id : $id) Updated Successfully',
          backgroundColor: ColorTheme.green, colorText: Colors.white);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      ApiChecker.checkApi(response);
    } else {
      Get.snackbar(response.body['errors'][0]['code'],
          response.body['errors'][0]['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading = false;
    update();
  }

  void filterEmployees() {
    final query = employeeSearchController.text.toLowerCase();

    if (query.isEmpty) {
      filteredEmployeeMnmgtList = employeeMnmgtList;
    } else {
      filteredEmployeeMnmgtList = (employeeMnmgtList ?? []).where((employee) {
        final name = (employee.fName ?? '').toLowerCase();
        // final phone = (employee.phone ?? '').toLowerCase();
        // final role = employee.role?.name?.toLowerCase();

        return name.contains(query);
        // ||
        //     phone.contains(query) ||
        //     role!.contains(query);
      }).toList();
    }
  }

  onSubmit({required bool isEdit, int? id}) async {
    // if (isEdit) {
    //   await updateEmployeeMnmgtList(id!);
    // } else {
    //   await addEmployeeMnmgtList();
    // }
    if (isEdit) {
      await employeeSubmit(isEdit: isEdit, id: id!);
    } else {
      await employeeSubmit(isEdit: isEdit);
    }
  }

  employeeSubmit({bool? isEdit, int? id}) async {
    try {
      final data = {
        'f_name': firstNameController.text,
        'l_name': lastNameController.text,
        'role_id': roleIdMap[selectedRole] ?? 0,
        'email': emailController.text,
        'phone': phoneController.text,
        'bill_user_view': selectedBillUser,
        if (selectedFoodFor.isNotEmpty) 'food_for': selectedFoodFor,
        if (passwordController.text.isNotEmpty)
          'password': passwordController.text
        // "f_name": "albus hogwarts",
        // "l_name": "dumbledore",
        // "role_id": 7,
        // "email": "albuswolfricbp.uspdated@example1.com",
        // "phone": "6387812376",
        // "bill_user_view": "Yes",
        // "password": "randomPassword123!"
      };
      if (isEdit!) {
        updateEmployeeMnmgtList(id: id, data: data);
      } else {
        addEmployeeMnmgtList(data: data);
      }
    } catch (e) {
      print(e);
    }
  }

  bool get isAnyFieldFilled =>
      firstNameController.text.isNotEmpty ||
      lastNameController.text.isNotEmpty ||
      phoneController.text.isNotEmpty ||
      emailController.text.isNotEmpty ||
      passwordController.text.isNotEmpty ||
      confirmPasswordController.text.isNotEmpty ||
      selectedRole != 'All Role' ||
      selectedBillUser != 'No' ||
      selectedFoodFor.isNotEmpty;

  void checkPassword() {
    isMatched = passwordController.text == confirmPasswordController.text;
    update();
  }

  void resetController() async {
    isReset = true;
    update();
    await Future.delayed(Duration(seconds: 1));
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole = 'All Role';
    selectedBillUser = 'No';
    selectedFoodFor = '';
    pendingFoodFor = '';
    isReset = false;
    update();
  }

  String? validatePassword(String value, {bool isEditing = false}) {
    // Password must be at least 8 characters long, contain at least one uppercase letter,
    if (value.isEmpty) {
      return isEditing ? null : 'Password is required';
    }
    String pattern =
        r'^(?=.*[A-Z])(?=.*\d)(?=.*[@!#\$&*~])[A-Za-z\d@!#\$&*~]{8,}$';

    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Password must be 8+ chars, 1 uppercase, 1 number, 1 special char';
    }
    return null;
  }

  String? validatePhone(String value) {
    String pattern = r'^\+?[0-9]{10}$';
    RegExp regex = RegExp(pattern);

    if (value.isEmpty) {
      return 'Phone number is required';
    } else if (!regex.hasMatch(value)) {
      return '10 Digit Phone Number is Required';
    }
    return null;
  }

  String? validateEmail(String value) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);

    if (value.isEmpty) {
      return 'Email is required';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String sanitizePhoneNumber(String Phonenumber) {
    if (Phonenumber.startsWith('+91')) {
      return Phonenumber.substring(3).trim();
    }
    return Phonenumber.trim();
  }

  void autoPopulateEmail() {
    String firstName = firstNameController.text.trim().toLowerCase();
    String restaurantName = Get.find<AuthController>()
            .profileModel
            ?.restaurants
            ?.first
            .name
            ?.toLowerCase() ??
        '';

    // Remove all special characters and spaces except alphanumeric characters
    // This will keep only letters and numbers for email parts
    firstName = firstName.replaceAll(RegExp(r'[^a-z0-9]'), '');
    restaurantName = restaurantName.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // Generate clean email
    emailController.text = '$firstName@$restaurantName.com';
  }
}
