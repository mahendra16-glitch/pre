// import 'dart:developer';
// import 'package:dotted_line/dotted_line.dart';
// import 'package:mygenie_restaurant/controller/auth_controller.dart';
// import 'package:mygenie_restaurant/controller/expense_controller.dart';
// import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
// import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
// import 'package:mygenie_restaurant/helper/colors.dart';
// import 'package:mygenie_restaurant/helper/route_helper.dart';
// import 'package:mygenie_restaurant/util/images.dart';
// import 'package:mygenie_restaurant/util/styles.dart';
// import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
// import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
// import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
// import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
// import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
// import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
// import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// Widget customDrawer(BuildContext context) {
//   return Drawer(
//     backgroundColor: Color(0xFFF8F8F8),
//     child: SafeArea(
//       child: ListView(
//         // padding: EdgeInsets.zero,

//         children: <Widget>[
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 20, left: 15),
//               child: Image.asset(
//                 Images.brand_logo,
//                 height: Get.height * 0.1,
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 15, top: 7),
//               child: Text(
//                 '${Get.find<AuthController>()?.profileModel?.empFname ?? ''} ${Get.find<AuthController>()?.profileModel?.empLname ?? ''}',
//                 style: poppinsMedium.copyWith(
//                     fontSize: 13, color: ColorTheme.hintText),
//               ),
//             ),
//           ),
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               iconColor: ColorTheme.hintText,
//               initiallyExpanded: true,
//               expandedAlignment: Alignment.centerLeft,
//               title: Text(
//                 'Manu Management',
//                 style: poppinsMedium.copyWith(
//                     fontSize: 14, color: ColorTheme.hintText),
//               ),
//               children: <Widget>[
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();
//                     Get.find<ExpenseManagementController>().tabValue.value = 0;
//                     await Get.to(() => MenuHomeScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Manage Food',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 15.height,
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();

//                     await Get.to(() => CategoriesScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Categories',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 15.height,
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();

//                     await Get.to(() => AddonsScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Addons',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 15, left: 15),
//                   child: DottedLine(
//                     direction: Axis.horizontal,
//                     alignment: WrapAlignment.center,
//                     lineThickness: 1.0,
//                     dashLength: 2.5,
//                     dashColor: ColorTheme.hintText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               iconColor: ColorTheme.hintText,
//               initiallyExpanded: true,
//               expandedAlignment: Alignment.centerLeft,
//               title: Text(
//                 'Expense',
//                 style: poppinsMedium.copyWith(
//                     fontSize: 14, color: ColorTheme.hintText),
//               ),
//               children: <Widget>[
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();
//                     Get.find<ExpenseManagementController>().tabValue.value = 0;
//                     await Get.to(() => ExpenseManagementScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Manage Expenses',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 15.height,
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();
//                     Get.find<ExpenseManagementController>().tabValue.value = 1;

//                     await Get.to(() => ExpenseManagementScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Add Stock',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 15, left: 15),
//                   child: DottedLine(
//                     direction: Axis.horizontal,
//                     alignment: WrapAlignment.center,
//                     lineThickness: 1.0,
//                     dashLength: 2.5,
//                     dashColor: ColorTheme.hintText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               iconColor: ColorTheme.hintText,
//               initiallyExpanded: true,
//               expandedAlignment: Alignment.centerLeft,
//               title: Text(
//                 'Inventory Management',
//                 style: poppinsMedium.copyWith(
//                     fontSize: 14, color: ColorTheme.hintText),
//               ),
//               children: <Widget>[
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();

//                     await Get.to(() => CurrentStocksScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Manage Stocks',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 15.height,
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();

//                     await Get.to(() => AddIngredientsScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Master Ingredients',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 15.height,
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();

//                     await Get.to(() => PurchaseReportScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Purchase Report',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 15.height,
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();

//                     FocusManager.instance.primaryFocus?.unfocus();

//                     await Get.to(() => RecipesListScreen());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Recipes List',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 15, left: 15),
//                   child: DottedLine(
//                     direction: Axis.horizontal,
//                     alignment: WrapAlignment.center,
//                     lineThickness: 1.0,
//                     dashLength: 2.5,
//                     dashColor: ColorTheme.hintText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               iconColor: ColorTheme.hintText,
//               initiallyExpanded: true,
//               expandedAlignment: Alignment.centerLeft,
//               title: Text(
//                 'Settlement',
//                 style: poppinsMedium.copyWith(
//                     fontSize: 14, color: ColorTheme.hintText),
//               ),
//               children: <Widget>[
//                 InkWell(
//                   onTap: () async {
//                     scaffoldKey.currentState!.closeDrawer();
//                     // _subscriptionBtStatus!.cancel();
//                     FocusManager.instance.primaryFocus?.unfocus();

