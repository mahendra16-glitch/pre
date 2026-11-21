import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mygenie_restaurant/controller/update_widget_controller.dart';
import 'package:mygenie_restaurant/view/screens/billing/widget/print_order_dialog.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/view_paid_orders.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/custom_package/super_tooltip/super_tooltip.dart';
import 'package:mygenie_restaurant/data/model/body/bluetoothPrinterBody.dart';
import 'package:mygenie_restaurant/data/model/response/cart_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/data/model/response/save_local_oreder_response.dart';
import 'package:mygenie_restaurant/helper/price_converter.dart';
import 'package:mygenie_restaurant/helper/printer_config.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:mygenie_restaurant/view/screens/billing/checkout_screen.dart';
import 'package:mygenie_restaurant/view/screens/billing/paid_order/view_paid_orders.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/revenue_report.dart';
import 'package:mygenie_restaurant/view/screens/settelment_report/settelment_report.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/helper/date_converter.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/view/screens/waiter/get_printer_ip/get_printer_ip.dart';
import 'package:mygenie_restaurant/view/screens/waiter/waiter_product_list/widget/product_widget.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/util/print_byte_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/ios_print_transport.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_target.dart';
import 'package:upgrader/upgrader.dart';
import 'package:http/http.dart' as http;

class BillingHomeScreen extends StatefulWidget {
  @override
  State<BillingHomeScreen> createState() => _BillingHomeScreenState();
}

