import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/product_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/data/api/api_checker.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/util/dimensions.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/confirmation_dialog.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygenie_restaurant/view/screens/pos/beach_billing/beach_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/report_summary.dart';
import 'package:mygenie_restaurant/view/screens/revenue_report/print_report.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);
  static final TextEditingController searchAdminDashboardController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          toolbarHeight: 80,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10, bottom: 10),
            child: SizedBox(width: 30, child: Image.asset(Images.app_logo)),
          ),
          title: Text(
            'Admin Dashboard',
            style: montserratSemiBold.copyWith(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          titleSpacing: 15,
          scrolledUnderElevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: ColorTheme.appColor,
                  size: 30,
                ),
                tooltip: 'Logout',
                onPressed: () => _showLogoutDialog(context),
              ),
            ),
          ],
        ),
        body: GetBuilder<AuthController>(
          builder: (authController) {
            if (authController.isLoadingRestaurants) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (authController.adminRestaurantModel == null ||
                authController
                    .adminRestaurantModel!.assignedRestaurants.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Restaurants Assigned',
                      style: montserratMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            var restaurants = authController
                .adminRestaurantModel!.assignedRestaurants
                .where((resturant) => resturant.restaurantName
                    .toLowerCase()
                    .contains(
                        searchAdminDashboardController.text.toLowerCase()))
                .toList();

            return RefreshIndicator(
              // color: CustomColors.primaryColor,
              onRefresh: () => authController.getAssignedRestaurants(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchAdminDashboardController,
                      style: montserratMedium.copyWith(
                          color: Colors.black54,
                          decoration: TextDecoration.none),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle:
                            montserratMedium.copyWith(color: Color(0xFFC6C6C6)),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: const Icon(
                            Icons.search,
                            color: Color(0xFFC6C6C6),
                          ),
                        ),
                        filled: true,
                        fillColor: ColorTheme.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: ColorTheme.white)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: ColorTheme.white)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: ColorTheme.white)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: ColorTheme.white)),
                      ),
                      onChanged: (_) {
                        authController.update();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        var restaurant = restaurants[index];

                        bool isLoading = authController.restaurantLoginLoading[
                                restaurant.restaurantId] ==
                            true;

                        return _RestaurantCard(
                          restaurant: restaurant,
                          restaurantId: restaurant.restaurantId,
                          isLoading: isLoading,
                          onLoginPressed: () => _handleRestaurantLogin(
                            context,
                            authController,
                            restaurant.restaurantId,
                            restaurant.restaurantName,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleRestaurantLogin(
    BuildContext context,
    AuthController authController,
    int restaurantId,
    String restaurantName,
  ) async {
    // Show loading for specific restaurant card
    authController.restaurantLoginLoading[restaurantId] = true;
    authController.update();

    try {
      // ============= Step 0: Clear All Previous Data FIRST =============
      // Clear before showing any loading
      try {
        // Clear all controller data
        Get.find<ProductController>().clearProductList();
        Get.find<SwiggyController>().clearOrderList();
        Get.find<KdsController>().clearOrderList();
        Get.find<TableController>().clearTableList(); // Clear table list
        Get.find<RestaurantController>().clearProductList();
        Get.find<AuthController>().clearSharedData();
      } catch (e) {
        print('Error clearing data: $e');
      }

      // ============= Step 1: Login as Restaurant =============
      var loginResponse = await authController.loginAsRestaurant(restaurantId);

      if (!loginResponse.isSuccess) {
        showErrorToast(loginResponse.message);
        return;
      }

      // ============= Step 2: Fetch Employee Profile =============

      var profileResponse = await ApiChecker.retry(
        () => authController.getProfile(),
        retries: 2,
      );

      if (profileResponse.statusCode != 200) {
        showErrorToast('Failed to load profile: ${profileResponse.statusText}');
        return;
      }

      // Validate profile
      if (authController.profileModel == null ||
          authController.profileModel!.role == null) {
        showErrorToast('Invalid profile data');
        return;
      }

      List<String> role = authController.profileModel!.role!;

      // ============= Step 3: Role-Based Initialization =============

      // ----------- STATION Role (KDS) -----------
      if (role.contains('STATION')) {
        logoHelper.appLogo = Images.ic_kds_app_logo;

        // Save profile
        authController.saveProfileDetail(
          jsonEncode(authController.profileModel),
        );

        // Navigate to KDS Home
        Get.offNamed(RouteHelper.getKdsHomeRoute());
        return;
      }

      // ----------- Delivery Role -----------
      else if (role.contains('Delivery')) {
        logoHelper.appLogo = Images.ic_manager_app_logo;

        // Save profile
        authController.saveProfileDetail(
          jsonEncode(authController.profileModel),
        );

        // Navigate to Delivery Dashboard
        Get.offNamed(RouteHelper.getDeliveryDashboardInitialRoute());
        return;
      }

      // ----------- Other Roles (Billing, Waiter, Manager, Owner) -----------
      else {
        // Set logo based on role
        if (role.contains('Waiter')) {
          if (!role.contains('order') && role.contains('bill')) {
            logoHelper.appLogo = Images.ic_cashier_app_logo;
          } else {
            logoHelper.appLogo = Images.ic_waiter_app_logo;
          }
        } else if (role.contains('report') ||
            role.contains('Owner') ||
            role.contains('report_summery')) {
          logoHelper.appLogo = Images.ic_owner_app_logo;
        } else if (role.contains('Manager')) {
          logoHelper.appLogo = Images.ic_manager_app_logo;
        } else {
          logoHelper.appLogo = Images.ic_waiter_app_logo;
        }

        // ============= Billing Role or Prepaid Restaurant =============
        if (role.contains('Billing') ||
            authController.profileModel!.billingUserView == 'Yes' ||
            (authController.profileModel!.restaurants != null &&
                authController.profileModel!.restaurants!.isNotEmpty &&
                authController
                        .profileModel!.restaurants!.first.isOrderPaymentType ==
                    'prepaid')) {
          // Check if employee list is required
          if (authController.profileModel!.restaurants != null &&
              authController.profileModel!.restaurants!.isNotEmpty &&
              authController.profileModel!.restaurants!.first.isShowEmpList ==
                  'Yes') {
            // Fetch employee list
            var getEmployee = await ApiChecker.retry(
              () => authController.getEmployeeList(),
              retries: 2,
            );

            if (getEmployee.statusCode != 200) {
              showErrorToast(
                  'Failed to load employees: ${getEmployee.statusText}');
              return;
            }

            // Save employee list
            authController.saveEmployeeList(
              jsonEncode(authController.getEmployeeListResponse),
            );
          }

          // Fetch food categories
          var getFoodCategory = await ApiChecker.retry(
            () => Get.find<RestaurantController>().getPOSFoodCategoryList(),
            retries: 2,
          );

          if (getFoodCategory.statusCode != 200) {
            showErrorToast(
                'Failed to load categories: ${getFoodCategory.statusText}');
            return;
          }

          // Fetch product list for billing
          var getProductList = await ApiChecker.retry(
            () => Get.find<RestaurantController>()
                .getWaiterProductList('1', 'all', loginType: 'Billing'),
            retries: 2,
          );

          if (getProductList.statusCode != 200) {
            showErrorToast(
                'Failed to load products: ${getProductList.statusText}');
            return;
          }

          // Save data to local storage
          authController.saveProductCategoryList(
            jsonEncode(Get.find<RestaurantController>().categoryList),
          );
          authController.saveProductList(
            jsonEncode(Get.find<RestaurantController>().productList),
          );

          // Save profile
          authController.saveProfileDetail(
            jsonEncode(authController.profileModel),
          );

          // Navigate based on role
          if (role.contains('Billing')) {
            Get.offNamed(RouteHelper.getBillingDashboardInitialRoute());
          } else {
            // Beach billing view
            if (authController.profileModel!.billingUserView == 'Yes' ||
                (authController.profileModel!.restaurants != null &&
                    authController.profileModel!.restaurants!.isNotEmpty &&
                    authController.profileModel!.restaurants!.first
                            .isOrderPaymentType ==
                        'prepaid')) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => BeachBellingHomeScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            }
          }
          return;
        }

        // ============= Waiter/Manager/Owner Role =============
        else {
          // Set KDS submenu index based on order permission
          Get.find<KdsController>().setSubMenuIndex(
            !role.contains('order') ? 2 : 1,
          );

          // Fetch food categories
          var getFoodCategory = await ApiChecker.retry(
            () => Get.find<RestaurantController>().getPOSFoodCategoryList(),
            retries: 2,
          );

          if (getFoodCategory.statusCode != 200) {
            showErrorToast(
                'Failed to load categories: ${getFoodCategory.statusText}');
            return;
          }

          // Fetch product list
          var getProductList = await ApiChecker.retry(
            () => Get.find<RestaurantController>()
                .getWaiterProductList('1', 'all'),
            retries: 2,
          );

          if (getProductList.statusCode != 200) {
            showErrorToast(
                'Failed to load products: ${getProductList.statusText}');
            return;
          }

          // Fetch cancel reasons
          var getCancelReason = await ApiChecker.retry(
            () => Get.find<KdsController>().getCancelReason(),
            retries: 2,
          );

          if (getCancelReason.statusCode != 200) {
            showErrorToast(
                'Failed to load cancel reasons: ${getCancelReason.statusText}');
            return;
          }

          // Fetch table list
          var getTableList = await ApiChecker.retry(
            () => Get.find<TableController>().saveTableListLocally(),
            retries: 2,
          );

          if (getTableList.statusCode != 200) {
            showErrorToast('Failed to load tables: ${getTableList.statusText}');
            return;
          }

          // Save data to local storage
          authController.saveProductCategoryList(
            jsonEncode(Get.find<RestaurantController>().categoryList),
          );
          authController.saveProductList(
            jsonEncode(Get.find<RestaurantController>().productList),
          );

          // Save profile
          authController.saveProfileDetail(
            jsonEncode(authController.profileModel),
          );

          // Navigate to table view home
          if (Get.find<AuthController>()
                  .profileModel!
                  .restaurants!
                  .first
                  .restaurantType ==
              'Restaurant buffet') {
            Get.offNamed(RouteHelper.getBuffetInitialRoute());
          } else if (!role.contains('order')) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => PrintReport(isadmin: true),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            Get.offNamed(RouteHelper.getTableViewHomeRoute());
          }
          return;
        }
      }
    } catch (e) {
      showErrorToast('Error: ${e.toString()}');
    } finally {
      // Hide loading for specific restaurant
      authController.restaurantLoginLoading[restaurantId] = false;
      authController.update();
    }
  }

  void _showLogoutDialog(BuildContext context) {
    Get.bottomSheet(ConfirmationDialog(
        icon: Images.support,
        description: 'Are you sure you want to log out from My Genie Admin?',
        isLogOut: true,
        onYesPressed: () async {
          try {
            // Response response = await Get.find<AuthController>().logout();
            // if (response.statusCode == 200) {
            Get.find<AuthController>().logoutFromAdmin();
            Get.find<AuthController>().clearSharedData();
            Get.offAllNamed(RouteHelper.getSignInRoute());

            // showCustomSnackBar('Logged out from restaurant', isError: false);
          } catch (e) {
            print(e);
          }
        }));
  }
}