//                     await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (builder) => SettlementScreen()));
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 0),
//                       child: Text(
//                         'Settlement',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 15, left: 15),
//                   child: DottedLine(
//                     direction: Axis.horizontal,
//                     alignment: WrapAlignment.center,
//                     lineThickness: 1.0,
//                     dashLength: 2.5,
//                     dashColor: ColorTheme.hintText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Theme(
//             data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//             child: ExpansionTile(
//               iconColor: ColorTheme.hintText,
//               initiallyExpanded: true,
//               expandedAlignment: Alignment.centerLeft,
//               title: Text(
//                 'My Profile',
//                 style: poppinsMedium.copyWith(
//                     fontSize: 14, color: ColorTheme.hintText),
//               ),
//               children: <Widget>[
//                 InkWell(
//                   onTap: () {
//                     scaffoldKey.currentState?.closeDrawer();
//                     FocusManager.instance.primaryFocus?.unfocus();

//                     String logo = '';
//                     if (!Get.find<AuthController>()
//                             .profileModel!
//                             .role!
//                             .contains('order') &&
//                         Get.find<AuthController>()
//                             .profileModel!
//                             .role!
//                             .contains('bill')) {
//                       logo = Images.ic_cashier_app_logo;
//                     } else if (Get.find<AuthController>()
//                         .profileModel!
//                         .role!
//                         .contains('report')) {
//                       logo = Images.ic_owner_app_logo;
//                     } else if (Get.find<AuthController>()
//                         .profileModel!
//                         .role!
//                         .contains('Manager')) {
//                       logo = Images.ic_manager_app_logo;
//                     } else {
//                       logo = Images.ic_waiter_app_logo;
//                     }

//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: ((context) => EmployeeResetPassword(
//                                   resetToken:
//                                       Get.find<AuthController>().getUserToken(),
//                                   email: Get.find<AuthController>()
//                                       .profileModel!
//                                       .empEmail,
//                                   image: logo,
//                                   password: '',
//                                   fromPasswordChange: true,
//                                 ))));

//                     // Get.toNamed(RouteHelper.getEmployeeResetPasswordRoute(
//                     //     Get.find<AuthController>().profileModel.empEmail,
//                     //     Get.find<AuthController>().getUserToken(),
//                     //     'password-change'));
//                     // Get.toNamed(RouteHelper.getTapManagementRoute());
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: EdgeInsets.only(left: 15, top: 15),
//                       child: Text(
//                         'Reset Password',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // if (GetPlatform.isAndroid)
//                 //   InkWell(
//                 //     onTap: () {
//                 //       scaffoldKey.currentState.closeDrawer();
//                 //       FocusManager.instance.primaryFocus?.unfocus();

//                 //       Navigator.push(
//                 //           context,
//                 //           MaterialPageRoute(
//                 //               builder: (builder) => UsbGetPrinterIp()));
//                 //       // Get.toNamed(RouteHelper.getTapManagementRoute());
//                 //     },
//                 //     child: Align(
//                 //       alignment: Alignment.centerLeft,
//                 //       child: Padding(
//                 //         padding: const EdgeInsets.only(left: 15, top: 10),
//                 //         child: Text(
//                 //           'Usb Printer Configuration',
//                 //           style: poppinsMedium.copyWith(
//                 //               fontSize: 13, color: ColorTheme.hintText),
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ),
//                 InkWell(
//                   onTap: () {
//                     FocusManager.instance.primaryFocus?.unfocus();
//                     scaffoldKey.currentState?.closeDrawer();

//                     Get.bottomSheet(
//                       ConfirmationDialog(
//                           icon: Images.support,
//                           description:
//                               'Are you sure you want to log out from My Genie?',
//                           isLogOut: true,
//                           onYesPressed: () async {
//                             try {
//                               Response response =
//                                   await Get.find<AuthController>().logout();
//                               if (response.statusCode == 200) {
//                                 Get.find<RestaurantController>()
//                                     .clearProductList();
//                                 Get.find<AuthController>().clearSharedData();
//                                 Get.offAllNamed(RouteHelper.getSignInRoute());
//                               }
//                             } catch (e) {}
//                             // socket.disconnect();
//                             // Get.find<RestaurantController>()
//                             //     .clearProductList();
//                             // Get.find<AuthController>().clearSharedData();
//                             // Get.offAllNamed(RouteHelper.getSignInRoute());
//                           }),
//                     );
//                   },
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15, top: 15),
//                       child: Text(
//                         'Logout',
//                         style: poppinsMedium.copyWith(
//                             fontSize: 13, color: ColorTheme.hintText),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Padding(
//               padding: const EdgeInsets.only(left: 15, top: 10),
//               child: Text(
//                 'Restaurant Id: ${Get.find<AuthController>().profileModel?.restaurants?.first?.id ?? '0'}',
//                 style: poppinsMedium.copyWith(
//                     fontSize: 13, color: ColorTheme.hintText),
//               ),
//             ),
//           ),
//           ListTile(
//             title: Text(
//               'Version: ${packageInfo?.version ?? ''}(${packageInfo?.buildNumber ?? ''})',
//               style: poppinsMedium.copyWith(fontSize: 10, color: Colors.grey),
//             ),
//             onTap: () {},
//           ),
//         ],
//       ),
//     ),
//   );
// }
