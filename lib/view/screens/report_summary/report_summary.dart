import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/extension/sizebox_extension.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/employee_home_screen.dart';
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
import 'package:mygenie_restaurant/view/screens/report_summary/widget/daily_waiter_sales_detail_report.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/most_cancel_tem.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/most_sell_station_item.dart';
import 'package:mygenie_restaurant/view/screens/settlement/screen/settlement_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../controller/report_summary_controller.dart';
// import 'widget/bar_chart_with_dialog.dart';
import 'widget/revenue_trend_chart.dart';
import 'widget/most_sold_category.dart';
import 'widget/most_sold_item.dart';

class ReportSummeryPage extends StatefulWidget {
  final bool isadmin;
  ReportSummeryPage({super.key, this.isadmin = false});

  @override
  State<ReportSummeryPage> createState() => _ReportSummeryPageState();
}

class _ReportSummeryPageState extends State<ReportSummeryPage> {
  // final controller = Get.put(ReportSummeryController());
  final controller = Get.find<ReportSummeryController>();
  // final scaffoldKey = GlobalKey<ScaffoldState>();
  PackageInfo? packageInfo;

  // Preference preference = Preference();
  @override
  void initState() {
    apiCall();
    super.initState();
  }

  apiCall() async {
    await controller.initializeAllApis();
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: controller.scaffoldKey,
      key: scaffoldKey,
      backgroundColor: ColorTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        // forceMaterialTransparency: true,
        title: RichText(
          text: const TextSpan(
            text: 'Report ',
            style: TextStyle(
              color: ColorTheme.redColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Summary',
                style: TextStyle(
                  color: ColorTheme.greenColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        leading: widget.isadmin
            ? Padding(
                padding:
                    const EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                child: IconButton(
                  icon: Image.asset(Images.menu, color: ColorTheme.appColor),
                  onPressed: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
              )
            : IconButton(
                icon: const Icon(
                  Icons.chevron_left_outlined,
                  color: Color(0xFFF26B33),
                  size: 30,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
        // leading: IconButton(
        //   icon:
        //       Image.asset(Images.menu, color: ColorTheme.appColor, height: 16),
        //   onPressed: () {
        //     scaffoldKey.currentState?.openDrawer();
        //   },
        // ),
        actions: [
          IconButton(
            onPressed: () async {},
            icon: const Icon(Icons.rotate_90_degrees_cw),
            color: ColorTheme.greyColor,
            iconSize: 20,
          ),
        ],
      ),
      drawer: widget.isadmin
          ? Drawer(
              backgroundColor: const Color(0xFFF8F8F8),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 15),
                        child: Image.asset(
                          Images.brand_logo,
                          height: Get.height * 0.1,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 7),
                        child: Text(
                          '${Get.find<AuthController>().profileModel?.empFname ?? ''} ${Get.find<AuthController>().profileModel?.empLname ?? ''}',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: ColorTheme.hintText,
                        initiallyExpanded: true,
                        expandedAlignment: Alignment.centerLeft,
                        title: Text(
                          'My Profile',
                          style: poppinsMedium.copyWith(
                              fontSize: 14, color: ColorTheme.hintText),
                        ),
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              scaffoldKey.currentState?.closeDrawer();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          EmployeeResetPassword(
                                            resetToken:
                                                Get.find<AuthController>()
                                                    .getUserToken(),
                                            email: Get.find<AuthController>()
                                                .profileModel!
                                                .empEmail!,
                                            image: Images.ic_kds_app_logo,
                                            password: '',
                                            fromPasswordChange: true,
                                          ))));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, top: GetPlatform.isIOS ? 10 : 0),
                                child: Text(
                                  'Reset Password',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              scaffoldKey.currentState?.closeDrawer();

                              if (Get.find<AuthController>().isAdminSession) {
                                Get.bottomSheet(
                                  ConfirmationDialog(
                                      icon: Images.support,
                                      description:
                                          'You will be redirected to MyGenie Admin Dashboard',
                                      title: 'Logout from Restaurant',
                                      isLogOut: true,
                                      onYesPressed: () async {
                                        try {
                                          Response response =
                                              await Get.find<AuthController>()
                                                  .logout();
                                          if (response.statusCode == 200) {
                                            Get.find<RestaurantController>()
                                                .clearProductList();
                                            Get.find<AuthController>()
                                                .clearSharedData();
                                            // Get.offAllNamed(RouteHelper.getSignInRoute());

                                            await Get.find<AuthController>()
                                                .logoutFromRestaurant();
                                            Get.offAllNamed(RouteHelper
                                                .getAdminDashboardRoute());

                                            showCustomSnackBar(
                                                'Logged out from restaurant successfully',
                                                isError: false);
                                          }
                                        } catch (e) {}
                                      }),
                                );
                              } else {
                                Get.bottomSheet(ConfirmationDialog(
                                    icon: Images.support,
                                    description:
                                        'Are you sure you want to log out from My Genie?',
                                    isLogOut: true,
                                    onYesPressed: () async {
                                      try {
                                        Response response =
                                            await Get.find<AuthController>()
                                                .logout();
                                        if (response.statusCode == 200) {
                                          Get.find<RestaurantController>()
                                              .clearProductList();
                                          Get.find<AuthController>()
                                              .clearSharedData();
                                          Get.offAllNamed(
                                              RouteHelper.getSignInRoute());
                                        }
                                      } catch (e) {}
                                    }));
                              }
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: Text(
                                  'Logout',
                                  style: poppinsMedium.copyWith(
                                      fontSize: 13, color: ColorTheme.hintText),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: Text(
                          'Restaurant Id: ${Get.find<AuthController>().profileModel?.restaurants?.first.id ?? '0'}',
                          style: poppinsMedium.copyWith(
                              fontSize: 13, color: ColorTheme.hintText),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Version: ${packageInfo?.version ?? ''}(${packageInfo?.buildNumber ?? ''})',
                        style: poppinsMedium.copyWith(
                            fontSize: 10, color: Colors.grey),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  decoration: const BoxDecoration(
                    color: ColorTheme.grey200Color,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: ColorTheme.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Obx(
                        () => Row(
                          children: List.generate(
                            controller.salesChartTabs.length,
                            (index) {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selected.value = index;
                                    controller.fetchInsightsSales(index);
                                  },
                                  child: Container(
                                    color: controller.selected.value == index
                                        ? ColorTheme.blueColor
                                        : ColorTheme.whiteColor,
                                    alignment: Alignment.center,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 7),
                                    child: Text(
                                      controller.salesChartTabs[index],
                                      style: TextStyle(
                                        color: controller.selected.value == index
                                            ? ColorTheme.whiteColor
                                            : ColorTheme.greyColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  color: ColorTheme.grey200Color,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Sales',
                              style: TextStyle(
                                color: ColorTheme.blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${controller.getDateRangeForSales(controller.selected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.selected.value)["endDate"]}',
                                style: const TextStyle(
                                  color: ColorTheme.greyColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Obx(
                          () => Text(
                            '₹${controller.insightsTotalSales.value}',
                            style: const TextStyle(
                              color: ColorTheme.blackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  height: 300,
                  color: ColorTheme.grey200Color,
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: RevenueTrendChart(controller: controller),
                ),
              /*
              /// Report Summary
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  decoration: const BoxDecoration(
                    color: ColorTheme.grey200Color,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: ColorTheme.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            controller.reportList.length,
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  controller.selected.value = index;
                                  controller.totalSalesReport(index);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: controller.selected.value == index
                                          ? ColorTheme.blueColor
                                          : ColorTheme.whiteColor),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 7),
                                    child: Text(
                                      controller.reportList[index],
                                      style: TextStyle(
                                        color:
                                            controller.selected.value == index
                                                ? ColorTheme.whiteColor
                                                : ColorTheme.greyColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  color: ColorTheme.grey200Color,
                  child: GestureDetector(
                    onTap: () {
                      controller.isExpanded1.value =
                          !controller.isExpanded1.value;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Sales',
                                style: TextStyle(
                                  color: ColorTheme.blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '${controller.getDateRangeForSales(controller.selected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.selected.value)["endDate"]}',
                                  style: const TextStyle(
                                    color: ColorTheme.greyColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Get.find<AuthController>()
                                      .profileModel
                                      ?.restaurants
                                      ?.first
                                      .resturantType ==
                                  'Restaurant'
                              ? Obx(
                                  () => Text(
                                    '₹${controller.totalSalesCount.value}',
                                    style: const TextStyle(
                                      color: ColorTheme.blackColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : Text(
                                  '₹0.00',
                                  style: const TextStyle(
                                    color: ColorTheme.blackColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                          Obx(
                            () => Icon(
                              controller.isExpanded1.value
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: ColorTheme.greyColor,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  color: ColorTheme.grey200Color,
                  child: Obx(
                    () {
                      List stationRevenue = controller
                                      .topSalesList["station_revenue"]
                                      .toString() ==
                                  "null" ||
                              controller.topSalesList["station_revenue"].isEmpty
                          ? []
                          : (controller.topSalesList["station_revenue"].entries
                              .map((entry) => {
                                    "name": entry.key,
                                    "value": double.parse(entry.value
                                        .toString()
                                        .replaceAll(',', ''))
                                  })
                              .toList());

                      List cancelRevenue = controller
                                  .topSalesList["cancel_revenue"]
                                  .toString() ==
                              "null"
                          ? []
                          : (controller.topSalesList["cancel_revenue"].entries
                              .map((entry) => {
                                    "name": entry.key,
                                    "value": double.parse(entry.value
                                        .toString()
                                        .replaceAll(',', ''))
                                  })
                              .toList());

                      List roomRevenue =
                          controller.topSalesList["room_revenue"].toString() ==
                                  "null"
                              ? []
                              : (controller.topSalesList["room_revenue"].entries
                                  .map((entry) => {
                                        "name": entry.key,
                                        "value": entry.value
                                            .toString()
                                            .replaceAll(',', ''),
                                      })
                                  .toList());
                      return Visibility(
                        visible: controller.isExpanded1.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              // const Divider(),

                              buildHeader('Paid Revenue',
                                  '₹${controller.topSalesList["paid_revenue"] ?? '0.00'}',
                                  isBold: true),
                              buildSection('Cash',
                                  '₹${controller.topSalesList["Cash"] ?? '0.00'}'),
                              buildSection('Card',
                                  '₹${controller.topSalesList["Card"] ?? '0.00'}'),
                              buildSection('UPI',
                                  '₹${controller.topSalesList["UPI"] ?? '0.00'}'),
                              const Divider(),
                              const Divider(),

                              buildSection('Credit Cash',
                                  '₹${controller.topSalesList["tab_cash"] ?? '0.00'}'),
                              buildSection('Credit Card',
                                  '₹${controller.topSalesList["tab_card"] ?? '0.00'}'),
                              buildSection('Credit UPI',
                                  '₹${controller.topSalesList["tab_upi"] ?? '0.00'}'),
                              const Divider(),
                              const Divider(),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: roomRevenue.length,
                                itemBuilder: (context, index) {
                                  var items = roomRevenue[index];
                                  return buildSection('${items["name"]}',
                                      '₹${items["value"] ?? '0.00'}');
                                },
                              ),
                              const Divider(),
                              const Divider(),

                              buildSection('Credit Unpaid',
                                  '₹${controller.topSalesList["orderTAB"] ?? '0.00'}'),
                              buildSection('Room Unpaid',
                                  '₹${controller.topSalesList["orderRoom"] ?? '0.00'}'),
                              const Divider(),
                              const Divider(),

                              buildHeader('Running Orders',
                                  '₹${controller.topSalesList["running_order"] ?? '0.00'}',
                                  isBold: true),
                              buildSection('Service Charge',
                                  '₹${controller.topSalesList["service_charge"] ?? '0.00'}'),
                              buildSection('Discount',
                                  '₹${controller.topSalesList["discount"] ?? '0.00'}'),
                              buildSection('Tips',
                                  '₹${controller.topSalesList["tips"] ?? '0.00'}'),
                              buildSection('Tax',
                                  '₹${controller.topSalesList["tax"] ?? '0.00'}'),
                              const Divider(),
                              const Divider(),

                              buildHeader('Station Sales',
                                  '₹${stationRevenue.length == 0 ? 0.00 : stationRevenue.map((item) => item["value"] ?? '0.00').reduce((a, b) => a + b)}',
                                  isBold: true),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: stationRevenue.length,
                                itemBuilder: (context, index) {
                                  var items = stationRevenue[index];
                                  return buildSection('${items["name"]}',
                                      '₹${items["value"] ?? '0.00'}');
                                },
                              ),
                              const Divider(),
                              const Divider(),

                              buildHeader('Cancel Sales',
                                  '₹${cancelRevenue.length == 0 ? 0.00 : cancelRevenue.map((item) => item["value"] ?? '0.00').reduce((a, b) => a + b)}',
                                  isBold: true),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: cancelRevenue.length,
                                itemBuilder: (context, index) {
                                  var items = cancelRevenue[index];
                                  return buildSection('${items["name"]}',
                                      '₹${items["value"] ?? '0.00'}');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  height: 300,
                  color: ColorTheme.grey200Color,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 15),
                        child: BarChartWithDialog(controller: controller),
                      ),
                      Obx(() {
                        if (controller.isLoadingTopSales.value) {
                          return Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: ColorTheme.grey200Color,
                            child: const Center(
                                child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            )),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ],
                  ),
                ),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('sales_report'))
                Container(
                  color: ColorTheme.grey200Color,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        controller.chartList.length,
                        (index) {
                          return Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: controller.chartList[index]['color'],
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.chartList[index]['name'],
                                style: const TextStyle(
                                  color: ColorTheme.greyColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

              */
              /// Average Sales
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('revenue_report_average'))
                Get.find<AuthController>()
                            .profileModel
                            ?.restaurants
                            ?.first
                            .resturantType ==
                        'Restaurant'
                    ? const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: Text(
                          'Average Sales',
                          style: TextStyle(
                            color: ColorTheme.greyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('revenue_report_average'))
                Get.find<AuthController>()
                            .profileModel
                            ?.restaurants
                            ?.first
                            .resturantType ==
                        'Restaurant'
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: ColorTheme.grey200Color,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                controller.averageSalesList.length,
                                (index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      controller.averageListSelected.value =
                                          index;
                                      controller.generateDateList();
                                      await controller.revenueReport(index);
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: controller.averageListSelected
                                                      .value ==
                                                  index
                                              ? ColorTheme.blueColor
                                              : ColorTheme.grey200Color),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25, vertical: 7),
                                        child: Text(
                                          controller.averageSalesList[index],
                                          style: TextStyle(
                                            color: controller
                                                        .averageListSelected
                                                        .value ==
                                                    index
                                                ? ColorTheme.whiteColor
                                                : ColorTheme.greyColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),

              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('revenue_report_average'))
                Get.find<AuthController>()
                            .profileModel
                            ?.restaurants
                            ?.first
                            .resturantType ==
                        'Restaurant'
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Average Sales',
                                  style: TextStyle(
                                    color: ColorTheme.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    '${controller.getDateRange(controller.averageListSelected.value)["startDate"]} - ${controller.getDateRange(controller.averageListSelected.value)["endDate"]}',
                                    style: const TextStyle(
                                      color: ColorTheme.greyColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Obx(
                              () => Text(
                                controller.averageSalesDate.values.isEmpty
                                    ? ''
                                    : '₹${(controller.averageSalesDate.values.reduce((a, b) => a + b) / controller.averageSalesDate.length).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: ColorTheme.blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('revenue_report_average'))
                Get.find<AuthController>()
                            .profileModel
                            ?.restaurants
                            ?.first
                            .resturantType ==
                        'Restaurant'
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(
                          color: ColorTheme.greyColor,
                          height: 1,
                          thickness: 0.5,
                        ),
                      )
                    : SizedBox.shrink(),
              if (Get.find<AuthController>()
                  .profileModel!
                  .role!
                  .contains('revenue_report_average'))
                Get.find<AuthController>()
                            .profileModel
                            ?.restaurants
                            ?.first
                            .resturantType ==
                        'Restaurant'
                    ? Obx(() => Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: TableCalendar(
                            onCalendarCreated:
                                (PageController controller) async {
                              await Future.delayed(Duration(seconds: 5));
                              setState(() {});
                            },
                            calendarFormat: CalendarFormat.month,
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: controller.focusedDay.value,
                            selectedDayPredicate: (day) {
                              return isSameDay(
                                  controller.selectedDay.value, day);
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                final totalSales = controller.averageSalesDate[
                                        DateTime(
                                            day.year, day.month, day.day)] ??
                                    0;

                                // Defining a local variable to determine the background color.
                                final Color backgroundColor = controller
                                        .averageSalesDate
                                        .containsKey(DateTime(
                                            day.year, day.month, day.day))
                                    ? totalSales <=
                                            (controller.averageSalesDate.values
                                                    .reduce((a, b) => a + b) /
                                                controller
                                                    .averageSalesDate.length)
                                        ? ColorTheme.redColor
                                        : ColorTheme.greenColor
                                    : Colors.transparent;

                                return Container(
                                  height: 50,
                                  width: 50,
                                  margin: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      color:
                                          backgroundColor == Colors.transparent
                                              ? ColorTheme.greyColor
                                              : ColorTheme.whiteColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.showCustomBottomSheet(
                                  context, selectedDay);
                              // });
                            },
                            calendarStyle: CalendarStyle(
                              isTodayHighlighted: false,
                              selectedTextStyle:
                                  TextStyle(color: ColorTheme.greyColor),
                              selectedDecoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.rectangle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: ColorTheme.greenColor,
                                shape: BoxShape.rectangle,
                              ),
                              markerDecoration: BoxDecoration(
                                color: ColorTheme.redColor,
                                shape: BoxShape.rectangle,
                              ),
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              leftChevronVisible: false,
                              rightChevronVisible: false,
                              headerPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              titleTextStyle: TextStyle(
                                color: ColorTheme.greyColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ))
                    : SizedBox.shrink(),

              /// List Of Sales
              Container(
                color: ColorTheme.grey200Color,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Station Sales
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('consumption_report'))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                'Station Sales',
                                style: TextStyle(
                                  color: ColorTheme.greyColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: ColorTheme.whiteColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Obx(
                                  () => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      controller.reportList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            controller.stationListSelected
                                                .value = index;
                                            controller.setDateRange(
                                                controller.reportList[index],
                                                section: 'station');
                                            controller
                                                .stationSalesRevenueReport(
                                                    index);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: controller
                                                            .stationListSelected
                                                            .value ==
                                                        index
                                                    ? ColorTheme.blueColor
                                                    : ColorTheme.whiteColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 7),
                                              child: Text(
                                                controller.reportList[index],
                                                style: TextStyle(
                                                  color: controller
                                                              .stationListSelected
                                                              .value ==
                                                          index
                                                      ? ColorTheme.whiteColor
                                                      : ColorTheme.greyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Obx(
                                () => Text(
                                  '${controller.getDateRangeForSales(controller.stationListSelected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.stationListSelected.value)["endDate"]}',
                                  style: const TextStyle(
                                    color: ColorTheme.greyColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () {
                                if (controller.isLoadingStationSales.value) {
                                  return const Center(
                                      child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: CircularProgressIndicator(),
                                  ));
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        controller.allStationSalesData.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final items =
                                          controller.allStationSalesData[index];

                                      final totalValue = double.parse(controller
                                          .stationSales.value
                                          .toString()
                                          .replaceAll(',', ''));
                                      double progressValue = totalValue == 0
                                          ? 0
                                          : double.parse(
                                                  (controller.allStationSalesData[
                                                              index]["price"]
                                                          ["total_price"])
                                                      .toString()
                                                      .replaceAll(',', '')) /
                                              totalValue;

                                      return Row(
                                        children: [
                                          const CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              AppConstants.networkImage,
                                            ),
                                            radius: 30,
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            height: 70,
                                            width: 1,
                                            color: ColorTheme.greyColor,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  items["station_name"]
                                                      as String,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: ColorTheme.greyColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Stack(
                                                        children: [
                                                          SizedBox(
                                                            height: 25,
                                                            child:
                                                                LinearProgressIndicator(
                                                              value:
                                                                  progressValue,
                                                              backgroundColor:
                                                                  ColorTheme
                                                                      .greyColor
                                                                      .withOpacity(
                                                                          0.2),
                                                              color: ColorTheme
                                                                  .greenColor,
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 2,
                                                                      left:
                                                                          8.0),
                                                              child: Text(
                                                                Get.find<AuthController>()
                                                                            .profileModel
                                                                            ?.restaurants
                                                                            ?.first
                                                                            .resturantType ==
                                                                        'Restaurant'
                                                                    ? "₹ ${items["price"]['total_price'].toString()}"
                                                                    : '0.00',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  color: ColorTheme
                                                                      .whiteColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 7),
                                                    Obx(
                                                      () => controller
                                                                  .isLoadingStationSales
                                                                  .value ==
                                                              false
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                Get.to(() =>
                                                                    MostStationSalesItem(
                                                                      name: items[
                                                                              "station_name"]
                                                                          as String,
                                                                      selectedTabIndex: controller
                                                                          .stationListSelected
                                                                          .value,
                                                                    ));
                                                              },
                                                              child: Text(
                                                                "View All",
                                                                style: TextStyle(
                                                                    color: ColorTheme
                                                                        .greyColor,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),

                            /// Top Item
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                color: ColorTheme.greyColor,
                                thickness: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                'Top 4 Most Sold Items',
                                style: TextStyle(
                                  color: ColorTheme.greyColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: ColorTheme.whiteColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Obx(
                                  () => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      controller.reportList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            controller.topSoldListItemSelected
                                                .value = index;
                                            controller.setDateRange(
                                                controller.reportList[index],
                                                section: 'items');
                                            controller.topSoldItems(
                                                controller.itemsFromDate.value,
                                                controller.itemsToDate.value);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: controller
                                                            .topSoldListItemSelected
                                                            .value ==
                                                        index
                                                    ? ColorTheme.blueColor
                                                    : ColorTheme.whiteColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 7),
                                              child: Text(
                                                controller.reportList[index],
                                                style: TextStyle(
                                                  color: controller
                                                              .topSoldListItemSelected
                                                              .value ==
                                                          index
                                                      ? ColorTheme.whiteColor
                                                      : ColorTheme.greyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  '${controller.getDateRangeForSales(controller.topSoldListItemSelected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.topSoldListItemSelected.value)["endDate"]}',
                                  style: const TextStyle(
                                    color: ColorTheme.greyColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () {
                                if (controller.isLoadingSoldItem.value) {
                                  return const Center(
                                      child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: CircularProgressIndicator(),
                                  ));
                                } else {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      // Two items per row
                                      crossAxisSpacing: 0,
                                      mainAxisSpacing: 0,
                                      childAspectRatio: 0.8,
                                      mainAxisExtent: 170,
                                    ),
                                    itemCount:
                                        controller.topSoldItemsList.length > 3
                                            ? 4
                                            : controller
                                                .topSoldItemsList.length,
                                    itemBuilder: (context, index) {
                                      int totalItems =
                                          controller.topSoldItemsList.length > 3
                                              ? 4
                                              : controller
                                                  .topSoldItemsList.length;

                                      bool isLastColumn = (index % 2 == 1);
                                      bool isLastRow = index >= totalItems - 2;

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: isLastColumn
                                                ? BorderSide.none
                                                : BorderSide(
                                                    color: ColorTheme.greyColor
                                                        .withOpacity(0.2),
                                                    // Divider color
                                                    width:
                                                        1, // Divider thickness
                                                  ),
                                            bottom: isLastRow
                                                ? BorderSide.none
                                                : BorderSide(
                                                    color: ColorTheme.greyColor
                                                        .withOpacity(0.2),
                                                    // Divider color
                                                    width:
                                                        1, // Divider thickness
                                                  ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    AppConstants.networkImage),
                                                radius: 32,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "${controller.topSoldItemsList[index]['food_item']}",
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ColorTheme.greyColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${controller.topSoldItemsList[index]['total_quantity']} ",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color:
                                                          ColorTheme.greenColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    " Sold",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          ColorTheme.blueColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                            Obx(
                              () => controller.isLoadingSoldItem.value == false
                                  ? GestureDetector(
                                      onTap: () {
                                        Get.to(() => MostSoldItem(
                                              selectedTabIndex: controller
                                                  .topSoldListItemSelected
                                                  .value,
                                            ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 20, left: 15),
                                        child: Container(
                                          height: 30,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              color: ColorTheme.blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "View All",
                                            style: TextStyle(
                                              color: ColorTheme.whiteColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ),

                            /// Top Category

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                color: ColorTheme.greyColor,
                                thickness: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                'Top 4 Most Sold Category',
                                style: TextStyle(
                                  color: ColorTheme.greyColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: ColorTheme.whiteColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Obx(
                                  () => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      controller.reportList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            controller
                                                .topSoldListCategorySelected
                                                .value = index;
                                            controller.setDateRange(
                                                controller.reportList[index],
                                                section: 'category');
                                            controller.topSoldCategory(index);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: controller
                                                            .topSoldListCategorySelected
                                                            .value ==
                                                        index
                                                    ? ColorTheme.blueColor
                                                    : ColorTheme.whiteColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 7),
                                              child: Text(
                                                controller.reportList[index],
                                                style: TextStyle(
                                                  color: controller
                                                              .topSoldListCategorySelected
                                                              .value ==
                                                          index
                                                      ? ColorTheme.whiteColor
                                                      : ColorTheme.greyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  '${controller.getDateRangeForSales(controller.topSoldListCategorySelected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.topSoldListCategorySelected.value)["endDate"]}',
                                  style: const TextStyle(
                                    color: ColorTheme.greyColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () {
                                if (controller.isLoadingCategory.value) {
                                  return const Center(
                                      child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: CircularProgressIndicator(),
                                  ));
                                } else {
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 0,
                                      mainAxisSpacing: 0,
                                      childAspectRatio: 0.8,
                                      mainAxisExtent: 150,
                                    ),
                                    itemCount:
                                        controller.topSalesCategoryList.length >
                                                3
                                            ? 4
                                            : controller
                                                .topSalesCategoryList.length,
                                    itemBuilder: (context, index) {
                                      int totalItems = controller
                                                  .topSalesCategoryList.length >
                                              3
                                          ? 4
                                          : controller
                                              .topSalesCategoryList.length;

                                      bool isLastColumn = (index % 2 == 1);
                                      bool isLastRow = index >= totalItems - 2;

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: isLastColumn
                                                ? BorderSide.none
                                                : BorderSide(
                                                    color: ColorTheme.greyColor
                                                        .withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                            bottom: isLastRow
                                                ? BorderSide.none
                                                : BorderSide(
                                                    color: ColorTheme.greyColor
                                                        .withOpacity(0.2),
                                                    // Divider color
                                                    width:
                                                        1, // Divider thickness
                                                  ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    AppConstants.networkImage),
                                                radius: 32,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "${controller.topSalesCategoryList[index]['category_name']}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ColorTheme.greyColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${controller.topSalesCategoryList[index]['total_quantity']} ",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color:
                                                          ColorTheme.greenColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    " Sold",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          ColorTheme.blueColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                            Obx(
                              () => controller.isLoadingCategory.value == false
                                  ? GestureDetector(
                                      onTap: () {
                                        // Get.to(() => MostSoldCategory());
                                        Get.to(() => MostSoldCategory(
                                              selectedTabIndex: controller
                                                  .topSoldListCategorySelected
                                                  .value,
                                            ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 20, left: 15),
                                        child: Container(
                                          height: 30,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              color: ColorTheme.blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "View All",
                                            style: TextStyle(
                                              color: ColorTheme.whiteColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                color: ColorTheme.greyColor,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 15),
                      //   child: Text(
                      //     'Station Sales',
                      //     style: TextStyle(
                      //       color: ColorTheme.greyColor,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: ColorTheme.whiteColor,
                      //     borderRadius: BorderRadius.circular(15),
                      //   ),
                      //   child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(15),
                      //     child: Obx(
                      //       () => Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: List.generate(
                      //           controller.reportList.length,
                      //           (index) {
                      //             return GestureDetector(
                      //               onTap: () {
                      //                 controller.stationListSelected.value =
                      //                     index;
                      //                 controller.setDateRange(
                      //                     controller.reportList[index],
                      //                     section: 'station');
                      //                 controller
                      //                     .stationSalesRevenueReport(index);
                      //               },
                      //               child: Container(
                      //                 decoration: BoxDecoration(
                      //                     color: controller.stationListSelected
                      //                                 .value ==
                      //                             index
                      //                         ? ColorTheme.blueColor
                      //                         : ColorTheme.whiteColor),
                      //                 child: Padding(
                      //                   padding: const EdgeInsets.symmetric(
                      //                       horizontal: 25, vertical: 7),
                      //                   child: Text(
                      //                     controller.reportList[index],
                      //                     style: TextStyle(
                      //                       color: controller
                      //                                   .stationListSelected
                      //                                   .value ==
                      //                               index
                      //                           ? ColorTheme.whiteColor
                      //                           : ColorTheme.greyColor,
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 12,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 10),
                      //   child: Obx(
                      //     () => Text(
                      //       '${controller.getDateRangeForSales(controller.stationListSelected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.stationListSelected.value)["endDate"]}',
                      //       style: const TextStyle(
                      //         color: ColorTheme.greyColor,
                      //         fontSize: 10,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Obx(
                      //   () {
                      //     if (controller.isLoadingStationSales.value) {
                      //       return const Center(
                      //           child: Padding(
                      //         padding: EdgeInsets.symmetric(vertical: 20),
                      //         child: CircularProgressIndicator(),
                      //       ));
                      //     } else {
                      //       return ListView.builder(
                      //         shrinkWrap: true,
                      //         itemCount: controller.allStationSalesData.length,
                      //         physics: const NeverScrollableScrollPhysics(),
                      //         itemBuilder: (context, index) {
                      //           final items =
                      //               controller.allStationSalesData[index];

                      //           final totalValue = double.parse(controller
                      //               .stationSales.value
                      //               .toString()
                      //               .replaceAll(',', ''));
                      //           double progressValue = totalValue == 0
                      //               ? 0
                      //               : double.parse((controller
                      //                               .allStationSalesData[index]
                      //                           ["price"]["total_price"])
                      //                       .toString()
                      //                       .replaceAll(',', '')) /
                      //                   totalValue;

                      //           return Row(
                      //             children: [
                      //               const CircleAvatar(
                      //                 backgroundImage: NetworkImage(
                      //                   AppConstants.networkImage,
                      //                 ),
                      //                 radius: 30,
                      //               ),
                      //               const SizedBox(width: 10),
                      //               Container(
                      //                 height: 70,
                      //                 width: 1,
                      //                 color: ColorTheme.greyColor,
                      //               ),
                      //               const SizedBox(width: 10),
                      //               Expanded(
                      //                 child: Column(
                      //                   crossAxisAlignment:
                      //                       CrossAxisAlignment.start,
                      //                   children: [
                      //                     Text(
                      //                       items["station_name"] as String,
                      //                       style: const TextStyle(
                      //                         fontSize: 14,
                      //                         color: ColorTheme.greyColor,
                      //                         fontWeight: FontWeight.bold,
                      //                       ),
                      //                     ),
                      //                     const SizedBox(height: 5),
                      //                     Row(
                      //                       children: [
                      //                         Expanded(
                      //                           child: Stack(
                      //                             children: [
                      //                               SizedBox(
                      //                                 height: 25,
                      //                                 child:
                      //                                     LinearProgressIndicator(
                      //                                   value: progressValue,
                      //                                   backgroundColor:
                      //                                       ColorTheme.greyColor
                      //                                           .withOpacity(
                      //                                               0.2),
                      //                                   color: ColorTheme
                      //                                       .greenColor,
                      //                                 ),
                      //                               ),
                      //                               Align(
                      //                                 alignment:
                      //                                     Alignment.centerLeft,
                      //                                 child: Padding(
                      //                                   padding:
                      //                                       const EdgeInsets
                      //                                           .only(
                      //                                           top: 2,
                      //                                           left: 8.0),
                      //                                   child: Text(
                      //                                Get.find<AuthController>()
                      //                   .profileModel
                      //                   ?.restaurants
                      //                   ?.first
                      //                   .resturantType == 'Restaurant' ?     "₹ ${items["price"]['total_price'].toString()}" : '0.00',
                      //                                     style:
                      //                                         const TextStyle(
                      //                                       fontSize: 14,
                      //                                       color: ColorTheme
                      //                                           .whiteColor,
                      //                                       fontWeight:
                      //                                           FontWeight.bold,
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                         SizedBox(width: 7),
                      //                         Obx(
                      //                           () => controller
                      //                                       .isLoadingStationSales
                      //                                       .value ==
                      //                                   false
                      //                               ? GestureDetector(
                      //                                   onTap: () {
                      //                                     Get.to(() =>
                      //                                         MostStationSalesItem(
                      //                                           name: items[
                      //                                                   "station_name"]
                      //                                               as String,
                      //                                           selectedTabIndex:
                      //                                               controller
                      //                                                   .stationListSelected
                      //                                                   .value,
                      //                                         ));
                      //                                   },
                      //                                   child: Text(
                      //                                     "View All",
                      //                                     style: TextStyle(
                      //                                         color: ColorTheme
                      //                                             .greyColor,
                      //                                         fontSize: 12,
                      //                                         fontWeight:
                      //                                             FontWeight
                      //                                                 .bold),
                      //                                   ),
                      //                                 )
                      //                               : SizedBox(),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ],
                      //           );
                      //         },
                      //       );
                      //     }
                      //   },
                      // ),

                      // /// Top Item
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 8),
                      //   child: Divider(
                      //     color: ColorTheme.greyColor,
                      //     thickness: 1,
                      //   ),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 15),
                      //   child: Text(
                      //     'Top 4 Most Sold Items',
                      //     style: TextStyle(
                      //       color: ColorTheme.greyColor,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: ColorTheme.whiteColor,
                      //     borderRadius: BorderRadius.circular(15),
                      //   ),
                      //   child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(15),
                      //     child: Obx(
                      //       () => Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: List.generate(
                      //           controller.reportList.length,
                      //           (index) {
                      //             return GestureDetector(
                      //               onTap: () {
                      //                 controller.topSoldListItemSelected.value =
                      //                     index;
                      //                 controller.setDateRange(
                      //                     controller.reportList[index],
                      //                     section: 'items');
                      //                 controller.topSoldItems(
                      //                     controller.itemsFromDate.value,
                      //                     controller.itemsToDate.value);
                      //               },
                      //               child: Container(
                      //                 decoration: BoxDecoration(
                      //                     color: controller
                      //                                 .topSoldListItemSelected
                      //                                 .value ==
                      //                             index
                      //                         ? ColorTheme.blueColor
                      //                         : ColorTheme.whiteColor),
                      //                 child: Padding(
                      //                   padding: const EdgeInsets.symmetric(
                      //                       horizontal: 25, vertical: 7),
                      //                   child: Text(
                      //                     controller.reportList[index],
                      //                     style: TextStyle(
                      //                       color: controller
                      //                                   .topSoldListItemSelected
                      //                                   .value ==
                      //                               index
                      //                           ? ColorTheme.whiteColor
                      //                           : ColorTheme.greyColor,
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 12,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Obx(
                      //   () => Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 10),
                      //     child: Text(
                      //       '${controller.getDateRangeForSales(controller.topSoldListItemSelected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.topSoldListItemSelected.value)["endDate"]}',
                      //       style: const TextStyle(
                      //         color: ColorTheme.greyColor,
                      //         fontSize: 10,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Obx(
                      //   () {
                      //     if (controller.isLoadingSoldItem.value) {
                      //       return const Center(
                      //           child: Padding(
                      //         padding: EdgeInsets.symmetric(vertical: 20),
                      //         child: CircularProgressIndicator(),
                      //       ));
                      //     } else {
                      //       return GridView.builder(
                      //         shrinkWrap: true,
                      //         physics: const NeverScrollableScrollPhysics(),
                      //         gridDelegate:
                      //             const SliverGridDelegateWithFixedCrossAxisCount(
                      //           crossAxisCount: 2,
                      //           // Two items per row
                      //           crossAxisSpacing: 0,
                      //           mainAxisSpacing: 0,
                      //           childAspectRatio: 0.8,
                      //           mainAxisExtent: 170,
                      //         ),
                      //         itemCount: controller.topSoldItemsList.length > 3
                      //             ? 4
                      //             : controller.topSoldItemsList.length,
                      //         itemBuilder: (context, index) {
                      //           int totalItems =
                      //               controller.topSoldItemsList.length > 3
                      //                   ? 4
                      //                   : controller.topSoldItemsList.length;

                      //           bool isLastColumn = (index % 2 == 1);
                      //           bool isLastRow = index >= totalItems - 2;

                      //           return Container(
                      //             decoration: BoxDecoration(
                      //               border: Border(
                      //                 right: isLastColumn
                      //                     ? BorderSide.none
                      //                     : BorderSide(
                      //                         color: ColorTheme.greyColor
                      //                             .withOpacity(0.2),
                      //                         // Divider color
                      //                         width: 1, // Divider thickness
                      //                       ),
                      //                 bottom: isLastRow
                      //                     ? BorderSide.none
                      //                     : BorderSide(
                      //                         color: ColorTheme.greyColor
                      //                             .withOpacity(0.2),
                      //                         // Divider color
                      //                         width: 1, // Divider thickness
                      //                       ),
                      //               ),
                      //             ),
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 20, vertical: 10),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   const CircleAvatar(
                      //                     backgroundImage: NetworkImage(
                      //                         AppConstants.networkImage),
                      //                     radius: 32,
                      //                   ),
                      //                   const SizedBox(height: 10),
                      //                   Text(
                      //                     "${controller.topSoldItemsList[index]['food_item']}",
                      //                     maxLines: 2,
                      //                     style: const TextStyle(
                      //                       fontSize: 14,
                      //                       color: ColorTheme.greyColor,
                      //                       fontWeight: FontWeight.bold,
                      //                     ),
                      //                   ),
                      //                   Row(
                      //                     children: [
                      //                       Text(
                      //                         "${controller.topSoldItemsList[index]['total_quantity']} ",
                      //                         style: const TextStyle(
                      //                           fontSize: 18,
                      //                           color: ColorTheme.greenColor,
                      //                           fontWeight: FontWeight.bold,
                      //                         ),
                      //                       ),
                      //                       const Text(
                      //                         " Sold",
                      //                         style: TextStyle(
                      //                           fontSize: 14,
                      //                           color: ColorTheme.blueColor,
                      //                           fontWeight: FontWeight.w600,
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       );
                      //     }
                      //   },
                      // ),
                      // Obx(
                      //   () => controller.isLoadingSoldItem.value == false
                      //       ? GestureDetector(
                      //           onTap: () {
                      //             Get.to(() => MostSoldItem(
                      //                   selectedTabIndex: controller
                      //                       .topSoldListItemSelected.value,
                      //                 ));
                      //           },
                      //           child: Padding(
                      //             padding: const EdgeInsets.only(
                      //                 bottom: 20, left: 15),
                      //             child: Container(
                      //               height: 30,
                      //               width: 100,
                      //               decoration: BoxDecoration(
                      //                   color: ColorTheme.blueColor,
                      //                   borderRadius:
                      //                       BorderRadius.circular(10)),
                      //               alignment: Alignment.center,
                      //               child: const Text(
                      //                 "View All",
                      //                 style: TextStyle(
                      //                   color: ColorTheme.whiteColor,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         )
                      //       : const SizedBox(),
                      // ),

                      // /// Top Category

                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 8),
                      //   child: Divider(
                      //     color: ColorTheme.greyColor,
                      //     thickness: 1,
                      //   ),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 15),
                      //   child: Text(
                      //     'Top 4 Most Sold Category',
                      //     style: TextStyle(
                      //       color: ColorTheme.greyColor,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: ColorTheme.whiteColor,
                      //     borderRadius: BorderRadius.circular(15),
                      //   ),
                      //   child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(15),
                      //     child: Obx(
                      //       () => Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: List.generate(
                      //           controller.reportList.length,
                      //           (index) {
                      //             return GestureDetector(
                      //               onTap: () {
                      //                 controller.topSoldListCategorySelected
                      //                     .value = index;
                      //                 controller.setDateRange(
                      //                     controller.reportList[index],
                      //                     section: 'category');
                      //                 controller.topSoldCategory(index);
                      //               },
                      //               child: Container(
                      //                 decoration: BoxDecoration(
                      //                     color: controller
                      //                                 .topSoldListCategorySelected
                      //                                 .value ==
                      //                             index
                      //                         ? ColorTheme.blueColor
                      //                         : ColorTheme.whiteColor),
                      //                 child: Padding(
                      //                   padding: const EdgeInsets.symmetric(
                      //                       horizontal: 25, vertical: 7),
                      //                   child: Text(
                      //                     controller.reportList[index],
                      //                     style: TextStyle(
                      //                       color: controller
                      //                                   .topSoldListCategorySelected
                      //                                   .value ==
                      //                               index
                      //                           ? ColorTheme.whiteColor
                      //                           : ColorTheme.greyColor,
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 12,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Obx(
                      //   () => Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 10),
                      //     child: Text(
                      //       '${controller.getDateRangeForSales(controller.topSoldListCategorySelected.value)["startDate"]} - ${controller.getDateRangeForSales(controller.topSoldListCategorySelected.value)["endDate"]}',
                      //       style: const TextStyle(
                      //         color: ColorTheme.greyColor,
                      //         fontSize: 10,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Obx(
                      //   () {
                      //     if (controller.isLoadingCategory.value) {
                      //       return const Center(
                      //           child: Padding(
                      //         padding: EdgeInsets.symmetric(vertical: 20),
                      //         child: CircularProgressIndicator(),
                      //       ));
                      //     } else {
                      //       return GridView.builder(
                      //         shrinkWrap: true,
                      //         physics: const NeverScrollableScrollPhysics(),
                      //         gridDelegate:
                      //             const SliverGridDelegateWithFixedCrossAxisCount(
                      //           crossAxisCount: 2,
                      //           crossAxisSpacing: 0,
                      //           mainAxisSpacing: 0,
                      //           childAspectRatio: 0.8,
                      //           mainAxisExtent: 150,
                      //         ),
                      //         itemCount:
                      //             controller.topSalesCategoryList.length > 3
                      //                 ? 4
                      //                 : controller.topSalesCategoryList.length,
                      //         itemBuilder: (context, index) {
                      //           int totalItems =
                      //               controller.topSalesCategoryList.length > 3
                      //                   ? 4
                      //                   : controller
                      //                       .topSalesCategoryList.length;

                      //           bool isLastColumn = (index % 2 == 1);
                      //           bool isLastRow = index >= totalItems - 2;

                      //           return Container(
                      //             decoration: BoxDecoration(
                      //               border: Border(
                      //                 right: isLastColumn
                      //                     ? BorderSide.none
                      //                     : BorderSide(
                      //                         color: ColorTheme.greyColor
                      //                             .withOpacity(0.2),
                      //                         width: 1,
                      //                       ),
                      //                 bottom: isLastRow
                      //                     ? BorderSide.none
                      //                     : BorderSide(
                      //                         color: ColorTheme.greyColor
                      //                             .withOpacity(0.2),
                      //                         // Divider color
                      //                         width: 1, // Divider thickness
                      //                       ),
                      //               ),
                      //             ),
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 20, vertical: 10),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   const CircleAvatar(
                      //                     backgroundImage: NetworkImage(
                      //                         AppConstants.networkImage),
                      //                     radius: 32,
                      //                   ),
                      //                   const SizedBox(height: 10),
                      //                   Text(
                      //                     "${controller.topSalesCategoryList[index]['category_name']}",
                      //                     overflow: TextOverflow.ellipsis,
                      //                     maxLines: 1,
                      //                     style: const TextStyle(
                      //                       fontSize: 14,
                      //                       color: ColorTheme.greyColor,
                      //                       fontWeight: FontWeight.bold,
                      //                     ),
                      //                   ),
                      //                   Row(
                      //                     children: [
                      //                       Text(
                      //                         "${controller.topSalesCategoryList[index]['total_quantity']} ",
                      //                         style: const TextStyle(
                      //                           fontSize: 18,
                      //                           color: ColorTheme.greenColor,
                      //                           fontWeight: FontWeight.bold,
                      //                         ),
                      //                       ),
                      //                       const Text(
                      //                         " Sold",
                      //                         style: TextStyle(
                      //                           fontSize: 14,
                      //                           color: ColorTheme.blueColor,
                      //                           fontWeight: FontWeight.w600,
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       );
                      //     }
                      //   },
                      // ),
                      // Obx(
                      //   () => controller.isLoadingCategory.value == false
                      //       ? GestureDetector(
                      //           onTap: () {
                      //             // Get.to(() => MostSoldCategory());
                      //             Get.to(() => MostSoldCategory(
                      //                   selectedTabIndex: controller
                      //                       .topSoldListCategorySelected.value,
                      //                 ));
                      //           },
                      //           child: Padding(
                      //             padding: const EdgeInsets.only(
                      //                 bottom: 20, left: 15),
                      //             child: Container(
                      //               height: 30,
                      //               width: 100,
                      //               decoration: BoxDecoration(
                      //                   color: ColorTheme.blueColor,
                      //                   borderRadius:
                      //                       BorderRadius.circular(10)),
                      //               alignment: Alignment.center,
                      //               child: const Text(
                      //                 "View All",
                      //                 style: TextStyle(
                      //                   color: ColorTheme.whiteColor,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         )
                      //       : const SizedBox(),
                      // ),

                      /// Top Cancelled Items
                      // if (Get.find<AuthController>()
                      //     .profileModel!
                      //     .role!
                      //     .contains('cancellation_report'))
                      //   const Padding(
                      //     padding: EdgeInsets.symmetric(vertical: 8),
                      //     child: Divider(
                      //       color: ColorTheme.greyColor,
                      //       thickness: 1,
                      //     ),
                      //   ),
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('cancellation_report'))
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            'Top Cancelled Items',
                            style: TextStyle(
                              color: ColorTheme.greyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('cancellation_report'))
                        Container(
                          decoration: BoxDecoration(
                            color: ColorTheme.whiteColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Obx(
                              () => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  controller.reportList.length,
                                  (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        controller.topCancelledItemsSelect
                                            .value = index;
                                        controller.setDateRange(
                                            controller.reportList[index],
                                            section: 'cancelled');
                                        controller.topCancelItems(index);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: controller
                                                      .topCancelledItemsSelect
                                                      .value ==
                                                  index
                                              ? ColorTheme.blueColor
                                              : ColorTheme.whiteColor,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25, vertical: 7),
                                          child: Text(
                                            controller.reportList[index],
                                            style: TextStyle(
                                              color: controller
                                                          .topCancelledItemsSelect
                                                          .value ==
                                                      index
                                                  ? ColorTheme.whiteColor
                                                  : ColorTheme.greyColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('cancellation_report'))
                        Obx(
                          () => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              '${controller.getDateRangeForSales(controller.topCancelledItemsSelect.value)["startDate"]} - ${controller.getDateRangeForSales(controller.topCancelledItemsSelect.value)["endDate"]}',
                              style: const TextStyle(
                                color: ColorTheme.greyColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('cancellation_report'))
                        Obx(
                          () {
                            if (controller.isLoadingTopCancelledItems.value) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ));
                            } else {
                              return controller.topCancelledItems.isEmpty
                                  ? const SizedBox()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: DataTable(
                                        columnSpacing: 15,
                                        dataRowHeight: 70,
                                        horizontalMargin: 0,
                                        border: TableBorder(
                                            verticalInside: BorderSide(
                                                color: ColorTheme.greyColor
                                                    .withOpacity(0.5))),
                                        showBottomBorder: true,
                                        columns: const [
                                          DataColumn(
                                            label: Expanded(
                                              flex: 6,
                                              child: Text(
                                                "Food Name",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorTheme.blueColor,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Count",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorTheme.blueColor,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Amount",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorTheme.blueColor,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: controller.topCancelledItems
                                            .take(4)
                                            .map((item) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    const CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              AppConstants
                                                                  .networkImage),
                                                      radius: 18,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        item['food_item'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: ColorTheme
                                                              .greyColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    item['quantity'].toString(),
                                                    style: const TextStyle(
                                                      color:
                                                          ColorTheme.greenColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Text(
                                                    Get.find<AuthController>()
                                                                .profileModel
                                                                ?.restaurants
                                                                ?.first
                                                                .resturantType ==
                                                            'Restaurant'
                                                        ? item['price']
                                                            .toString()
                                                        : '0.00',
                                                    style: const TextStyle(
                                                      color:
                                                          ColorTheme.greenColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    );
                            }
                          },
                        ),
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('cancellation_report'))
                        const SizedBox(height: 10),
                      if (Get.find<AuthController>()
                          .profileModel!
                          .role!
                          .contains('cancellation_report'))
                        Obx(
                          () => controller.isLoadingTopCancelledItems.value ==
                                  false
                              ? GestureDetector(
                                  onTap: () {
                                    Get.to(() => MostCancelItems(
                                          selectedTabIndex: controller
                                              .topCancelledItemsSelect.value,
                                        ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 20, left: 15),
                                    child: Container(
                                      height: 30,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: ColorTheme.blueColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "View All",
                                        style: TextStyle(
                                          color: ColorTheme.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSection(String title, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: ColorTheme.blackColor,
              ),
            ),
            Text(
              Get.find<AuthController>()
                          .profileModel
                          ?.restaurants
                          ?.first
                          .resturantType ==
                      'Restaurant'
                  ? value
                  : '0.00',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: ColorTheme.blackColor,
              ),
            ),
          ],
        ),
        // const Divider(),
      ],
    ),
  );
}

Widget buildHeader(String title, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ColorTheme.blackColor,
          ),
        ),
        Text(
          Get.find<AuthController>()
                      .profileModel
                      ?.restaurants
                      ?.first
                      .resturantType ==
                  'Restaurant'
              ? value
              : '0.00',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: ColorTheme.blackColor,
          ),
        ),
      ],
    ),
  );
}

// class CustomLogoutDialog extends StatelessWidget {
//   ReportSummeryController controller;
//   CustomLogoutDialog({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           color: Colors.white),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding:
//               const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 20),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Image.asset("assets/images/support.png",
//                 width: 50, height: 50, color: const Color(0xFFF26B33)),
//             const Padding(
//               padding: EdgeInsets.all(20),
//               child: Text(
//                 "Are you sure you want to logout from My Genie?",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Get.back();
//                   },
//                   child: Container(
//                     width: 100,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFC6C6C6),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     alignment: Alignment.center,
//                     child: const Text(
//                       "No",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 GestureDetector(
//                   onTap: () async {
//                     await controller.logOut();
//                     controller.dispose();
//                   },
//                   child: Container(
//                     width: 100,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF26B33),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     alignment: Alignment.center,
//                     child: const Text(
//                       "Yes",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }
