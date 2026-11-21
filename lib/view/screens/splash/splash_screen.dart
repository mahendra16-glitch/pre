import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/data/model/body/notification_body.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/screens/pos/beach_billing/beach_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody body;
  SplashScreen({required this.body});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool _firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!_firstTime) {
        // Check if none of the results are wifi or mobile (i.e., not connected)
        bool isNotConnected = !results.contains(ConnectivityResult.wifi) &&
            !results.contains(ConnectivityResult.mobile);
        isNotConnected
            ? SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _route();
    });
    // Get.find<SplashController>().initSharedData();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
  }

  void _route() async {
    try {
      if (Get.find<AuthController>().isLoggedIn()) {
        // ============= Check if Admin Session =============
        print('Admin Session: ${Get.find<AuthController>().isAdminSession}');
        if (Get.find<AuthController>().isAdminSession) {
          // Admin session exists
          // Navigate to admin dashboard
          // Get.offNamed(RouteHelper.getSignInRoute());

          Get.offNamed(RouteHelper.getAdminDashboardRoute());

          // Fetch assigned restaurants in background
          Get.find<AuthController>().getAssignedRestaurants();
          return;
        }

        // ============= Employee Session - Load Profile =============
        await Get.find<AuthController>().getProfileDataFromLocal();

        if (Get.find<AuthController>().profileModel != null &&
            Get.find<AuthController>().profileModel!.role == null) {
          Get.offNamed(RouteHelper.getSignInRoute());
        } else if (Get.find<AuthController>().profileModel != null &&
            Get.find<AuthController>()
                    .profileModel!
                    .restaurants!
                    .first
                    .restaurantType ==
                'Restaurant buffet') {
          await Get.find<KdsController>().getCancelReason();

          logoHelper.appLogo = Images.ic_manager_app_logo;

          Get.offNamed(RouteHelper.getBuffetInitialRoute());
        } else if (Get.find<AuthController>().profileModel != null &&
            (Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('Waiter') ||
                Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('Manager'))) {
          // print(Get.find<AuthController>().profileModel.role);
          if (Get.find<AuthController>()
              .profileModel!
              .role!
              .contains('Waiter')) {
            if (!Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('order') &&
                Get.find<AuthController>()
                    .profileModel!
                    .role!
                    .contains('bill')) {
              logoHelper.appLogo = Images.ic_cashier_app_logo;
            } else {
              logoHelper.appLogo = Images.ic_waiter_app_logo;
            }
          } else if (Get.find<AuthController>()
              .profileModel!
              .role!
              .contains('report')) {
            logoHelper.appLogo = Images.ic_owner_app_logo;
          } else {
            logoHelper.appLogo = Images.ic_manager_app_logo;
          }
          Get.find<KdsController>().clearOrderList();
          Get.find<KdsController>().setSubMenuIndex(
              !Get.find<AuthController>().profileModel!.role!.contains('order')
                  ? 2
                  : 1);
          await Get.find<KdsController>().getCancelReason();
          // Get.offNamed(RouteHelper.getWaiterDashboardInitialRoute());
          if (Get.find<AuthController>().profileModel!.billingUserView ==
                  'Yes' ||
              Get.find<AuthController>()
                      .profileModel!
                      .restaurants!
                      .first
                      .isOrderPaymentType ==
                  'prepaid') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => BeachBellingHomeScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            // if (GetPlatform.isWindows ||
            //     MediaQuery.of(context).size.shortestSide > 570) {
            // Get.offNamed(RouteHelper.getTableViewHomeRoute());
            // Check if role doesn't contain 'order' - same logic as sign_in_screen
            if (!Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('order')) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => PrintReport(isadmin: true),
                ),
                (Route<dynamic> route) => false,
              );
            } else {
              Get.offNamed(RouteHelper.getTableViewHomeRoute());
            }

            // Get.offNamed(RouteHelper.getTablateWaiterDashboardInitialRoute());
            // } else {
            // Get.offNamed(RouteHelper.getTableViewHomeRoute());
            // Get.offNamed(RouteHelper.getWaiterDashboardInitialRoute());
            // }
          }
        } else if (Get.find<AuthController>()
            .profileModel!
            .role!
            .contains('Delivery')) {
          logoHelper.appLogo = Images.ic_manager_app_logo;

          Get.offNamed(RouteHelper.getDeliveryDashboardInitialRoute());
        } else if (Get.find<AuthController>().profileModel != null &&
            (Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('STATION'))) {
          logoHelper.appLogo = Images.ic_kds_app_logo;
          if (Get.find<AuthController>()
              .profileModel!
              .role!
              .contains('token_display')) {
            Get.offNamed(RouteHelper.gettokenDisplayHomeRoute());
          } else {
            Get.offNamed(RouteHelper.getKdsHomeRoute());
          }
        } else if (Get.find<AuthController>().profileModel != null &&
            Get.find<AuthController>()
                .profileModel!
                .role!
                .contains('Billing')) {
          logoHelper.appLogo = Images.ic_manager_app_logo;

          Get.offNamed(RouteHelper.getBillingDashboardInitialRoute());
        } else {
          Get.offNamed(RouteHelper.getSignInRoute());
        }
      } else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    } catch (e) {
      Get.offNamed(RouteHelper.getSignInRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SvgPicture.asset(
              Images.splash_logo,
              // height: 26,
            ),
            // Image.asset(Images.logo, width: 150),
            // SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            // Image.asset(Images.brand_logo, width: 150),
            //Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: 25), textAlign: TextAlign.center),
            // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
            // Text('suffix_name'.tr,
            //     style: poppinsMedium, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