class _BillingHomeScreenState extends State<BillingHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<LocalOrderModel> orderList = [];
  late final StreamSubscription<ConnectivityResult> _subscription;

  bool isCollaps = false;
  bool isOpenedDropdown = false;
  List<String> orderTypeList = [
    'All',
    'Dine In',
    // 'Take Away',
    // 'Delivery',
    // 'Room'
  ];
  late PackageInfo packageInfo;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _dropdownContoller = SuperTooltipController();

  final _controller = SuperTooltipController();
  final _tableController = SuperTooltipController();

  List<Product> products = [];
  final TextEditingController searchController = TextEditingController();

  late final StreamSubscription<BTStatus> _subscriptionBtStatus;
  final PrinterManager _printerManager = PrinterManager.instance;
  List<List<CartModel>> cartProductList = [];
  List<List<CartModel>> failedCartProductList = [];
  int currentPrintIndex = 0;
  bool isConnect = true;
  List<int>? pendingTask;
  bool isFailedPrint = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    _subscriptionBtStatus.cancel();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.find<RestaurantController>().posFoodCategoryList.isEmpty) {
        Get.find<RestaurantController>().getProductCategoryListFromLocal(
            Get.find<AuthController>().getProductCategoryList());
        // Get.find<RestaurantController>().setCategoryList();
      }
      Get.find<RestaurantController>().setPOSWaiterCategoryIndex(0);
      if (Get.find<RestaurantController>().productList.isEmpty) {
        Get.find<RestaurantController>().getProductListFromLocal(
            Get.find<AuthController>().getProductList());
      }
      // if (Get.find<AuthController>().employeeList.isEmpty) {
      //   Get.find<AuthController>().getEmployeeListFromLocal(
      //       Get.find<AuthController>().convertEmployeeListFromLocal());
      // }
      Get.find<AuthController>().setEmployeeIndex(null);
      Get.find<CartController>().calculationCart();
      products = Get.find<AuthController>().getProductList();
      Get.find<RestaurantController>().update();
      orderList = await Get.find<CartController>().getOrderListFromLocally();

      Get.find<UpdateWidgetController>()
          .updateInternetStatus(await hasInternetConnection());

      // _subscription =
      //     Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
      // await listenBlutooth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return
        UpgradeAlert(
          upgrader: Upgrader(durationUntilAlertAgain: Duration(seconds: 5)),
          child:
        Scaffold(
            appBar: AppBar(
              // toolbarHeight: Get.height / 10.72,
              backgroundColor: Theme.of(context).cardColor,
              leading: Padding(
                padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                child: IconButton(
                  icon: Image.asset(Images.menu,
                      color: ColorTheme.appColor, height: 16),
                  onPressed: () {
                    searchController.clear();
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              titleSpacing: 0,
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(logoHelper.appLogo!, width: Get.width * 0.3),
              ),
              //     Image.asset(Images.ic_kds_app_logo, width: Get.width * 0.4),
              actions: [
                SizedBox(
                  height: 10,
                  child: GetBuilder<CartController>(builder: (posController) {
                    return posController.cartList.isEmpty
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Get.find<CartController>().clearCartList();
                              products =
                                  Get.find<AuthController>().getProductList();

                              // Get.find<RestaurantController>()
                              //     .getWaiterProductList('1', 'all');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(
                                  right: 20, top: 13, bottom: 13),
                              height: 10,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color: ColorTheme.appColor),
                              child: Center(
                                child: Text(
                                  'Clear Cart'.tr,
                                  style: poppinsMedium.copyWith(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          );
                  }),
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: Color(0xFFF8F8F8),
              child: SafeArea(
                child: GetBuilder<UpdateWidgetController>(
                    builder: (updateControler) {
                  return Column(
                    // padding: EdgeInsets.zero,

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
                      // Theme(

                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: ColorTheme.hintText,
                          initiallyExpanded: true,
                          expandedAlignment: Alignment.centerLeft,
                          title: Text(
                            'Orders',
                            style: poppinsMedium.copyWith(
                                fontSize: 14, color: ColorTheme.hintText),
                          ),
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                scaffoldKey.currentState?.closeDrawer();
                                FocusManager.instance.primaryFocus?.unfocus();

                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            ViewBillingPaidOrders()));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    'Paid Orders',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                            if (updateControler.isInternetConnection &&
                                orderList.isNotEmpty)
                              InkWell(
                                onTap: () async {
                                  // scaffoldKey.currentState.closeDrawer();
                                  // FocusManager.instance.primaryFocus?.unfocus();
                                  Get.find<CartController>()
                                      .billingSyncOrder(orderList);
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 10),
                                    child: Text(
                                      'Sync Orders',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            if (updateControler.isInternetConnection)
                              InkWell(
                                onTap: () async {
                                  scaffoldKey.currentState?.closeDrawer();
                                  _subscriptionBtStatus.cancel();
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              ViewPaidOrders()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 10),
                                    child: Text(
                                      'View Online Orders',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 15),
                              child: DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineThickness: 1.0,
                                dashLength: 2.5,
                                dashColor: ColorTheme.hintText,
                              ),
                            ),
                          ],
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
                            if (GetPlatform.isIOS)
                              InkWell(
                                onTap: () {
                                  scaffoldKey.currentState?.closeDrawer();
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              GetPrinterIp()));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      'Printer Configuration',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            if (updateControler.isInternetConnection)
                              InkWell(
                                onTap: () {
                                  scaffoldKey.currentState?.closeDrawer();
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  String logo = '';
                                  if (!Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('order') &&
                                      Get.find<AuthController>()
                                          .profileModel!
                                          .role!
                                          .contains('bill')) {
                                    logo = Images.ic_cashier_app_logo;
                                  } else if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('report')) {
                                    logo = Images.ic_owner_app_logo;
                                  } else if (Get.find<AuthController>()
                                      .profileModel!
                                      .role!
                                      .contains('Manager')) {
                                    logo = Images.ic_manager_app_logo;
                                  } else {
                                    logo = Images.ic_waiter_app_logo;
                                  }

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              EmployeeResetPassword(
                                                resetToken:
                                                    Get.find<AuthController>()
                                                        .getUserToken(),
                                                email:
                                                    Get.find<AuthController>()
                                                        .profileModel!
                                                        .empEmail!,
                                                image: logo,
                                                password: '',
                                                fromPasswordChange: true,
                                              ))));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 15,
                                        top: GetPlatform.isIOS ? 10 : 0),
                                    child: Text(
                                      'Reset Password',
                                      style: poppinsMedium.copyWith(
                                          fontSize: 13,
                                          color: ColorTheme.hintText),
                                    ),
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                scaffoldKey.currentState?.closeDrawer();

                                Get.bottomSheet(
                                  ConfirmationDialog(
                                      icon: Images.support,
                                      description:
                                          'Are you sure you want to log out from My Genie?',
                                      isLogOut: true,
                                      onYesPressed: () async {
                                        try {
                                          Get.find<RestaurantController>()
                                              .clearProductList();
                                          Get.find<AuthController>()
                                              .clearSharedData();
                                          Get.offAllNamed(
                                              RouteHelper.getSignInRoute());
                                        } catch (e) {}
                                      }),
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 10),
                                  child: Text(
                                    'Logout',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 13,
                                        color: ColorTheme.hintText),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      ListTile(
                        title: Text(
                          'Version: ${packageInfo.version ?? ''}(${packageInfo.buildNumber ?? ''})',
                          style: poppinsMedium.copyWith(
                              fontSize: 10, color: Colors.grey),
                        ),
                        onTap: () {},
                      ),
                    ],
                  );
                }),
              ),
            ),
            key: scaffoldKey,
            backgroundColor: Colors.white,
            body: SafeArea(
              child:
                  GetBuilder<RestaurantController>(builder: (restController) {
                return GetBuilder<CartController>(builder: (posController) {
                  return posController.isLoading || restController.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            // Divider(),
                            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                              child: Row(
                                children: [
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isShowEmpList ==
                                      'Yes')
                                    Get.find<AuthController>()
                                            .employeeList
                                            .isNotEmpty
                                        ? GetBuilder<AuthController>(
                                            builder: (authController) {
                                            return SuperTooltip(
                                              borderRadius: 2,
                                              // bottom: 50,
                                              hasShadow: false,
                                              borderColor:
                                                  ColorTheme.borderGrey,
                                              // shadowColor: Colors.black
                                              //     .withOpacity(0.1),
                                              showBarrier: true,
                                              controller: _tableController,
                                              borderWidth: 1,
                                              popupDirection:
                                                  TooltipDirection.down,
                                              backgroundColor: Colors.white,
                                              left: 15,
                                              right: Get.width * 0.6 + 25,
                                              arrowTipDistance: 20,
                                              arrowBaseWidth: 0,
                                              arrowLength: 0,
                                              // borderWidth: 2.0,
                                              // showCloseButton:
                                              //     ShowCloseButton.none,
                                              touchThroughAreaShape:
                                                  ClipAreaShape.rectangle,
                                              touchThroughAreaCornerRadius: 5,
                                              minimumOutsideMargin: 0,
                                              barrierColor: Colors.transparent,

                                              content: ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  itemCount: authController
                                                      .employeeList.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return InkWell(
                                                      onTap: () async {
                                                        authController.setEmployeeIndex(
                                                            Get.find<AuthController>()
                                                                    .employeeList[
                                                                index]);
                                                        await _tableController
                                                            .hideTooltip();
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                left: 20,
                                                                bottom: authController.employeeList.length -
                                                                            1 ==
                                                                        index
                                                                    ? 10
                                                                    : 0,
                                                                top: index == 0
                                                                    ? 10
                                                                    : 0),
                                                            child: Text(
                                                              '${authController.employeeList[index].fName}',
                                                              style: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          13,
                                                                      color: ColorTheme
                                                                          .hintText),
                                                            ),
                                                          ),
                                                          if (authController
                                                                      .employeeList
                                                                      .length -
                                                                  1 !=
                                                              index)
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              child: Divider(
                                                                  height: 1,
                                                                  color: ColorTheme
                                                                      .borderGrey),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                              child: Container(
                                                height: 40,
                                                width: Get.width * 0.3,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .PADDING_SIZE_SMALL),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: ColorTheme
                                                          .borderGrey),
                                                  // color: ColorTheme.borderGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        authController
                                                                    .selectedEmployee ==
                                                                null
                                                            ? '${authController.profileModel!.empFname}'
                                                            : '${authController.selectedEmployee!.fName}',
                                                        maxLines: 1,
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          color: ColorTheme
                                                              .hintText,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                        Icons
                                                            .keyboard_arrow_down_rounded,
                                                        color:
                                                            ColorTheme.appColor)
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                        : SizedBox.shrink(),
                                  if (Get.find<AuthController>()
                                          .profileModel!
                                          .restaurants!
                                          .first
                                          .isShowEmpList ==
                                      'Yes')
                                    SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.PADDING_SIZE_SMALL),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorTheme.borderGrey),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: searchController,
                                              textInputAction:
                                                  TextInputAction.search,
                                              autofocus: false,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              keyboardType: TextInputType.name,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 5),
                                                suffixIcon: Icon(Icons.search,
                                                    color: ColorTheme.appColor),
                                                hintText:
                                                    '${Get.find<AuthController>().profileModel!.restaurants!.first.searchFood}',
                                                hintStyle:
                                                    poppinsMedium.copyWith(
                                                        fontSize: 13,
                                                        color: ColorTheme
                                                            .hintText),
                                                filled: true,
                                                fillColor:
                                                    Theme.of(context).cardColor,
                                              ),
                                              style: poppinsMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                              onChanged: (value) async {
                                                if (restController
                                                        .categoryIndex !=
                                                    0)
                                                  restController
                                                      .setPOSWaiterCategoryIndex(
                                                          0);
                                                restController.update();
                                              },
                                            ),
                                          ),
                                          Container(
                                              height: 50,
                                              width: 1,
                                              color: Colors.grey),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: InkWell(
                                              onTap: () async {
                                                await _controller.showTooltip();
                                              },
                                              child: SuperTooltip(
                                                borderRadius: 2,
                                                // bottom: 50,
                                                hasShadow: false,
                                                borderColor:
                                                    ColorTheme.borderGrey,
                                                // shadowColor: Colors.black
                                                //     .withOpacity(0.1),
                                                showBarrier: true,
                                                controller: _controller,
                                                borderWidth: 1,
                                                popupDirection:
                                                    TooltipDirection.down,
                                                backgroundColor: Colors.white,
                                                right: 15,
                                                left: Get.width * 0.3 + 25,
                                                arrowTipDistance: 20,
                                                arrowBaseWidth: 0,
                                                arrowLength: 0,
                                                // borderWidth: 2.0,
                                                // showCloseButton:
                                                //     ShowCloseButton.none,
                                                touchThroughAreaShape:
                                                    ClipAreaShape.rectangle,
                                                touchThroughAreaCornerRadius: 5,
                                                minimumOutsideMargin: 0,
                                                barrierColor:
                                                    Colors.transparent,
                                                content: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount: restController
                                                        .posFoodCategoryList
                                                        .length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return InkWell(
                                                        onTap: () async {
                                                          restController
                                                              .setPOSWaiterCategoryIndex(
                                                                  restController
                                                                      .posFoodCategoryList[
                                                                          index]
                                                                      .id);
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          searchController
                                                              .clear();
                                                          await _controller
                                                              .hideTooltip();
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 20,
                                                                      top: index ==
                                                                              0
                                                                          ? 10
                                                                          : 0,
                                                                      bottom: restController.posFoodCategoryList.length - 1 ==
                                                                              index
                                                                          ? restController.posFoodCategoryList.length > 14
                                                                              ? 50
                                                                              : 15
                                                                          : 0

                                                                      //  restController.posFoodCategoryList.length>14&&
                                                                      ),
                                                              child: Text(
                                                                restController
                                                                    .posFoodCategoryList[
                                                                        index]
                                                                    .name,
                                                                style: poppinsMedium.copyWith(
                                                                    fontSize:
                                                                        13,
                                                                    color: restController.posFoodCategoryList[index].id ==
                                                                            restController
                                                                                .categoryIndex
                                                                        ? ColorTheme
                                                                            .appColor
                                                                        : ColorTheme
                                                                            .hintText),
                                                              ),
                                                            ),
                                                            if (restController
                                                                        .posFoodCategoryList
                                                                        .length -
                                                                    1 !=
                                                                index)
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            10),
                                                                child: Divider(
                                                                    height: 1,
                                                                    color: ColorTheme
                                                                        .borderGrey),
                                                              ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                child: Icon(
                                                    Icons
                                                        .keyboard_arrow_down_outlined,
                                                    color: ColorTheme.appColor),
                                              ),
                                            ),
                                            // Icon(
                                            //     Icons
                                            //         .keyboard_arrow_down_outlined,
                                            //     color: ColorTheme.appColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              child: Divider(
                                color: Color(0xFFE6E6E6),
                                height: 1,
                              ),
                            ),
                            if (MediaQuery.of(context).size.shortestSide < 570)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  height: 33,
                                  child: ListView.builder(
                                    // scrollDirection: Axis.horizontal,
                                    itemCount: restController
                                        .posFoodCategoryList.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          restController
                                              .setPOSWaiterCategoryIndex(
                                                  restController
                                                      .posFoodCategoryList[
                                                          index]
                                                      .id);
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          searchController.clear();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: index == 0 ? 0 : 11),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: restController
                                                            .posFoodCategoryList[
                                                                index]
                                                            .id ==
                                                        restController
                                                            .categoryIndex
                                                    ? ColorTheme.appColor
                                                    : ColorTheme.borderGrey),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            color: restController
                                                        .posFoodCategoryList[
                                                            index]
                                                        .id ==
                                                    restController.categoryIndex
                                                ? ColorTheme.appColor
                                                : Colors.white,
                                          ),
                                          child: Center(
                                            child: Text(
                                              restController
                                                  .posFoodCategoryList[index]
                                                  .name,
                                              style: poppinsMedium.copyWith(
                                                  fontSize: 14,
                                                  color: restController
                                                              .posFoodCategoryList[
                                                                  index]
                                                              .id ==
                                                          restController
                                                              .categoryIndex
                                                      ? Colors.white
                                                      : Colors.grey),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (MediaQuery.of(context).size.shortestSide < 570)
                              SizedBox(height: 20),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (MediaQuery.of(context).size.shortestSide >
                                      570)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: Dimensions.PADDING_SIZE_LARGE,
                                          left:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      height: Get.height,
                                      width: MediaQuery.of(context).size.width >
                                              1600
                                          ? Get.width * 0.15
                                          : Get.width * 0.25,
                                      decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                              248, 248, 248, 1.0),
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.RADIUS_DEFAULT)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL,
                                          horizontal:
                                              Dimensions.PADDING_SIZE_SMALL),
                                      child: ListView.builder(
                                        // scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: restController
                                            .posFoodCategoryList.length,

                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              restController
                                                  .setPOSWaiterCategoryIndex(
                                                      restController
                                                          .posFoodCategoryList[
                                                              index]
                                                          .id);
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              searchController.clear();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .PADDING_SIZE_EXTRA_SMALL,
                                                  vertical: 10),
                                              margin: EdgeInsets.only(
                                                top: Dimensions
                                                    .PADDING_SIZE_DEFAULT,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .RADIUS_DEFAULT),
                                                color: restController
                                                            .posFoodCategoryList[
                                                                index]
                                                            .id ==
                                                        restController
                                                            .categoryIndex
                                                    ? ColorTheme.appColor
                                                    : Colors.white,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  restController
                                                      .posFoodCategoryList[
                                                          index]
                                                      .name,
                                                  style: poppinsRegular.copyWith(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width >
                                                                  1600
                                                              ? 20
                                                              : 14,
                                                      color: restController
                                                                  .posFoodCategoryList[
                                                                      index]
                                                                  .id ==
                                                              restController
                                                                  .categoryIndex
                                                          ? Colors.white
                                                          : Color.fromRGBO(152,
                                                              152, 152, 1.0)),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  Expanded(
                                    // width: Get.width * 0.7,
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      // key: UniqueKey(),
                                      physics: BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15, bottom: 20),
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        return products[index]
                                                    .name!
                                                    .toUpperCase() ==
                                                'CHECK IN'
                                            ? SizedBox.shrink()
                                            : DateConverter.isAvailable(
                                                    products[index]
                                                        .availableTimeStarts!,
                                                    products[index]
                                                        .availableTimeEnds!)
                                                ? products[index]
                                                        .name!
                                                        .toLowerCase()
                                                        .contains(
                                                            searchController
                                                                .text
                                                                .toLowerCase())
                                                    ? restController
                                                            .posFoodCategoryList
                                                            .isEmpty
                                                        ? WaiterProductWidget(
                                                            products: products,
                                                            scrollController:
                                                                _scrollController,
                                                            searchController:
                                                                searchController,
                                                            product:
                                                                products[index],
                                                            index: index,
                                                            length:
                                                                products.length,
                                                            isCampaign: false,
                                                          )
                                                        : restController
                                                                    .categoryIndex ==
                                                                0
                                                            ? WaiterProductWidget(
                                                                products:
                                                                    products,
                                                                scrollController:
                                                                    _scrollController,
                                                                searchController:
                                                                    searchController,
                                                                product:
                                                                    products[
                                                                        index],
                                                                index: index,
                                                                length: products
                                                                    .length,
                                                                isCampaign:
                                                                    false,
                                                              )
                                                            : products[index]
                                                                    .mainCategoryId!
                                                                    .contains(restController
                                                                        .categoryIndex
                                                                        .toString())
                                                                ? WaiterProductWidget(
                                                                    products:
                                                                        products,
                                                                    scrollController:
                                                                        _scrollController,
                                                                    searchController:
                                                                        searchController,
                                                                    product:
                                                                        products[
                                                                            index],
                                                                    index:
                                                                        index,
                                                                    length: products
                                                                        .length,
                                                                    isCampaign:
                                                                        false,
                                                                  )
                                                                : const SizedBox
                                                                    .shrink()
                                                    : SizedBox.shrink()
                                                : SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                });
              }),
            ),
            bottomNavigationBar:
                GetBuilder<CartController>(builder: (cartController) {
              return cartController.cartList.isNotEmpty
                  ? SafeArea(
                      child: Container(
                      height: 65,
                      width: Get.width,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions
                            .PADDING_SIZE_LARGE, /* vertical: Dimensions.PADDING_SIZE_SMALL*/
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF2A2A2A).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5))
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${'item'.tr}: ${cartController.cartList.length}',
                                      style: poppinsMedium.copyWith(
                                          color: ColorTheme.blue,
                                          fontSize: 11)),
                                  const SizedBox(
                                      height:
                                          Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  Text(
                                    'Rs. ${PriceConverter.convertPrice(cartController.calculationCart(), isHideCurrency: true)}',
                                    style: poppinsSemiBold.copyWith(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ]),
                            InkWell(
                              onTap: () async {
                                Get.find<CartController>().update();
                                searchController.clear();
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BillingCheckOut(
                                              orderList: orderList,
                                              placeOrderEvent: (data) {
                                                if (data) {
                                                  currentPrintIndex = 0;
                                                  print(
                                                      '--------$currentPrintIndex');
                                                  cartProductList = [];
                                                  failedCartProductList = [];
                                                  isFailedPrint = false;
                                                  printPlaceOrder();
                                                }
                                              },
                                            )));
                                if (cartController.cartList.isNotEmpty) {
                                  for (var i = 0; i < products.length; i++) {
                                    for (var cart in cartController.cartList) {
                                      if (cart.product.id == products[i].id) {
                                        products[i].qty = cart.quantity;
                                        break;
                                      } else {
                                        products[i].qty = 0;
                                      }
                                    }
                                  }
                                } else {
                                  products = Get.find<AuthController>()
                                      .getProductList();
                                }
                                Get.find<RestaurantController>().update();
                              },
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.PADDING_SIZE_DEFAULT),
                                decoration: BoxDecoration(
                                    color: ColorTheme.appColor,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Center(
                                  child: Text(
                                    'Review Order',
                                    style: poppinsMedium.copyWith(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ))
                  : const SizedBox();
            })
            ),
            );
  }

  printPlaceOrder() async {
    orderList = await Get.find<CartController>().getOrderListFromLocally();
    for (var i = 0;
        i <
            (Get.find<AuthController>()
                    .profileModel!
                    .restaurantPrinterNew
                    ?.length ??
                0);
        i++) {
      RestaurantPrinterNew printer =
          Get.find<AuthController>().profileModel!.restaurantPrinterNew![i];
      List<CartModel> tempCartList = [];

      for (var e in orderList.last.cartList) {
        if ((e.product.stationName?.toUpperCase() ?? '') ==
            (printer.areaName?.toUpperCase() ?? '')) {
          tempCartList.add(e);
        }
      }
      cartProductList.add(tempCartList);
      failedCartProductList.add([]);

      // printDebug();
    }
    if (Platform.isAndroid) {
      await _subscriptionBtStatus.cancel();
      await listenBlutooth();
    }
    dataCheck();
  }

  listenBlutooth() {
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' -----------------home status bt $status ------------------ ');

      if (status == BTStatus.connected) {
        isConnect = true;
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () async {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      } else if (status == BTStatus.none) {
        if (!isConnect) {
          print('not connect');
          Future.delayed(Duration(seconds: 2), () async {
            // showErrorToast(
            //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
            isConnect = true;
            isFailedPrint = true;
            failedCartProductList[currentPrintIndex] =
                cartProductList[currentPrintIndex];
            currentPrintIndex = currentPrintIndex + 1;
            dataCheck();
          });
        } else {
          isConnect = false;
          print('%%%%%%%%%');
        }
      }
    });
  }

  dataCheck() async {
    try {
      if (currentPrintIndex <= cartProductList.length - 1) {
        if (cartProductList[currentPrintIndex].isEmpty) {
          for (var i = currentPrintIndex; i < cartProductList.length; i++) {
            if (cartProductList[i].isEmpty) {
              currentPrintIndex = currentPrintIndex + 1;
              dataCheck();
              break;
            } else {
              placeOrderByteConvert();

              break;
            }
          }
        } else {
          placeOrderByteConvert();
        }
      } else {
        if (isFailedPrint) {
          if (Platform.isAndroid) {
            await _subscriptionBtStatus.cancel();
          }
          await Get.bottomSheet(PrintOrderBillingDialog(
            order: orderList.last,
            cartProductList: failedCartProductList,
          ));
        }
      }
    } catch (e) {}
  }

  Future placeOrderByteConvert() async {
    pendingTask = [];
    List<int> bytes = [];
    ProfileModel profileModel = Get.find<AuthController>().profileModel!;

    final profile = await CapabilityProfile.load(name: 'XP-N160I');

    final generator = Generator(
        profileModel.billPrinterPaperRoll == 58
            ? PaperSize.mm58
            : PaperSize.mm80,
        profile);

    bytes += generator.setGlobalCodeTable('CP1252');

    bytes += generator.text(profileModel.restaurants![0].name!,
        styles: PrinterConfig().titleStyle());
    bytes += generator.text(profileModel.restaurants![0].address!,
        styles: PrinterConfig().addressStyle());
    if (profileModel.restaurants![0].gstCode != '')
      bytes += generator.text('GST no. ${profileModel.restaurants![0].gstCode}',
          styles: PrinterConfig().gstStyle());
    if (profileModel.restaurants![0].fssai != '')
      bytes += generator.text('FSI no. ${profileModel.restaurants![0].fssai}',
          styles: PrinterConfig().gstStyle());

    bytes += generator.row([
      PosColumn(
          text: 'order_id'.tr + ':' + ' ${orderList.last.orderId}',
          width: 6,
          styles: PrinterConfig().orderIdStyle()),
      PosColumn(
          text:
              '${DateFormat('${Get.find<AuthController>().profileModel!.restaurants!.first.billDateFormat}').format(DateTime.now())}',
          width: 6,
          styles: PrinterConfig().orderCreateDateStyle()),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Billing', width: 5, styles: PrinterConfig().dineInStyle()),
      PosColumn(
        text: '',
        width: 1,
        styles: PosStyles(align: PosAlign.center),
      ),
      PosColumn(
          text: '${orderList.last.employeeName ?? ''}',
          width: 6,
          styles: PrinterConfig().waiterNameStyle()),
    ]);

    bytes += generator.row([
      PosColumn(
        text: '${orderList.last.name}',
        width: 5,
        styles: PosStyles(
          height:
              Get.find<AuthController>().profileModel!.printConfig == null ||
                      Get.find<AuthController>()
                              .profileModel!
                              .printConfig!
                              .restaurantFoodList ==
                          null
                  ? PosTextSize.size1
                  : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig!
                      .restaurantFoodList!
                      .split(',')
                      .first),
          width: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList ==
                      null
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                  .profileModel!
                  .printConfig!
                  .restaurantFoodList!
                  .split(',')[1]),
          bold: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList ==
                      null
              ? false
              : Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList!
                          .split(',')
                          .last ==
                      'true'
                  ? true
                  : false,
          align: PosAlign.left,
        ),
      ),
      PosColumn(
        text: '',
        width: 2,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: '${orderList.last.phoneNumber}',
        width: 5,
        styles: PosStyles(
          height:
              Get.find<AuthController>().profileModel!.printConfig == null ||
                      Get.find<AuthController>()
                              .profileModel!
                              .printConfig!
                              .restaurantFoodList ==
                          null
                  ? PosTextSize.size1
                  : PrinterConfig().fonstSize(Get.find<AuthController>()
                      .profileModel!
                      .printConfig!
                      .restaurantFoodList!
                      .split(',')
                      .first),
          width: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList ==
                      null
              ? PosTextSize.size1
              : PrinterConfig().fonstSize(Get.find<AuthController>()
                  .profileModel!
                  .printConfig!
                  .restaurantFoodList!
                  .split(',')[1]),
          bold: Get.find<AuthController>().profileModel!.printConfig == null ||
                  Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList ==
                      null
              ? false
              : Get.find<AuthController>()
                          .profileModel!
                          .printConfig!
                          .restaurantFoodList!
                          .split(',')
                          .last ==
                      'true'
                  ? true
                  : false,
          align: PosAlign.right,
          fontType: PosFontType.fontB,
        ),
      ),
    ]);

    bytes += generator.hr(ch: '--');
    bytes += generator.row([
      PosColumn(text: 'SL', width: 2, styles: PrinterConfig().foodStyle()),
      PosColumn(
          text: 'item_info'.tr, width: 8, styles: PrinterConfig().foodStyle()),
      PosColumn(text: 'qty'.tr, width: 2, styles: PrinterConfig().foodStyle()),
    ]);
    bytes += generator.hr(ch: '--');
    List<CartModel> foodOrderList = [];
    foodOrderList.addAll(cartProductList[currentPrintIndex]);
    for (var i = 0; i < foodOrderList.length; i++) {
      CartModel food = foodOrderList[i];
      String addOnText = '';
      int index0 = 0;
      List<int> ids = [];
      List<int> qtys = [];
      for (var addOn in food.addOnIds) {
        ids.add(addOn.id);
        qtys.add(addOn.quantity);
      }
      for (var addOn in food.product.addOns!) {
        if (ids.contains(addOn.id)) {
          addOnText =
              '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
          index0 = index0 + 1;
        }
      }

      String variationText = '';

      if (food.variation.isNotEmpty) {
        for (int index = 0; index < food.variation.length; index++) {
          if (food.variation[index].isNotEmpty &&
              food.variation[index].contains(true)) {
            variationText +=
                '${variationText.isNotEmpty ? ', ' : ''}${food.product.variations![index].name} (';

            for (int i = 0; i < food.variation[index].length; i++) {
              if (food.variation[index][i]) {
                // print(variationTotal);
                variationText +=
                    '${variationText.endsWith('(') ? '' : ', '}${food.product.variations![index].values![i].level}';
              }
            }
            variationText += ')';
          }
        }
      }

      bytes += generator.row([
        PosColumn(
            text: '${i + 1}.', width: 2, styles: PrinterConfig().foodStyle()),
        PosColumn(
          text: '${food.product.name}',
          width: 8,
          styles: PrinterConfig().foodStyle(),
        ),
        PosColumn(
          text: formatQuantity(food.quantity),
          width: 2,
          styles: PrinterConfig().foodStyle(),
        ),
      ]);

      if (addOnText != '') {
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Add-Ons :$addOnText',
            width: 8,
            styles: PrinterConfig().foodStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
        ]);
      }
      if (variationText != '') {
        bytes += generator.row([
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(
              align: PosAlign.center,
            ),
          ),
          PosColumn(
            text: 'Variants  :$variationText',
            width: 8,
            styles: PrinterConfig().foodStyle(),
          ),
          PosColumn(
            text: '',
            width: 2,
            styles: PosStyles(align: PosAlign.center),
          ),
        ]);
      }

      bytes += generator.hr(ch: '....');
    }

    // bytes += generator.row([
    //   PosColumn(
    //     text: '',
    //     width: 2,
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //     ),
    //   ),
    //   PosColumn(
    //     text: 'Sub Total ',
    //     width: 5,
    //     styles: PrinterConfig().subtotalStyle(),
    //   ),
    //   PosColumn(
    //     text: '',
    //     width: 2,
    //     styles: PosStyles(align: PosAlign.center),
    //   ),
    //   PosColumn(
    //       text:
    //           '${PriceConverter.convertPrice(orderSubTotal, isHideCurrency: true, asFixed: 2)}',
    //       width: 3,
    //       styles: PrinterConfig().subtotalStyle()),
    // ]);

    bytes += generator.hr(ch: '....');
    if (Get.find<AuthController>()
            .profileModel!
            .restaurants!
            .first
            .footerTextBill !=
        '') {
      bytes += generator.text(
          Get.find<AuthController>()
              .profileModel!
              .restaurants!
              .first
              .footerTextBill!,
          styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              // bold: true,
              fontType: PosFontType.fontB));
    }
    bytes += generator.text('Powered by MyGenie',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            // bold: true,
            fontType: PosFontType.fontB));
    bytes += generator.cut();

    if (Platform.isAndroid) {
      await printEscPos(bytes, generator); //kitchen
    } else {
      await iosPrintEscPos(bytes, generator); //kitchen
    }
  }

  Future printEscPos(List<int> bytes, Generator generator) async {
    print('bytes length:${bytes.length}');
    // await PrinterManager.instance
    //     .disconnect(type: PrinterType.bluetooth); //  what this do explain
    BluetoothPrinter bluetoothPrinter = BluetoothPrinter(
        address: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .printerIp,
        deviceName: Get.find<AuthController>()
            .profileModel!
            .restaurantPrinterNew![currentPrintIndex]
            .printerName); //device name or ip was mandadory
    try {
      await _printerManager.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
          name: bluetoothPrinter.deviceName,
          address: bluetoothPrinter.address!,
          isBle: bluetoothPrinter.isBle ?? false,
        ),
      );
      pendingTask = null;
    } catch (e) {
      print('%%%%%%%$e');
    }

    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
      try {
        bool data = await _printerManager.send(
            type: bluetoothPrinter.typePrinter, bytes: bytes);
        Future.delayed(
            Duration(
                seconds: bytes.length <= 5850
                    ? 2
                    : bytes.length <= 7890
                        ? 3
                        : bytes.length <= 10195
                            ? 6
                            : bytes.length <= 13100
                                ? 10
                                : bytes.length <= 21150
                                    ? 15
                                    : 20), () async {
          // print('%%%%%%%%%%%%%isPrinted---$data');
          bytes = [];
          Get.find<LoadingController>().startLoading(false);
          await Get.find<LoadingController>()
              .changeText(data: 'Successfully printed!!');
          await Get.find<LoadingController>().changeStatus(data: true);
          await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
          currentPrintIndex = currentPrintIndex + 1;
          dataCheck();
        });
      } catch (e) {}
    }
  }

  Future iosPrintEscPos(List<int> bytes, Generator generator) async {
    print('########## bytes length ${bytes.length}');
    // bytes += generator.feed(2);
    // await PrintBluetoothThermal.pairedBluetooths;

    // Future.delayed(Duration(seconds: 5), () async {
    final printers = Get.find<AuthController>().profileModel?.restaurantPrinterNew;
    if (printers == null || currentPrintIndex < 0 || currentPrintIndex >= printers.length) {
      isConnect = true;
      isFailedPrint = true;
      currentPrintIndex = currentPrintIndex + 1;
      dataCheck();
      return;
    }
    final currentPrinter = printers[currentPrintIndex];
    final macAddress = currentPrinter.macPrinterIp ?? '';

    if (macAddress.isEmpty && NetworkPrinterResolver.kotPrinterAt(currentPrintIndex) == null) {
      isConnect = true;
      isFailedPrint = true;
      failedCartProductList[currentPrintIndex] =
          cartProductList[currentPrintIndex];
      currentPrintIndex = currentPrintIndex + 1;
      dataCheck();
    } else {
      final bool result = await IosPrintTransport.connect(
          wifiPrinter: NetworkPrinterResolver.kotPrinterAt(currentPrintIndex), 
          macPrinterAddress: macAddress);
      Future.delayed(Duration(seconds: 4), () async {
        if (result) {
          await IosPrintTransport.writeBytes(bytes);
          Future.delayed(
              Duration(
                  seconds: bytes.length <= 5850
                      ? 2
                      : bytes.length <= 7890
                          ? 3
                          : bytes.length <= 10195
                              ? 6
                              : bytes.length <= 13100
                                  ? 10
                                  : bytes.length <= 21150
                                      ? 15
                                      : 20), () async {
            bytes = [];
            var isDisconnect = await IosPrintTransport.disconnect;
            print('is disconnect $isDisconnect');
            currentPrintIndex = currentPrintIndex + 1;
            dataCheck();
          });
          print("print test result:  $result");
        } else {
          //no conectado, reconecte
          // showErrorToast('Failed to bluetooth connect');
          // showErrorToast(
          //     '${Get.find<AuthController>().profileModel.restaurantPrinterNew[currentPrintIndex].areaName} kot failed');
          isConnect = true;
          isFailedPrint = true;
          failedCartProductList[currentPrintIndex] =
              cartProductList[currentPrintIndex];
          currentPrintIndex = currentPrintIndex + 1;
          dataCheck();
        }
      });
    }
    // });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    String status;
    bool hasInternet = await hasInternetConnection();
    print('------------ Check Internet Connection -------------');
    switch (result) {
      case ConnectivityResult.wifi:
        status = 'Connected to WiFi';
        break;
      case ConnectivityResult.mobile:
        status = 'Connected to Mobile Network';
        break;
      case ConnectivityResult.none:
        status = 'No Internet Connection';
        break;
      default:
        status = 'Unknown';
        break;
    }

    Get.find<UpdateWidgetController>().updateInternetStatus(hasInternet);
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));
      if (result.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
