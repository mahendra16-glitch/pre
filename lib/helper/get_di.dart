import 'dart:convert';

import 'package:mygenie_restaurant/controller/addon_controller.dart';
import 'package:mygenie_restaurant/controller/auth_controller.dart';
import 'package:mygenie_restaurant/controller/buffet_controller.dart';
import 'package:mygenie_restaurant/controller/cart_controller.dart';
import 'package:mygenie_restaurant/controller/check_in_controller.dart';
import 'package:mygenie_restaurant/controller/delivery_man_controller.dart';
import 'package:mygenie_restaurant/controller/edit_walkin_order_controller.dart';
import 'package:mygenie_restaurant/controller/expense_controller.dart';
import 'package:mygenie_restaurant/controller/kds_controller.dart';
import 'package:mygenie_restaurant/controller/loader_contoller.dart';
import 'package:mygenie_restaurant/controller/localization_controller.dart';
import 'package:mygenie_restaurant/controller/location_controller.dart';
import 'package:mygenie_restaurant/controller/notification_controller.dart';
import 'package:mygenie_restaurant/controller/order_controller.dart';
import 'package:mygenie_restaurant/controller/pos_controller.dart';
import 'package:mygenie_restaurant/controller/product_controller.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/controller/restaurant_controller.dart';
import 'package:mygenie_restaurant/controller/revenue_controller.dart';
import 'package:mygenie_restaurant/controller/settlement_controller.dart';
import 'package:mygenie_restaurant/controller/splash_controller.dart';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/controller/tab_management_controller.dart';
import 'package:mygenie_restaurant/controller/table_controller.dart';
import 'package:mygenie_restaurant/controller/theme_controller.dart';
import 'package:mygenie_restaurant/controller/token_display_controller.dart';
import 'package:mygenie_restaurant/controller/update_widget_controller.dart';
import 'package:mygenie_restaurant/data/model/response/bank_repo.dart';
import 'package:mygenie_restaurant/data/repository/addon_repo.dart';
import 'package:mygenie_restaurant/data/repository/auth_repo.dart';
import 'package:mygenie_restaurant/data/repository/buffet_repo.dart';
import 'package:mygenie_restaurant/data/repository/campaign_repo.dart';
import 'package:mygenie_restaurant/data/repository/cart_repo.dart';
import 'package:mygenie_restaurant/data/repository/chat_repo.dart';
import 'package:mygenie_restaurant/data/repository/check_in_repo.dart';
import 'package:mygenie_restaurant/data/repository/coupon_repo.dart';
import 'package:mygenie_restaurant/data/repository/delivery_man_repo.dart';
import 'package:mygenie_restaurant/data/repository/edit_walkin_order_repo.dart';
import 'package:mygenie_restaurant/data/repository/expense_repo.dart';
import 'package:mygenie_restaurant/data/repository/kds_repo.dart';
import 'package:mygenie_restaurant/data/repository/language_repo.dart';
import 'package:mygenie_restaurant/data/repository/location_repo.dart';
// import 'package:mygenie_restaurant/data/repository/menu_management_repo.dart';
import 'package:mygenie_restaurant/data/repository/notification_repo.dart';
import 'package:mygenie_restaurant/data/repository/order_repo.dart';
import 'package:mygenie_restaurant/data/repository/pos_repo.dart';
import 'package:mygenie_restaurant/data/repository/product_repo.dart';
import 'package:mygenie_restaurant/data/repository/restaurant_repo.dart';
import 'package:mygenie_restaurant/data/repository/revenue_repo.dart';
import 'package:mygenie_restaurant/data/repository/settlement_repo.dart';
import 'package:mygenie_restaurant/data/repository/splash_repo.dart';
import 'package:mygenie_restaurant/data/api/api_client.dart';
import 'package:mygenie_restaurant/data/repository/swiggy_repo.dart';
import 'package:mygenie_restaurant/data/repository/tab_management_repo.dart';
import 'package:mygenie_restaurant/data/repository/table_repo.dart';
import 'package:mygenie_restaurant/data/repository/token_display_repo.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/data/model/response/language_model.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/controller/employee_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/controller/role_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/repo/employee_management_repo.dart';
import 'package:mygenie_restaurant/view/screens/employee_management/repo/role_management_repo.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/controller/expense_controller.dart';
import 'package:mygenie_restaurant/view/screens/expense_management/expense_repo/expense_repo.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/controller/inventory_controller.dart';
import 'package:mygenie_restaurant/view/screens/inventory_management/inventory_repo/inventory_repo.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/controller/menu_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/menu_management_screen/menu_management_repo/menu_management_repo.dart';
import 'package:mygenie_restaurant/view/screens/report_summary/widget/repo/report_summary_repo.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/aggregator_setup_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/delivery_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/payment_type_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/loyalty_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/printer_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/table_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/controller/resturant_setting_controller.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/aggregator_setup_repo.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/delivery_management_repo.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/payment_type_repo.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/loyalty_repo.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/printer_management_repo.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/table_management_repo.dart';
import 'package:mygenie_restaurant/view/screens/resturant_config/repo/resturant_setting_repo.dart';
import 'package:mygenie_restaurant/view/screens/settlement/controller/settlement_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/settlement/settlement_repo/settlement_repo.dart';
import 'package:mygenie_restaurant/view/screens/custome management/controller/customer_management_controller.dart';
import 'package:mygenie_restaurant/view/screens/custome management/repo/customer_management_repo.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

