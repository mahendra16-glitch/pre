import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/widget/add_edit_employee_screen.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/widget/add_edit_role_screen.dart';

import 'package:mygenie_restaurant/view/screens/employee_management/widget/employee_content.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/widget/role_content.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/view/expense_screen.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/add_Ingredients_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/current_stocks_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/purchase_report_screen.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/view/recipes_list_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/addons/addons_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/categories/categories_screen.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/view/menu_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'package:super_tooltip/super_tooltip.dart';

class EmployeeMgmtScreen extends StatefulWidget {
  final Key? key;
  const EmployeeMgmtScreen({this.key}) : super(key: key);

  @override
  State<EmployeeMgmtScreen> createState() => _EmployeeMgmtScreenState();
}

class _EmployeeMgmtScreenState extends State<EmployeeMgmtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Employees, Roles
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF5F5F5),
        // drawer: Drawer(
        //   backgroundColor: Color(0xFFF8F8F8),
        //   child: SafeArea(
        //     child: ListView(
        //       // padding: EdgeInsets.zero,

        //       children: <Widget>[
        //         Align(
        //           alignment: Alignment.centerLeft,
        //           child: Padding(
        //             padding: const EdgeInsets.only(top: 20, left: 15),
        //             child: Image.asset(
        //               Images.brand_logo,
        //               height: Get.height * 0.1,
        //             ),
        //           ),
        //         ),
        //         Align(
        //           alignment: Alignment.centerLeft,
        //           child: Padding(
        //             padding: const EdgeInsets.only(left: 15, top: 7),
        //             child: Text(
        //               '${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}',
        //               style: poppinsMedium.copyWith(
        //                   fontSize: 13, color: ColorTheme.hintText),
        //             ),
        //           ),
        //         ),
        //         if (Get.find<AuthController>()
        //             .profileModel!
        //             .role!
        //             .contains('menu'))
        //           Theme(
        //             data: Theme.of(context)
        //                 .copyWith(dividerColor: Colors.transparent),
        //             child: ExpansionTile(
        //               iconColor: ColorTheme.hintText,
        //               initiallyExpanded: true,
        //               expandedAlignment: Alignment.centerLeft,
        //               title: Text(
        //                 'Menu Management',
        //                 style: poppinsMedium.copyWith(
        //                     fontSize: 14, color: ColorTheme.hintText),
        //               ),
        //               children: <Widget>[
        //                 InkWell(
        //                   onTap: () async {
        //                     scaffoldKey.currentState!.closeDrawer();

        //                     FocusManager.instance.primaryFocus?.unfocus();
        //                     Get.find<ExpenseManagementController>()
        //                         .tabValue
        //                         .value = 0;
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
        //         if (Get.find<AuthController>()
        //             .profileModel!
        //             .role!
        //             .contains('expence'))
        //           Theme(
        //             data: Theme.of(context)
        //                 .copyWith(dividerColor: Colors.transparent),
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
        //                     Get.find<ExpenseManagementController>()
        //                         .tabValue
        //                         .value = 0;
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
        //                     Get.find<ExpenseManagementController>()
        //                         .tabValue
        //                         .value = 1;

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
        //         if (Get.find<AuthController>()
        //             .profileModel!
        //             .role!
        //             .contains('inventory'))
        //           Theme(
        //             data: Theme.of(context)
        //                 .copyWith(dividerColor: Colors.transparent),
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
        //         if (Get.find<AuthController>()
        //             .profileModel!
        //             .role!
        //             .contains('sattle_report'))
        //           Theme(
        //             data: Theme.of(context)
        //                 .copyWith(dividerColor: Colors.transparent),
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
        //         if (Get.find<AuthController>()
        //                 .profileModel!
        //                 .role!
        //                 .contains('report_summery') ||
        //             Get.find<AuthController>()
        //                 .profileModel!
        //                 .role!
        //                 .contains('waiter_revenue_report'))
        //           Theme(
        //             data: Theme.of(context)
        //                 .copyWith(dividerColor: Colors.transparent),
        //             child: ExpansionTile(
        //               iconColor: ColorTheme.hintText,
        //               initiallyExpanded: true,
        //               expandedAlignment: Alignment.centerLeft,
        //               title: Text(
        //                 'Revenue',
        //                 style: poppinsMedium.copyWith(
        //                     fontSize: 14, color: ColorTheme.hintText),
        //               ),
        //               children: <Widget>[
        //                 if (Get.find<AuthController>()
        //                     .profileModel!
        //                     .role!
        //                     .contains('report_summery'))
        //                   InkWell(
        //                     onTap: () async {
        //                       FocusManager.instance.primaryFocus?.unfocus();
        //                       scaffoldKey.currentState?.closeDrawer();

        //                       await Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                               builder: (builder) =>
        //                                   ReportSummeryPage()));
        //                     },
        //                     child: Align(
        //                       alignment: Alignment.centerLeft,
        //                       child: Padding(
        //                         padding: const EdgeInsets.only(
        //                             left: 15, top: 0, bottom: 10),
        //                         child: Text(
        //                           'Report Summary',
        //                           style: poppinsMedium.copyWith(
        //                               fontSize: 13, color: ColorTheme.hintText),
        //                         ),
        //                       ),
        //                     ),
        //                   ),
        //                 // const SizedBox(
        //                 //   height: 10,
        //                 // ),
        //                 if (Get.find<AuthController>()
        //                     .profileModel!
        //                     .role!
        //                     .contains('waiter_revenue_report'))
        //                   InkWell(
        //                     onTap: () async {
        //                       FocusManager.instance.primaryFocus?.unfocus();
        //                       scaffoldKey.currentState?.closeDrawer();
        //                       // if (Get.find<AuthController>()
        //                       //     .profileModel!
        //                       //     .role!
        //                       //     .contains('waiter_revenue_report'))
        //                       await Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                               builder: (builder) =>
        //                                   DailyWaiterSalesDetailsReport()));
        //                     },
        //                     child: Align(
        //                       alignment: Alignment.centerLeft,
        //                       child: Padding(
        //                         padding:
        //                             const EdgeInsets.only(left: 15, top: 0),
        //                         child: Text(
        //                           'Report Summary(W)',
        //                           style: poppinsMedium.copyWith(
        //                               fontSize: 13, color: ColorTheme.hintText),
        //                         ),
        //                       ),
        //                     ),
        //                   ),

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
        //         if (Get.find<AuthController>()
        //             .profileModel!
        //             .role!
        //             .contains('employee'))
        //           Theme(
        //             data: Theme.of(context)
        //                 .copyWith(dividerColor: Colors.transparent),
        //             child: ExpansionTile(
        //               iconColor: ColorTheme.hintText,
        //               initiallyExpanded: true,
        //               expandedAlignment: Alignment.centerLeft,
        //               title: Text(
        //                 'Employee Management',
        //                 style: poppinsMedium.copyWith(
        //                     fontSize: 14, color: ColorTheme.hintText),
        //               ),
        //               children: <Widget>[
        //                 InkWell(
        //                   onTap: () async {
        //                     FocusManager.instance.primaryFocus?.unfocus();
        //                     scaffoldKey.currentState?.closeDrawer();

        //                     await Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                             builder: (builder) =>
        //                                 EmployeeMgmtScreen()));
        //                   },
        //                   child: Align(
        //                     alignment: Alignment.centerLeft,
        //                     child: Padding(
        //                       padding: const EdgeInsets.only(left: 15, top: 10),
        //                       child: Text(
        //                         'Employee Management',
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
        //         Theme(
        //           data: Theme.of(context)
        //               .copyWith(dividerColor: Colors.transparent),
        //           child: ExpansionTile(
        //             iconColor: ColorTheme.hintText,
        //             initiallyExpanded: true,
        //             expandedAlignment: Alignment.centerLeft,
        //             title: Text(
        //               'My Profile',
        //               style: poppinsMedium.copyWith(
        //                   fontSize: 14, color: ColorTheme.hintText),
        //             ),
        //             children: <Widget>[
        //               InkWell(
        //                 onTap: () {
        //                   scaffoldKey.currentState?.closeDrawer();
        //                   FocusManager.instance.primaryFocus?.unfocus();

        //                   String logo = '';
        //                   if (!Get.find<AuthController>()
        //                           .profileModel!
        //                           .role!
        //                           .contains('order') &&
        //                       Get.find<AuthController>()
        //                           .profileModel!
        //                           .role!
        //                           .contains('bill')) {
        //                     logo = Images.ic_cashier_app_logo;
        //                   } else if (Get.find<AuthController>()
        //                       .profileModel!
        //                       .role!
        //                       .contains('report')) {
        //                     logo = Images.ic_owner_app_logo;
        //                   } else if (Get.find<AuthController>()
        //                       .profileModel!
        //                       .role!
        //                       .contains('Manager')) {
        //                     logo = Images.ic_manager_app_logo;
        //                   } else {
        //                     logo = Images.ic_waiter_app_logo;
        //                   }

        //                   Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                           builder: ((context) => EmployeeResetPassword(
        //                                 resetToken: Get.find<AuthController>()
        //                                     .getUserToken(),
        //                                 email: Get.find<AuthController>()
        //                                     .profileModel!
        //                                     .empEmail!,
        //                                 image: logo,
        //                                 password: '',
        //                                 fromPasswordChange: true,
        //                               ))));

        //                   // Get.toNamed(RouteHelper.getEmployeeResetPasswordRoute(
        //                   //     Get.find<AuthController>().profileModel.empEmail,
        //                   //     Get.find<AuthController>().getUserToken(),
        //                   //     'password-change'));
        //                   // Get.toNamed(RouteHelper.getTapManagementRoute());
        //                 },
        //                 child: Align(
        //                   alignment: Alignment.centerLeft,
        //                   child: Padding(
        //                     padding: EdgeInsets.only(left: 15, top: 15),
        //                     child: Text(
        //                       'Reset Password',
        //                       style: poppinsMedium.copyWith(
        //                           fontSize: 13, color: ColorTheme.hintText),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               // if (GetPlatform.isAndroid)
        //               //   InkWell(
        //               //     onTap: () {
        //               //       scaffoldKey.currentState.closeDrawer();
        //               //       FocusManager.instance.primaryFocus?.unfocus();

        //               //       Navigator.push(
        //               //           context,
        //               //           MaterialPageRoute(
        //               //               builder: (builder) => UsbGetPrinterIp()));
        //               //       // Get.toNamed(RouteHelper.getTapManagementRoute());
        //               //     },
        //               //     child: Align(
        //               //       alignment: Alignment.centerLeft,
        //               //       child: Padding(
        //               //         padding: const EdgeInsets.only(left: 15, top: 10),
        //               //         child: Text(
        //               //           'Usb Printer Configuration',
        //               //           style: poppinsMedium.copyWith(
        //               //               fontSize: 13, color: ColorTheme.hintText),
        //               //         ),
        //               //       ),
        //               //     ),
        //               //   ),
        //               InkWell(
        //                 onTap: () {
        //                   FocusManager.instance.primaryFocus?.unfocus();
        //                   scaffoldKey.currentState?.closeDrawer();

        //                   Get.bottomSheet(
        //                     ConfirmationDialog(
        //                         icon: Images.support,
        //                         description:
        //                             'Are you sure you want to log out from My Genie?',
        //                         isLogOut: true,
        //                         onYesPressed: () async {
        //                           try {
        //                             Response response =
        //                                 await Get.find<AuthController>()
        //                                     .logout();
        //                             if (response.statusCode == 200) {
        //                               Get.find<RestaurantController>()
        //                                   .clearProductList();
        //                               Get.find<AuthController>()
        //                                   .clearSharedData();
        //                               Get.offAllNamed(
        //                                   RouteHelper.getSignInRoute());
        //                             }
        //                           } catch (e) {
        //                             print(e);
        //                           }
        //                           // socket.disconnect();
        //                           // Get.find<RestaurantController>()
        //                           //     .clearProductList();
        //                           // Get.find<AuthController>().clearSharedData();
        //                           // Get.offAllNamed(RouteHelper.getSignInRoute());
        //                         }),
        //                   );
        //                 },
        //                 child: Align(
        //                   alignment: Alignment.centerLeft,
        //                   child: Padding(
        //                     padding: const EdgeInsets.only(left: 15, top: 15),
        //                     child: Text(
        //                       'Logout',
        //                       style: poppinsMedium.copyWith(
        //                           fontSize: 13, color: ColorTheme.hintText),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Align(
        //           alignment: Alignment.centerLeft,
        //           child: Padding(
        //             padding: const EdgeInsets.only(left: 15, top: 10),
        //             child: Text(
        //               'Restaurant Id: ${Get.find<AuthController>().profileModel?.restaurants?.first.id ?? '0'}',
        //               style: poppinsMedium.copyWith(
        //                   fontSize: 13, color: ColorTheme.hintText),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        appBar: AppBar(
          backgroundColor: ColorTheme.white,
          // leading: IconButton(
          //   icon: Image.asset(Images.menu,
          //       color: ColorTheme.appColor, height: 16),
          //   onPressed: () {
          //     scaffoldKey.currentState?.openDrawer();
          //   },
          // ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: ColorTheme.appColor, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            _tabController.index == 0 ? "Employee Mgmt" : 'Roles Mgmt',
            style: montserratSemiBold.copyWith(
              color: Colors.green,
              fontSize: 18,
            ),
          ),
          titleSpacing: 0,
          scrolledUnderElevation: 0,
          actions: [
            SizedBox(width: 25, child: SvgPicture.asset(Images.export)),
            SizedBox(width: 16),
            IconButton(
              onPressed: () {
                _tabController.index == 0
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddEditEmployeeRoleScreen(
                                  employeeRoleData: {},
                                )))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddEditRoleScreen(
                                  isEdit: false,
                                )));
              },
              icon: Icon(
                Icons.add_circle_outline_outlined,
                color: Colors.green,
                size: 32,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // TabBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                    color: ColorTheme.white,
                    borderRadius: BorderRadius.circular(0),
                    border: Border(
                        top: BorderSide(color: ColorTheme.borderGrey3),
                        bottom: BorderSide(color: ColorTheme.borderGrey3))),
                child: TabBar(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  indicator: BoxDecoration(
                    color: ColorTheme.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: ColorTheme.green,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: [
                    Tab(
                        child: Center(
                            child: Text(
                      'Employees',
                      style: montserratSemiBold.copyWith(fontSize: 16),
                    ))),
                    Tab(
                        child: Center(
                            child: Text(
                      'Roles',
                      style: montserratSemiBold.copyWith(fontSize: 16),
                    ))),
                  ],
                ),
              ),

              // const SizedBox(height: 18),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: TextField(
              //     controller: Get.find<EmployeeManagementController>()
              //         .employeeSearchController,
              //     style: TextStyle(decoration: TextDecoration.none),
              //     decoration: InputDecoration(
              //       hintText: 'Search',
              //       hintStyle:
              //           poppinsSemiBold.copyWith(color: Color(0xFFC6C6C6)),
              //       suffixIcon: const Icon(
              //         Icons.search,
              //         color: Color(0xFFC6C6C6),
              //       ),
              //       filled: true,
              //       fillColor: ColorTheme.white,
              //       contentPadding: const EdgeInsets.symmetric(
              //           horizontal: 20, vertical: 12),
              //       border: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(30)),
              //           borderSide: BorderSide(color: ColorTheme.white)),
              //       focusedBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(30)),
              //           borderSide: BorderSide(color: ColorTheme.white)),
              //       errorBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(30)),
              //           borderSide: BorderSide(color: ColorTheme.white)),
              //       enabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(30)),
              //           borderSide: BorderSide(color: ColorTheme.white)),
              //     ),
              //     onChanged: (_) {
              //       Get.find<EmployeeManagementController>().filterEmployees();
              //     },
              //   ),
              // ),

              // const SizedBox(height: 20),

              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // First Tab: Employees
                    const EmployeeList(),

                    // Second Tab: Roles
                    const RoleList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