class _RestaurantCard extends StatelessWidget {
  final dynamic restaurant;
  final VoidCallback onLoginPressed;
  final int restaurantId;
  final bool isLoading;

  _RestaurantCard({
    required this.restaurant,
    required this.onLoginPressed,
    required this.restaurantId,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // final authController = Get.find<AuthController>();
    return GetBuilder<AuthController>(builder: (controller) {
      return Card(
        margin: const EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_DEFAULT),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
          child: Row(
            children: [
              // Restaurant Logo
              // Container(
              //   width: 60,
              //   height: 60,
              //   decoration: BoxDecoration(
              //     color: Colors.grey[200],
              //     borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              //   ),
              //   child: restaurant.restaurantLogo != null
              //       ? ClipRRect(
              //           borderRadius:
              //               BorderRadius.circular(Dimensions.RADIUS_SMALL),
              //           child: CachedNetworkImage(
              //             imageUrl:
              //                 'https://preprod.mygenie.online/storage/app/public/restaurant/${restaurant.restaurantLogo}',
              //             fit: BoxFit.cover,
              //             placeholder: (context, url) =>
              //                 const Center(child: CupertinoActivityIndicator()),
              //             errorWidget: (context, url, error) => Icon(
              //               Icons.restaurant,
              //               color: Colors.grey[400],
              //               size: 30,
              //             ),
              //           ),
              //         )
              //       : Icon(
              //           Icons.restaurant,
              //           color: Colors.grey[400],
              //           size: 30,
              //         ),
              // ),
              // const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),

              // Restaurant Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${restaurant.restaurantName} (${restaurant.restaurantId})',
                      style: montserratMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${restaurant.ownerFirstName} ${restaurant.ownerLastName ?? ''}',
                            style: montserratMedium.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.ownerPhone,
                          style: montserratMedium.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Login Button

              ElevatedButton(
                onPressed: onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.appColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  ),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            radius: 10,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Login',
                        style: montserratMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