// import '../controller/menu_management_controller.dart';

Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(
      appBaseUrl: AppConstants.BASE_URL, sharedPreferences: Get.find()));

  // Repository
  Get.lazyPut(
      () => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => LanguageRepo());
  Get.lazyPut(
      () => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() =>
      NotificationRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(
      () => OrderRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => BankRepo(apiClient: Get.find()));
  Get.lazyPut(() => RestaurantRepo(apiClient: Get.find()));
  Get.lazyPut(() => ProductRepo(apiClient: Get.find()));
  Get.lazyPut(() => CampaignRepo(apiClient: Get.find()));
  Get.lazyPut(() => AddonRepo(apiClient: Get.find()));
  Get.lazyPut(() => PosRepo(apiClient: Get.find()));
  Get.lazyPut(() => TabManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => SwiggyRepo(apiClient: Get.find()));
  Get.lazyPut(
      () => CartRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(
      () => TableRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => CheckInRepo(apiClient: Get.find()));
  Get.lazyPut(() => LocationRepo(apiClient: Get.find()));
  Get.lazyPut(() => EditWalkInOrderRepo(apiClient: Get.find()));
  Get.lazyPut(() => DeliveryManRepo(apiClient: Get.find()));
  Get.lazyPut(() => RevenueRepo(apiClient: Get.find()));
  // Get.lazyPut(() => MenuManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => MenuManagementRepo(apiClient: Get.find()));

  Get.lazyPut(() => ExpenseManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => BuffetRepo(apiClient: Get.find()));
  Get.lazyPut(() => InventoryRepo(apiClient: Get.find()));
  Get.lazyPut(
      () => ChatRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => CouponRepo(apiClient: Get.find()));
  Get.lazyPut(() => ExpenseRepo(apiClient: Get.find()));
  Get.lazyPut(() => KdsRepo(apiClient: Get.find()));
  Get.lazyPut(() => SettlementRepo(apiClient: Get.find()));
  Get.lazyPut(() => EmployeeManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => RoleManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => SettlementManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => LoyaltyRepo(apiClient: Get.find()));
  Get.lazyPut(() => RestaurantSettingsRepo(apiClient: Get.find()));
  Get.lazyPut(() => DeliveryManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => PaymentTypeRepo(apiClient: Get.find()));
  Get.lazyPut(() => PrinterManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => TableManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => AggregatorSetupRepo(apiClient: Get.find()));
  Get.lazyPut(() => ReportSummaryRepo(apiClient: Get.find()));
  Get.lazyPut(() => CustomerManagementRepo(apiClient: Get.find()));
  Get.lazyPut(() => TokenDisplayRepo(apiClient: Get.find()));

  // Controller
  Get.put(PrintDebugController(), permanent: true);
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(
      sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => MenuManagementController(menuManagementRepo: Get.find()));

  // Get.lazyPut(() => MenuManagementController(menuManagementRepo: Get.find()));
  Get.lazyPut(
      () => ExpenseManagementController(expenseManagementRepo: Get.find()));
  Get.lazyPut(() => InventoryController(inventoryRepo: Get.find()));
  Get.lazyPut(() =>
      SettlementManagementController(settlementManagementRepo: Get.find()));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => OrderController(orderRepo: Get.find()));
  Get.lazyPut(() => LocationController(locationRepo: Get.find()));
  Get.lazyPut(() => ReportSummeryController(reportSummaryRepo: Get.find()));

  Get.lazyPut(() => TabManagementController(tabManagementRepo: Get.find()));
  Get.lazyPut(() => SwiggyController(swiggyRepo: Get.find()));
  Get.lazyPut(() => SettlementController(settlementRepo: Get.find()));
  Get.lazyPut(() => UpdateWidgetController());
  Get.lazyPut(() => LoadingController());
  Get.lazyPut(() => RestaurantController(restaurantRepo: Get.find()));
  Get.lazyPut(() => AddonController(addonRepo: Get.find()));
  Get.lazyPut(() => PosController(posRepo: Get.find()));
  Get.lazyPut(() => CartController(cartRepo: Get.find()));
  Get.lazyPut(() => BuffetController(buffetRepo: Get.find()));
  Get.lazyPut(() => TokenDisplayController(tokenDisplayRepo: Get.find()));
  Get.lazyPut(() => CheckInController(checkInRepo: Get.find()));
  Get.lazyPut(() => EditWalkInOrderController(cartRepo: Get.find()));
  Get.lazyPut(() => DeliveryManController(deliveryManRepo: Get.find()));
  Get.lazyPut(() => ExpenseController(expenseRepo: Get.find()));
  Get.lazyPut(() => RevenueController(revenueRepo: Get.find()));
  Get.lazyPut(() => KdsController(kdsRepo: Get.find()));
  Get.lazyPut(() => TableController(tableRepo: Get.find()));
  Get.lazyPut(() => ProductController(productRepo: Get.find()));
  Get.lazyPut(
      () => EmployeeManagementController(employeeManagementRepo: Get.find()));
  Get.lazyPut(() => RoleManagementController(roleManagementRepo: Get.find()));
  Get.lazyPut(() => LoyaltyController(loyaltyRepo: Get.find()));
  Get.lazyPut(
      () => RestaurantSettingsController(restaurantSettingsRepo: Get.find()));
  Get.lazyPut(
      () => DeliveryManagementController(deliveryManagementRepo: Get.find()));
  Get.lazyPut(() => PaymentTypeController(paymentTypeRepo: Get.find()));
  Get.lazyPut(
      () => PrinterManagementController(printerManagementRepo: Get.find()));
  Get.lazyPut(() => TableManagementController(tableManagementRepo: Get.find()));
  Get.lazyPut(
      () => AggregatorSetupController(aggregatorSetupRepo: Get.find()));
  Get.lazyPut(
      () => CustomerManagementController(customerManagementRepo: Get.find()));

  // Retrieving localized data
  Map<String, Map<String, String>> _languages = Map();
  for (LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues = await rootBundle
        .loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> _mappedJson = json.decode(jsonStringValues);
    Map<String, String> _json = Map();
    _mappedJson.forEach((key, value) {
      _json[key] = value.toString();
    });
    _languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
        _json;
  }
  return _languages;
}
