import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/model/response/language_model.dart';
import 'package:mygenie_restaurant/util/images.dart';

class AppConstants {
  static const String APP_NAME = 'MyGenie Restaurant';

  // static const String BASE_URL = 'https://manage.mygenie.online'; //live
  // static const String SOCKET_BASE_URL =
  //     'https://socket.mygenie.online'; //production  //change the crm also
  // static const String CRM_BASE_URL =
  //     'https://crm-mygenie.mygenie.online'; //CRM PRODUCTION
  // static const String SOCKET_BASE_URL = 'http://13.233.63.7:3000'; //production
  static const String SOCKET_BASE_URL =
      'https://presocket.mygenie.online'; //devlopment
  static const String BASE_URL = 'https://preprod.mygenie.online'; // devlopment
  static const String CRM_BASE_URL = 'https://crm.mygenie.online'; //CRM UAT
  // static const String SOCKET_BASE_URL =
  //     'http://52.66.232.149:5000'; //devlopment
  static const String FEEDBACK_BASE_URL =
      'https://order.mygenie.online/feedback'; // devlopment
  static const String EMPLOYEE_LOGIN_URI =
      '/api/v1/auth/vendoremployee/common-login';
  static const String RESTAURANT_CRM_TOKEN_URI =
      '/api/v2/vendoremployee/restaurant-crm-token';

  //..........................................CRM.........................................//

  static const String CRM_CUSTOMER_LIST_URI = '/api/pos/customers';
  static const String CRM_CUSTOMER_DETAIL_URI = '/api/pos/customers/';
  static const String CRM_CUSTOMER_LOOKUP = '/api/pos/customer-lookup';
  static const String CRM_ADD_CUSTOMER = '/api/pos/customers';
  static const String CRM_EDIT_CUSTOMER = '/api/pos/customers';
  static const String CRM_ADDRESS_LIST_URL = '/api/pos/address-lookup';
  static const String CRM_ADDRESS_DELETE =
      '/api/pos/customers/customerId/addresses/addressId';
  static const String CRM_MAX_REDEEMABLE = '/api/pos/max-redeemable';
  static const String CRM_COUPONS_AVAILABLE = '/api/pos/coupons/available';
  static const String CRM_COUPONS_VALIDATE = '/api/pos/coupons/validate';
  //..........................................CRM.........................................//

  static const String EMPLOYEE_LOGOUT_URI =
      '/api/v2/vendoremployee/employee-logout';
  static const String FORGET_PASSWORD_URI =
      '/api/v1/auth/vendoremployee/forgot-password';
  static const String getDeliveryChargesUri = '/api/v1/config/distance-api';
  static const String RESET_PASSWORD_URI = '/api/v1/auth/vendor/reset-password';
  static const String EMPLOYEE_RESET_PASSWORD_URI =
      '/api/v1/vendoremployee/employee-reset-password';
  static const String WAITER_PROFILE_URI =
      // '/api/v2/vendoremployee/vendor-profile/profile';
      '/api/v1/vendoremployee/profile';
  static const String GET_EMPLOYEE_LIST_URI =
      '/api/v2/vendoremployee/billing/employee-list';
  static const String BUFFET_CANCEL_FOOD_ITEM =
      '/api/v2/vendoremployee/buffet/buffet-cancel-food-item';

  static const String WAITER_PRODUCT_LIST_URI =
      '/api/v1/vendoremployee/get-products-list';
  static const String BILLING_PRODUCT_LIST_URI =
      '/api/v2/vendoremployee/billing/get-products-list-for-offline';
  static const String WAITER_KDS_ORDER_LIST_URI =
      '/api/v1/vendoremployee/pos/employee-orders-list';
  static const String WAITER_SCHEDULE_ORDER_LIST_URI =
      '/api/v1/vendoremployee/pos/schedule-orders-list';
  static const String ONLINE_UNPAID_ORDER_LIST_URI =
      '/api/v2/vendoremployee/online-prepaid-order-list';
  static const String DELIVERY_ORDER_LIST_URI =
      '/api/v1/vendoremployee/get-delivery-order-list';
  static const String WAITER_MERGE_ORDER_NEW_URI =
      '/api/v2/vendoremployee/order/transfer-order';
  // static const String WAITER_MERGE_ORDER_URI =
  //     '/api/v2/vendoremployee/transfer-order';
  static const String WAITER_TRANSFER_FOOD_NEW_URI =
      '/api/v2/vendoremployee/order/transfer-food-item';
  // static const String WAITER_TRANSFER_FOOD_URI =
  //     '/api/v2/vendoremployee/transfer-food-item';
  static const String WAITER_DINEIN_ORDER_UPDATE_STATUS_NEW_URI =
      '/api/v2/vendoremployee/order/waiter-dinein-order-status-update';
  //   static const String WAITER_DINEIN_ORDER_UPDATE_STATUS_URI =
  // '/api/v1/vendoremployee/waiter-dinein-order-status-update';
  static const String ADD_PRODUCT_URI =
      '/api/v2/vendoremployee/product/add-single-product'; // v2 -> v1
  static const String SEND_PRINT_MANUAL_URL =
      '/api/v1/vendoremployee/order-temp-store';
  static const String PAID_ORDER_LIST_URI =
      '/api/v2/vendoremployee/paid-order-list';
  static const String PAy_LATER_ORDER_LIST_URI =
      '/api/v2/vendoremployee/paid-paylater-order-list';
  static const String CANCELLED_ORDER_LIST_URI =
      '/api/v2/vendoremployee/cancel-order-list';
  static const String GET_SINGLE_PRODUCT =
      '/api/v1/vendoremployee/get-single-products';
  static const String COMPLETED_SWIGGY_ORDER_BY_DATE_URI =
      '/api/v1/vendoremployee/urbanpiper/get-complete-order-list';
  static const String EXPORT_AGGR_ORDER_REPORT_URI =
      '/api/v2/vendoremployee/report/aggregator-order-detail/export';
  static const String ROOM_PAID_ORDER_LIST_URI =
      '/api/v2/vendoremployee/paid-in-room-order-list';
  static const String TAB_ORDER_LIST_URI =
      '/api/v2/vendoremployee/paid-in-tab-order-list';
  static const String SET_BUFFET_FOOD_PRIORITY =
      '/api/v2/vendoremployee/buffet/buffet-set-food-priority';
  static const String ATTEND_TABLE_URI =
      '/api/v1/vendoremployee/attend-waiter-call';
  static const String OREDER_STATUS_UPDATE_URI =
      '/api/v2/vendoremployee/order/order-status-update';
  // static const String OREDER_STATUS_UPDATE_URI =
  //     '/api/v2/vendoremployee/order-status-update';
  static const String SILENT_BUZZER_URI =
      '/api/v2/vendoremployee/send-scilent-notification';
  // static const String SPLIT_ORDER_URL =  //old split url
  //     '/api/v1/vendoremployee/pos/split-order';
  static const String SPLIT_ORDER_URL = //new split url
      '/api/v2/vendoremployee/order/split-order';
  static const String MAKE_UNPAID_ORDER_URI =
      // '/api/v2/vendoremployee/make-order-unpaid';
      '/api/v2/vendoremployee/order/make-order-unpaid';
  static const String MAKE_RAZORPAY_UNPAID_ORDER_URI =
      '/api/v1/vendoremployee/cancel-and-refund-razorpay';
  static const String CHANGE_PAYMENT_METHOD =
      '/api/v2/vendoremployee/change-order-payment-method';
  static const String PREPAID_OREDER_STATUS_UPDATE_URI =
      '/api/v2/vendoremployee/order/paid-prepaid-order';
  // static const String PREPAID_OREDER_STATUS_UPDATE_URI =
  //     '/api/v2/vendoremployee/paid-prepaid-order';

  static const String GET_PAID_ROOM_ORDER_LIST_URI =
      '/api/v1/vendoremployee/get-room-paid-order-details';
  static const String BUFFET_WAITER_ORDER_LIST_URI =
      '/api/v2/vendoremployee/buffet/buffet-orders-list';
  static const String FOOD_OREDER_STATUS_UPDATE_URI =
      '/api/v2/vendoremployee/order/food-status-update';
  // static const String FOOD_OREDER_STATUS_UPDATE_URI =
  //     '/api/v2/vendoremployee/food-status-update';
  static const String BUFFET_SERVER_ORDER_LIST_URI =
      '/api/v2/vendoremployee/buffet/server-orders-list';

  static const String BUFFET_FOOD_OREDER_DETAIL_STATUS_UPDATE_URI =
      '/api/v2/vendoremployee/buffet/buffet-food-item-details';
  static const String BUFFET_FOOD_OREDER_STATUS_UPDATE_URI =
      '/api/v2/vendoremployee/buffet/buffet-food-status-update';

  static const String CANCEL_QTY_FOOD_ITEM =
      '/api/v2/vendoremployee/partial-cancel-food-item';
  static const String CANCEL_FOOD_NEW_URI =
      '/api/v2/vendoremployee/order/cancel-food-item';
  static const String CANCEL_FOOD_ITEM =
      '/api/v2/vendoremployee/cancel-food-item';
  static const String SWIGGY_CHANGE_ORDER_STATUS =
      '/api/v1/urbanpiper/orders-status-update';
  static const String CHANGE_AGGREGATOR_STATUS_URI =
      '/api/v1/vendoremployee/urbanpiper/update-aggregator-status';
  static const String CATEGORY_URI =
      '/api/v2/vendoremployee/order-category-restaurant';
  static const String POPULAR_CATEGORY_URI =
      '/api/v2/vendoremployee/popular-category';
  static const String POPULAR_FOOD_LIST_URI =
      '/api/v2/vendoremployee/buffet/buffet-popular-food?offset=1&limit=10&type=all';

  static const String SUB_CATEGORY_URI = '/api/v1/categories/childes/';
  static const String ADDON_URI = '/api/v1/vendor/addon';
  static const String ADD_ADDON_URI = '/api/v1/vendor/addon/store';
  static const String GET_POS_ORDER_LIST_URI =
      '/api/v1/vendoremployee/station-order-list';
  static const String GET_MANUAL_BILL_FROM_SCOKET_URI =
      '/api/v1/vendoremployee/order-temp-details';
  static const String GET_ORDER_FROM_SCOKET_URI =
      '/api/v2/vendoremployee/get-single-order-new';
  static const String GET_TOKEN_DISPLAY_ORDER_FROM_SCOKET_URI =
      '/api/v1/vendoremployee/pos/token-single-orders-details';
  static const String DETAIL_FROM_SOCKET_SWIGGY_URI =
      '/api/v1/vendoremployee/urbanpiper/get-order-details';
  static const String GET_STATION_ORDER_FROM_SCOKET_URI =
      '/api/v2/vendoremployee/get-station-order-details';
  static const String ALL_CATEGORY_URI = '/api/v1/categories';
  static const String FOOD_CATEGORY_URI =
      '/api/v1/vendoremployee/get-categories';
  static const String GET_MENU_FOOD_LIST_URI =
      '/api/v2/vendoremployee/product/foods-list';
  static const String ADD_MENU_FOOD_LIST_URI =
      '/api/v2/vendoremployee/product/add-food';
  static const String UPDATE_MENU_FOOD_LIST_URI =
      '/api/v2/vendoremployee/product/foods/';
  static const String DELETE_MENU_FOOD_LIST_URI =
      '/api/v2/vendoremployee/product/delete/';

  static const String ADDON_LIST_URI =
      '/api/v2/vendoremployee/product/addon-list';
  static const String ADD_ADDON_LIST_URI =
      '/api/v2/vendoremployee/product/add-addon';
  static const String UPDATE_ADDON_LIST_URI =
      '/api/v2/vendoremployee/product/addon-update/';
  static const String DELETE_ADDON_LIST_URI =
      '/api/v2/vendoremployee/product/delete-addon/';

  static const String GET_TOTAL_KDS_ORDER_LIST_URI =
      '/api/v1/vendoremployee/employee-menu';
  static const String GET_BUFFET_STATION_SIDE_MENU_URI =
      '/api/v2/vendoremployee/buffet/buffet-employee-menu';
  static const String GET_CANCEL_REASON_LIST_URI =
      '/api/v1/vendoremployee/cancellation-reasons?limit=50&offset=1';
  static const String CHECKIN_URI =
      '/api/v1/vendoremployee/pos/user-group-check-in';

  static const String EMPLOYEE_PLACE_ORDER_URI =
      '/api/v2/vendoremployee/pos/place-order';
  static const String BUFFET_PLACE_ORDER_URI =
      '/api/v2/vendoremployee/buffet/buffet-place-order';
  static const String BUFFET_PREPAID_PLACE_ORDER_URI =
      '/api/v2/vendoremployee/buffet/buffet-place-prepaid-order';
  static const String PLACE_AND_PAY_ORDER_URI =
      '/api/v2/vendoremployee/billing/place-and-paid-order';
  static const String WAITER_PLACE_ORDER_NEW =
      '/api/v2/vendoremployee/order/place-order';
  static const String WAITER_EDIT_ORDER_NEW =
      '/api/v2/vendoremployee/order/update-place-order';
  static const String PREPAID_ORDER_URI =
      '/api/v1/vendoremployee/pos/place-order-and-payment';
  static const String EDC_PREPAID_ORDER_URI =
      '/api/v1/vendoremployee/pos/edc-prepaid-order-and-payment';
  static const String EMPLOYEE_UPDATE_PLACE_ORDER_URI =
      '/api/v2/vendoremployee/pos/update-place-order';
  static const String RESTAURANT_CUSTOMER_LIST_URI =
      '/api/v2/vendoremployee/restaurant-customer-list';
  static const String CUSTOMER_LIST_FROM_MEMBER_ID_URI =
      '/api/v1/vendoremployee/pos/customer-for-member-id';

  static const String BILLING_SYNC_ORDER_URI =
      '/api/v2/vendoremployee/billing/offline-order-syncup';
  static const String WALK_IN_EDIT_ORDER_URI =
      '/api/v2/vendoremployee/pos/update-confirm-order';
  static const String WAITER_SEARCH_CUSTOMERS_URI =
      '/api/v1/vendoremployee/pos/customers';
  static const String TABLE_LIST_URI = '/api/v1/vendoremployee/get-table-list';
  static const String BUFFET_TABLE_LIST_URI =
      '/api/v2/vendoremployee/buffet/buffet-table-list';

  static const String ALL_TABLE_LIST_URI =
      '/api/v1/vendoremployee/all-table-list';
  static const String ROOM_LIST_URI = '/api/v2/vendoremployee/get-room-list';
  static const String ROOM_BILLS_LIST_URI =
      '/api/v2/vendoremployee/get-room-order-details';
  static const String ROOM_LIST_WITH_AMOUNT_URI =
      '/api/v1/vendoremployee/get_room_total_payment_list';
  static const String CHANGE_TABLE_URI =
      '/api/v2/vendoremployee/order/order-table-room-switch';
  // static const String CHANGE_TABLE_URI =
  //     '/api/v1/vendoremployee/pos/order-table-room-switch';
  static const String UPDATE_CUSTOMER_DETAIL_URI =
      '/api/v1/vendoremployee/pos/user-check-create';
  static const String SWIGGY_ZOMATO_ORDER_LIST_URI =
      '/api/v1/vendoremployee/urbanpiper/get-order-list';
  static const String GET_TOKEN_DISPLAY_ORDER_LIST_URI =
      '/api/v1/vendoremployee/pos/token-orders-list';
  static const String GET_SWIGGY_STORE_STATUS_URI =
      '/api/v1/vendoremployee/urbanpiper/get-aggregator-status';
  static const String TAP_MANAGEMENT_CUSTOMER_LIST_URI =
      '/api/v1/vendoremployee/pos/tap-waiter-list';
  static const String REVENUE_REPORT_URI =
      '/api/v2/vendoremployee/revenue-report';
  static const String SETTLEMENT_LIST_URI =
      '/api/v2/vendoremployee/sattlement-list';
  static const String SETTLEMENT_DETAIL_URI =
      '/api/v2/vendoremployee/sattlement-details';
  static const String SETTLEMENT_AMOUNT_URI =
      '/api/v2/vendoremployee/daily-waiter-sattle-cash';
  static const String GET_COLLECT_BILL_DETTAIL_URI =
      '/api/v2/vendoremployee/pos/collect-order-bill-show';
  static const String ADD_MONEY_WALLET_URL =
      '/api/v1/vendoremployee/virtual-wallet/credit';
  static const String CHECK_WALLET_BALANCE_URL =
      '/api/v1/vendoremployee/virtual-wallet/balance';
  static const String GET_VIEW_TAB_BILLS_URI =
      '/api/v2/vendoremployee/pos/tap-customer-record-list?customer_id=';
  static const String TAP_CUSTOMER_ORDER_RECORDS_URI =
      '/api/v2/vendoremployee/report/tap-customer-order-records'; //tab report api
  static const String TAP_CUSTOMER_ORDER_RECORDS_EXPORT_URI =
      '/api/v2/vendoremployee/report/tap-customer-order-records/export'; //tab report export api

  static const String COLLECT_PAYMENT_URI =
      '/api/v2/vendoremployee/order/order-bill-payment';
  static const String ROOM_PAYMENT_URI =
      '/api/v2/vendoremployee/pos/room-payment';
  static const String SPLIT_ROOM_ORDER_URI =
      '/api/v2/vendoremployee/order/split-room-order';
  // static const String COLLECT_PAYMENT_URI =
  //     '/api/v2/vendoremployee/order-bill-payment';
  static const String EDC_COLLECT_PAYMENT_URI =
      '/api/v2/vendoremployee/edc-order-bill-payment';
  static const String CANCEL_EDC_REQ_URI =
      '/api/v1/vendoremployee/pos/edc-order-cancel-payment';
  static const String ADD_BILL_IN_ROOM_URI =
      '/api/v2/vendoremployee/order/order-shifted-room';
  static const String COLLECT_TAP_PAYMENT_URI =
      '/api/v1/vendoremployee/pos/tap-waiter-order-insert';
  static const String APPLY_DISCOUNT_FOR_ROLE_BASE_URI =
      '/api/v1/vendoremployee/order-discount-manage';
  static const String ADD_ADDRESS_URI =
      '/api/v1/vendoremployee/add-customer-address';
  static const String UPDATE_ADDRESS_URI =
      '/api/v1/vendoremployee/update-customer-address';
  static const String DELETE_ADDRESS_URI =
      '/api/v1/vendoremployee/delete-customer-address';
  static const String GET_ADDRESS_LIST_URI =
      '/api/v1/vendoremployee/get-customer-address-list';

  static const String WHATSAPP_BILL =
      '/api/v2/vendoremployee/send-bill-on-whatsapp';
  static const String SEND_PAYMENT_LINK = '/api/v1/razor-pay/payment-link';

  //.........................MENU MANAGEMENT..............................//

  /// Menu Management API
  // static const String ALL_CATEGORY_URI = '/api/v1/categories';
  static const foodList = "${version2}vendoremployee/product/foods-list";
  static const restaurantClients =
      "${version2}vendoremployee/product/restaurant-clients";
  static const addFood = "${version2}vendoremployee/product/add-food";
  static String editFood(int id) {
    String url = "${version2}vendoremployee/product/foods/$id";

    return url;
  }

  static String deleteFood(int id) {
    String url = "${version2}vendoremployee/product/delete/$id";

    return url;
  }

  static const addFoodAggregator =
      "${version2}vendoremployee/product/add-food-aggregator";

  static String statusFood(int id) {
    String url = "${version2}vendoremployee/product/status-food/$id";

    return url;
  }

  static const aggregatorStockToggle =
      "${version2}vendoremployee/aggregator-sync/stock-toggle";
  static const aggregatorConfig = "${version2}vendoremployee/aggregator-config";
  static const aggregatorConfigStoreToggle =
      "${version2}vendoremployee/aggregator-config/store-toggle";
  static const aggregatorSyncCatalog =
      "${version2}vendoremployee/aggregator-sync/sync-catalog";
  static const aggregatorForceSwiggyEnable =
      "${version2}vendoremployee/aggregator-sync/force-swiggy-enable";
  static const aggregatorClearCatalog =
      "${version2}vendoremployee/aggregator-sync/clear-catalog";
  static const aggregatorClearModifiers =
      "${version2}vendoremployee/aggregator-sync/clear-modifiers";
  static const aggregatorCategoryTimings =
      "${version2}vendoremployee/aggregator-sync/category-timings";
  static const aggregatorCategoryTimingsPush =
      "${version2}vendoremployee/aggregator-sync/category-timings/push";

  static const menuMasterLists = "/api/v2/vendoremployee/product/menu-master";

  static const deleteReasons =
      "${version2}vendoremployee/product/delete-reasons";

  //* Cancellation Reasons
  static const String cancellationReasonsList =
      '/api/v2/vendoremployee/cancel-reasons/list';
  static const String cancellationReasonsAdd =
      '/api/v2/vendoremployee/cancel-reasons/add';
  static String cancellationReasonsStatus(int id) =>
      '/api/v2/vendoremployee/cancel-reasons/status/$id';
  static String cancellationReasonsUpdate(int id) =>
      '/api/v2/vendoremployee/cancel-reasons/update/$id';
  static String cancellationReasonsDelete(int id) =>
      '/api/v2/vendoremployee/cancel-reasons/delete/$id';

  static const addonList = "${version2}vendoremployee/product/addon-list";
  static const addAddon = "${version2}vendoremployee/product/add-addon";
  static String updateAddon(int id) {
    String url = "${version2}vendoremployee/product/addon-update/$id";

    return url;
  }

  static const importAddon = "${version2}vendoremployee/product/import-addon";

  static String deleteAddon(int id) {
    String url = "${version2}vendoremployee/product/delete-addon/$id";

    return url;
  }

  static const bulkExport = "${version2}vendoremployee/product/bulk-export";

  static const bulkImport = "${version2}vendoremployee/product/bulk-import";

  static const importCategories =
      "${version2}vendoremployee/product/import-categories";

  static String addonStatusChange(int id) {
    String url = "${version2}vendoremployee/product/status-change/$id";

    return url;
  }

  static const exportSample = "${version2}vendoremployee/product/export-sample";

  //** Station *//
  static const stationList =
      "/api/v2/vendoremployee/product/station-printer-list";

  //** Category *//

  static const getMenuManagementCategories =
      "/api/v2/vendoremployee/product/categories";

  static const AddCategories = '/api/v1/vendoremployee/product/add-categories';

  //.........................MENU MANAGEMENT..............................//

  //.........................DAILY REPORT..............................//

  static const String version1 = '/api/v1/';
  static const String version2 = '/api/v2/';

  static const networkImage =
      "https://t3.ftcdn.net/jpg/05/60/70/82/360_F_560708240_pMZPOuSfvblWGRoaiZFLT4wiFTzQPwQe.jpg";

  static const login = "${version1}auth/vendoremployee/login";
  static const totalSales = "${version1}vendoremployee/all-sales-report";
  static const insightsSalesReport =
      "${version2}vendoremployee/report/insights-sales";
  static const topAllFoodSales =
      "${version1}vendoremployee/top-food sales-report";
  static const stationSalesRevenueReport =
      "${version1}vendoremployee/station-wise-sales-revenue-report";
  static const cancelReasonWiseFoodExportReport =
      "${version1}vendoremployee/calcel-food-sales-report-download";
  static const dailySalesItemWiseExportReport =
      "/api/v1/vendoremployee/daily-order-report-excel-export-combined";
  static const stationSalesRevenueReportDetails =
      "${version1}vendoremployee/monthly-sation-sales-revenue-report";
  static const revenueReport = "${version2}vendoremployee/revenue-report";
  static const salesCategoryReport =
      "${version1}vendoremployee/top-category-sales-report";
  static const salesCategoryReportDetails =
      "${version1}vendoremployee/top-all-food-sales-report";

  static const topCancelItemsReport =
      "${version1}vendoremployee/calcel-food-sales-report";
  static const dailySalesDetailsReport =
      "${version1}vendoremployee/daily-order-report";
  static const topFoodVariationSalesReport =
      "${version1}vendoremployee/top-food-variation-sales-report";
  static const topFoodVariationSalesReportDownload =
      "${version1}vendoremployee/top-food-variation-sales-report-download";
  static const orderAuditReport =
      "${version1}vendoremployee/order-audit-report";
  static const orderAuditReportExcel =
      "${version1}vendoremployee/order-audit-report-excel";
  static const orderCancelReport =
      "${version1}vendoremployee/order-cancel-report";
  static const orderCancelReportDownload =
      "${version1}vendoremployee/order-cancel-report-download";
  static const logout = "${version2}vendoremployee/employee-logout";
  static const orderLogsReport = "${version2}vendoremployee/report/order-logs";

  //.........................DAILY REPORT..............................//

  static const String GET_ADDRESS_DETAIL_URI =
      '/api/v1/config/place-details?place_id=';
  //   static const String DM_LIST_URI = '/api/v1/vendor/delivery-man/list';
  static const String DELIVERY_BOY_LIST_URI =
      '/api/v1/vendoremployee/delivery-employee-list';
  // static const String ASSIGN_DELIVERY_MAN =
  //     '/api/v1/vendoremployee/delivery-order-assign';
  static const String ASSIGN_DELIVERY_MAN =
      '/api/v2/vendoremployee/order/delivery-order-assign';

  // static const String REJECT_DELIVERY_MAN =
  //     '/api/v1/vendoremployee/delivery-order-cancel';
  static const String REJECT_DELIVERY_MAN =
      '/api/v2/vendoremployee/order/delivery-order-cancel';
  static const String PAID_ORDER_DETAILS_URI =
      '/api/v2/vendoremployee/employee-order-details?order_id=';
  static const String ALL_ROOM_BILL_PRINT_FROM_ORDERID =
      '/api/v1/vendoremployee/room-order-list-details?order_id=';
  static const String ZONE_LIST_URI = '/api/v1/zone/list';
  static const String SEARCH_LOCATION_URI =
      '/api/v1/config/place-api-autocomplete';
  static const String PLACE_DETAILS_URI = '/api/v1/config/place-api-details';
  static const String ZONE_URI = '/api/v1/config/get-zone-id';
  static const String RESTAURANT_REGISTER_URI = '/api/v1/auth/vendor/register';
  static const String RESTAURANT_PACKAGES_URI =
      '/api/v1/auth/vendor/package-view';
  static const String BUSINESS_PLAN_URI = '/api/v1/auth/vendor/business_plan';
  static const String RENEW_BUSINESS_PLAN_URI =
      '/api/v1/auth/vendor/package-renew';
  static const String ADD_COUPON_URI = '/api/v1/vendor/coupon-store';
  static const String COUPON_LIST_URI = '/api/v1/vendor/coupon-list';
  static const String COUPON_CHANGE_STATUS_URI = '/api/v1/vendor/coupon-status';
  static const String COUPON_DELETE_URI = '/api/v1/vendor/coupon-delete';
  static const String COUPON_UPDATE_URI = '/api/v1/vendor/coupon-update';
  static const String EXPENSE_LIST_URI = '/api/v1/vendor/get-expense';
  static const String ORDER_CANCELLATION_URI =
      '/api/v1/customer/order/cancellation-reasons';
  static const String CUISINE_URI = '/api/v1/cuisine';
  static const String UPDATE_PRODUCT_RECOMMENDED_URI =
      '/api/v1/vendor/product/recommended';

  //*order-details
  static const String ORDER_DETAILS =
      '${version1}vendoremployee/employee-order-details?order_id=';
  static const dailySalesReportDetails =
      "${version1}vendoremployee/daily-order-report-details-combined";
  static const dailySalesReportDetailsReport =
      "/api/v1/vendoremployee/daily-order-report-details-single";
  static const dailyWaiterSalesReportDetails =
      "${version2}vendoremployee/waiter-order-report-details";
//   static const dailySalesReport =
//       "${version2}vendoremployee/daily-sales-revenue-report";
  static const dailySalesReport =
      "${version1}vendoremployee/daily-sales-revenue-report";

  //Chatting
  static const String GET_CONVERSATION_LIST = '/api/v1/vendor/message/list';
  static const String GET_MESSAGE_LIST_URI = '/api/v1/vendor/message/details';
  static const String SEND_MESSAGE_URI = '/api/v1/vendor/message/send';
  static const String SEARCH_CONVERSATION_LIST_URI =
      '/api/v1/vendor/message/search-list';

  //.........................INVENTORY MANAGEMENT..............................//

  static const stockInventory =
      "${version2}vendoremployee/inventory/stock-inventory";

  //*Manage Vendor
  static const getVendor = "${version2}vendoremployee/inventory/get-vendor";
  static const addVendor = "${version2}vendoremployee/inventory/add-vendor";
  static const deleteVendor =
      "${version2}vendoremployee/inventory/vendor-delete/";
  static const updateVendor =
      "${version2}vendoremployee/inventory/update-vendor/";

  static const getInventoryIngredients =
      "${version2}vendoremployee/inventory/get-inventory-master";

  // static const addInventoryStock =
  //     "${version2}vendoremployee/inventory/add-pur";
  static const addInventoryStock =
      "${version2}vendoremployee/inventory/add-purchase";

  static const inventoryExportStock =
      "${version2}vendoremployee/inventory/export-stock";

  static const inventoryUploadStockExcel =
      "${version2}vendoremployee/inventory/upload-stock-excel";

  static const inventoryExportInventorySemple =
      "${version2}vendoremployee/inventory/export-inventory-semple";

  static const exportIngredients =
      "${version2}vendoremployee/inventory/export-inventory-master";

  static const purchaseExportPurchaseReport =
      "${version2}vendoremployee/inventory/export-purchase-report";

  static const importVendorSupplier =
      "${version2}vendoremployee/inventory/import-vendor-supplier";

  static String updateStockStatus(int id) {
    String url = "${version2}vendoremployee/inventory/update-status/$id";

    return url;
  }

  static const getInventroyFoodList =
      "${version2}vendoremployee/inventory/inventory-menu-list";

  static const getActiveFoodsList =
      "${version2}vendoremployee/product/active-foods-list";

  static const updateStatusInventoryFood =
      "${version2}vendoremployee/inventory/change-inventory-status";

  static const addIngredientsInventory =
      "${version2}vendoremployee/inventory/add-inventory";
  static String deleteIngredient(int id) =>
      '/api/v2/vendoremployee/inventory/ingredient/$id';

  static String updateStock(int id) {
    String url = "${version2}vendoremployee/inventory/update-stock/$id";

    return url;
  }

  static const getStockCategories =
      "${version2}vendoremployee/inventory/stock-item-categories";

  static const productAddCategories =
      "${version2}vendoremployee/product/add-categories";

  static const AddStockCategories =
      "${version2}vendoremployee/inventory/stock-item-categories/store";

  static String updateCategories(int id) {
    String url = "${version1}vendoremployee/product/update-categories/$id";

    return url;
  }

  static String deleteCategories(int id) {
    String url = "${version2}vendoremployee/product/delete-categories/$id";

    return url;
  }

  static String categoriesStatusChange(int id) {
    String url =
        "${version2}vendoremployee/product/categories-status-change/$id";

    return url;
  }

  static const exportCategories =
      "${version2}vendoremployee/product/export-categories";

  static const exportWithoutAddon =
      "${version2}vendoremployee/product/export-without-addon";

  static const exportAddon =
      "${version2}vendoremployee/product/export-addon-list";

  static const productCategories =
      "${version2}vendoremployee/product/categories";

  //   static const allCategoryList = "${version1}categories"; // this is all category api
  static const allCategoryList =
      "/api/v1/vendoremployee/get-categories"; // this is resturant category api

  static const foodsFor = "${version2}vendoremployee/product/foods-for";

  static const allergensUri = "${version2}vendoremployee/product/allergens";

  static const getPurchaseReport =
      "${version2}vendoremployee/inventory/vendor-item-list";

  static const vendorType = "${version2}vendoremployee/inventory/vendor-type";

  static String deleteReport(int id) {
    String url = "${version2}vendoremployee/inventory/delete/$id";

    return url;
  }

  static String unitInventory(int id) {
    String url = "${version2}vendoremployee/inventory/unit-inventory/$id";

    return url;
  }

  static String addSingleStock(int id) {
    String url = "${version2}vendoremployee/inventory/add-stock/$id";

    return url;
  }

  static const addSubRecipeStock =
      "/api/v2/vendoremployee/inventory/add-sub-recipe-stock";

  static const importInventory =
      "${version2}vendoremployee/inventory/import-inventory";

  //* Wastage Report
  static const wastageReport =
      "${version2}vendoremployee/inventory/wastage-report";

  //* Daily Consumption Report
  static const dailyConsumptionReport =
      "${version2}vendoremployee/report/daily-consumption-report";
  static const exportConsumptionExcel =
      "${version2}vendoremployee/report/export-consumption-excel";

  //* Prep Serve Time Report
  static const prepServeTimeReport =
      "${version2}vendoremployee/report/food-sale-quantity-average";
  static const prepServeTimeReportExport =
      "${version2}vendoremployee/report/food-sale-quantity-average/export";

  //*Manage inventory
  static const getRecipeById = "${version2}vendoremployee/recipe/recipe/";

  //* recipe
  static const getRecipeList = "${version2}vendoremployee/recipe/get-recipe";

  static const getAllRecipeList = "${version2}vendoremployee/recipe/recipes";

  static const getRecipesIngredients =
      "${version2}vendoremployee/recipe/get-ingredients";

  static String deleteRecipe(int id) {
    String url = "${version2}vendoremployee/recipe/delete-recipe/$id";

    return url;
  }

  static const addRecipe = "${version2}vendoremployee/recipe/store-recipe";

  static String updateRecipe(int id) {
    String url = "${version2}vendoremployee/recipe/update-recipe/$id";

    return url;
  }

  static const exportRecipe = "${version2}vendoremployee/recipe/export-recipe";

  static const exportRecipeSample =
      "/api/v2/vendoremployee/recipe/export-sample-recipe";

  static const importRecipe = "${version2}vendoremployee/recipe/import-recipe";

  //*sub-recipe

  static const getSubRecipe = "/api/v2/vendoremployee/recipe/sub-recipes";

  static const addSubRecipe =
      "${version2}vendoremployee/recipe/store-sub-recipe";

  static const updateSubRecipe =
      "/api/v2/vendoremployee/recipe/update-sub-recipe/";

  static const deleteSubRecipe =
      "/api/v2/vendoremployee/recipe/delete-sub-recipe/";

  static const exportSubRecipes =
      "${version2}vendoremployee/recipe/export-sub-recipes";

  static const exportSubRecipeSample =
      "/api/v2/vendoremployee/recipe/export-sample-sub-recipe";

  static const importSubRecipes =
      "${version2}vendoremployee/recipe/import-sub-recipes";

  //* addon-recipe
  static const String GET_ADDON_RECIPE_LIST =
      '/api/v2/vendoremployee/product/addon-recipe-list';
  static const String ADD_ADDON_RECIPE =
      '/api/v2/vendoremployee/product/store-addon-recipe';
  static const String UPDATE_ADDON_RECIPE =
      '/api/v2/vendoremployee/product/update-addon-recipe';
  static const String GET_ADDONS_WITHOUT_RECIPE =
      '/api/v2/vendoremployee/product/addons-without-recipe';
  static const String DELETE_ADDON_RECIPE =
      '/api/v2/vendoremployee/product/delete-addon-recipe';

  //* wastage reason
  static const String wastageReasons =
      '/api/v2/vendoremployee/inventory/wastage-reasons';
  static const String wastageReasonsList =
      '/api/v2/vendoremployee/wastage-reasons/list';
  static const String wastageReasonsAdd =
      '/api/v2/vendoremployee/wastage-reasons/add';
  static String wastageReasonsStatus(int id) =>
      '/api/v2/vendoremployee/wastage-reasons/status/$id';
  static String wastageReasonsUpdate(int id) =>
      '/api/v2/vendoremployee/wastage-reasons/update/$id';
  static String wastageReasonsDelete(int id) =>
      '/api/v2/vendoremployee/wastage-reasons/delete/$id';

  //.........................INVENTORY MANAGEMENT..............................//

  //.........................EXPENSE MANAGEMENT..............................//

  static const manageExpenses =
      "${version2}vendoremployee/expense/expenses-report";
  static const masterExpenses =
      "${version2}vendoremployee/expense/expenses-list";

  static const expenseDownloadSample =
      "${version2}vendoremployee/expense/download-semple";

  static const expensePaymentMethod =
      "${version2}vendoremployee/expense/payment-method";

  static const expenseReport =
      "${version2}vendoremployee/expense/expenses-export-report";
  static const getUnit = "${version2}vendoremployee/expense/get-unit";

  static const expenseImportExpense =
      "${version2}vendoremployee/expense/import-expense";
  static const categoryList = "${version2}vendoremployee/expense/category-list";
  static const addCategory = "${version2}vendoremployee/expense/store_category";

  static String deleteManageExpense(int id) {
    String url = "${version2}vendoremployee/expense/delete-expense/$id";

    return url;
  }

  // static String editManageExpense(int id) {
  //   String url = "${version2}vendoremployee/expense/edit-expense/$id";
  //
  //   return url;
  // }

  static String updateDirectExpenses(int expId) {
    return "${version2}vendoremployee/expense/update-direct-expenses/$expId";
  }

  static const addMasterExpense =
      "${version2}vendoremployee/expense/store_expense";

  static String deleteMasterExpense(int id) {
    String url = "${version2}vendoremployee/expense/expenses/$id";

    return url;
  }

  static String editMasterExpense(int id) {
    String url = "${version2}vendoremployee/expense/expenses/$id";

    return url;
  }

  static const expenseStockImport =
      "/api/v2/vendoremployee/expense/bulk-import-expense";

  static const expenseStockExistingSampleExport =
      "/api/v2/vendoremployee/expense/bulk-export-expense";

  static const addManageExpense =
      "${version2}vendoremployee/expense/store-expense-details";

  static const stockUnitPrices =
      "${version2}vendoremployee/expense/stock-unit-prices";
  static const stockUnitPrice =
      "${version2}vendoremployee/expense/stock-unit-price";
  static String stockUnitPriceEdit(int id) =>
      "${version2}vendoremployee/expense/stock-unit-price/$id";
  static String stockUnitPriceDelete(int id) =>
      "${version2}vendoremployee/expense/stock-unit-price/$id";
  static const expensesWithoutUnitPrices =
      "${version2}vendoremployee/expense/expenses-without-unit-prices";

  static const importUnitPriceMaster =
      "/api/v2/vendoremployee/expense/bulk-import-stock-unit-price";

  static const exportUnitPriceMaster =
      "/api/v2/vendoremployee/expense/bulk-export-stock-unit-price";

  //.........................EXPENSE MANAGEMENT..............................//

  //.........................SETTLEMENT..............................//
  static const String SETTLEMENT_RESTAURANT_LIST =
      "${version1}vendoremployee/waiter/get-settlement-report";

  static const String WAITER_FULL_SETTLEMENT =
      "${version1}vendoremployee/waiter/settlement";

  static const String WAITER_PARTIAL_SETTLEMENT =
      "${version1}vendoremployee/waiter/settlement";

  static const String ADD_WAITER_OPENING_BALANCE =
      "${version1}vendoremployee/waiter/opening-balance";

  static const String ADD_DEDUCT_PILFERAGE =
      "${version1}vendoremployee/waiter/add-deduct-pilferage";

  static const String GET_WAITER_LIST =
      "${version1}vendoremployee/waiter/get-waiter-list";

  static const String SETTLEMENT_CLOSING_REPORT_URI =
      "${version1}vendoremployee/settlement-closing-report";
  static const String SETTLEMENT_CLOSING_REPORT_EXPORT_URI =
      "${version1}vendoremployee/settlement-closing-report/export";
  static const String SETTLEMENT_CLOSING_REPORT_NEW_URI =
      "${version1}vendoremployee/settlement-closing-report-new";

  static const String WAITER_SELF_SETTLEMENT =
      "${version1}vendoremployee/waiter/self-settlement";
  //.........................SETTLEMENT..............................//

  //.........................EMPLOYEE MANAGEMENT..............................//

  // Employee Management
  static const String Get_Employee_Management_List =
      '/api/v2/vendoremployee/employee/employees-list';
  static const String Update_Employee_Management_List =
      '/api/v2/vendoremployee/employee/employees-update/';
  static const String Add_Employee_Management_List =
      '/api/v2/vendoremployee/employee/employees-add';
  static const String Delete_Employee_Management_List =
      '/api/v2/vendoremployee/employee/employees-delete/';
  static const String Update_employee_status =
      '/api/v2/vendoremployee/employee/employee-status/';

  // Role Management
  static const String Get_Role_Management_List =
      '/api/v1/vendoremployee/employee/role-list';
  static const String Get_All_Role_Types_Modules =
      '/api/v2/vendoremployee/employee/all-role-list';
  static const String Get_All_Master_Role =
      '/api/v1/vendoremployee/employee/role-master-list';
  static const String Update_Role_Management_List =
      '/api/v1/vendoremployee/employee/role-update/';
  static const String Add_Role_Management_List =
      '/api/v1/vendoremployee/employee/role-add';
  static const String ROLE_STATUS_UPDATE =
      '/api/v2/vendoremployee/employee/role-status-update/';

  //.........................EMPLOYEE MANAGEMENT..............................//

  //.........................LOYALTY PROGRAM..............................//

  static const String Get_Conversion_Rate_List =
      '/api/v1/vendoremployee/loyalty/conversionRate/get';

  static const String Add_Conversion_Rate =
      '/api/v1/vendoremployee/loyalty/conversionRate/create';

  static const String Update_Conversion_Rate =
      '/api/v1/vendoremployee/loyalty/conversionRate/update';

  static const String Delete_Conversion_Rate =
      '/api/v1/vendoremployee/loyalty/conversionRate/delete';

  //*****************************************************//

  static const String Get_Redemption_Rate_List =
      '/api/v1/vendoremployee/loyalty/redemptionRule/get';

  static const String Add_Redemption_Rate =
      '/api/v1/vendoremployee/loyalty/redemptionRule/create';

  static const String Update_Redemption_Rate =
      '/api/v1/vendoremployee/loyalty/redemptionRule/update';

  static const String Delete_Redemption_Rate =
      '/api/v1/vendoremployee/loyalty/redemptionRule/delete';

  //*****************************************************//

  static const String Create_Coupon =
      '/api/v1/vendoremployee/loyalty/discountCoupon/create';
  static const String checkValidCouponUri =
      '/api/v1/vendoremployee/loyalty/discountCoupon/validate';
  static const String redeemCouponUri =
      '/api/v1/vendoremployee/loyalty/discountCoupon/redeem';
  static const String checkValidLoyaltyPointUri =
      '/api/v1/vendoremployee/loyalty/points/validate-redeem-point';

  static const String Get_Coupon_List =
      '/api/v1/vendoremployee/loyalty/discountCoupon/get';

  static const String Update_Coupon =
      '/api/v1/vendoremployee/loyalty/discountCoupon/update/';

  static const String Delete_Coupon =
      '/api/v1/vendoremployee/loyalty/discountCoupon/delete/';

  //.........................LOYALTY PROGRAM..............................//

  //.........................RESTURANT CONFIGURATION..............................//

  //* Restuarnt Settings

  static const String Get_Resturant_setting =
      '/api/v2/vendoremployee/restaurant-settings/settings-list';

  static const String Update_Resturant_Setting =
      '/api/v2/vendoremployee/restaurant-settings/update-settings';

  //* Delivery Management

  static const String Get_Delivery_Config =
      '/api/v2/vendoremployee/restaurant-settings/delivery-config';

  static const String Update_Delivery_Config =
      '/api/v2/vendoremployee/restaurant-settings/update-delivery-config';

  static const String Add_Delivery_Charge =
      '/api/v2/vendoremployee/restaurant-settings/delivery-charges';

  static const String Delete_Delivery_Charge =
      '/api/v2/vendoremployee/restaurant-settings/delivery-charges/';

  //* Printer Management

  // Get all printer configurations list
  static const String Get_Printer_List =
      '/api/v2/vendoremployee/restaurant-settings/printer-config';

  // Get area/station options for printer configuration
  static const String Get_Printer_Area_Options =
      '/api/v2/vendoremployee/restaurant-settings/printer-config/area-options';

  // Add or update printer configuration (same endpoint for both)
  static const String Save_Printer_Config =
      '/api/v2/vendoremployee/restaurant-settings/printer-config';

  // Delete printer configuration by ID
  static const String Delete_Printer_Config =
      '/api/v2/vendoremployee/restaurant-settings/printer-config/';

  // Get current printing option/mode (fixed/waiter/station)
  // POST same endpoint to update printing option with restaurant_id and printing_option
  static const String Printing_Option =
      '/api/v2/vendoremployee/restaurant-settings/printing-option';

  //* Table Management

  // Get all table configurations list
  static const String TABLE_CONFIG_LIST =
      '/api/v2/vendoremployee/restaurant-settings/table-config';

  // Get area options for table configuration
  static const String TABLE_CONFIG_AREA_OPTIONS =
      '/api/v2/vendoremployee/restaurant-settings/table-config/area-options';

  // Get waiter list for table configuration
  static const String TABLE_CONFIG_WAITER_LIST =
      '/api/v2/vendoremployee/restaurant-settings/table-config/waiter-list';

  // Add new table configuration
  static const String TABLE_CONFIG_STORE =
      '/api/v2/vendoremployee/restaurant-settings/table-config/store';

  // Update existing table configuration
  static const String TABLE_CONFIG_UPDATE =
      '/api/v2/vendoremployee/restaurant-settings/table-config/store';

  // Delete table configuration by ID
  static const String TABLE_CONFIG_DELETE =
      '/api/v2/vendoremployee/restaurant-settings/table-config/';

  // Export sample template for table configuration
  static const String TABLE_CONFIG_EXPORT_SAMPLE =
      '/api/v2/vendoremployee/restaurant-settings/table-config/export-sample';

  // Export existing table list
  static const String TABLE_CONFIG_EXPORT_LIST =
      '/api/v2/vendoremployee/restaurant-settings/table-config/export-list';

  // Import table configuration (bulk upload)
  static const String TABLE_CONFIG_IMPORT =
      '/api/v2/vendoremployee/restaurant-settings/table-config/import';

  // Get table QR codes PDF
  static const String TABLE_CONFIG_QR_CODES =
      '/api/v2/vendoremployee/restaurant-settings/table-qr-codes';

  static const String CHECK_QR_PDF_STATUS_URI =
      '/api/v2/vendoremployee/restaurant-settings/qr-pdf-status';

  //* Payment Types
  static const String Payment_Types =
      '/api/v2/vendoremployee/restaurant-settings/payment-types';

  //.........................RESTURANT CONFIGURATION..............................//

  //.........................ADMIN SUPPORT..............................//

  static const String LOGIN_AS_RESTAURANT_URI =
      '/api/v1/auth/adminemployee/login-as-restaurant';
  static const String ASSIGNED_RESTAURANTS_URI =
      '/api/v1/auth/adminemployee/assigned-restaurants';
  //.........................ADMIN SUPPORT..............................//

  //.........................PROFIT LOSS REPORT..............................//
  static const String profitLossReport =
      "/api/v1/vendoremployee/profit-loss-report";
  //.........................PROFIT LOSS REPORT..............................//

  //.........................COUPON USAGE REPORT..............................//
  static const String couponUsageReport =
      "/api/v2/vendoremployee/report/coupon-usage-report";
  static const String couponUsageReportExport =
      "/api/v2/vendoremployee/report/coupon-usage-report/export";
  //.........................COUPON USAGE REPORT..............................//

  // Shared Key
  static const String THEME = 'theme';
  static const String INTRO = 'intro';
  static const String TOKEN = 'multivendor_restaurant_token';
  static const String CRM_TOKEN = 'crm_token';
  static const String COUNTRY_CODE = 'country_code';
  static const String LANGUAGE_CODE = 'language_code';
  static const String CART_LIST = 'cart_list';
  static const String USER_PASSWORD = 'user_password';
  static const String USER_PASSWORD_BIOMATRIC = 'user_password_biomatric';
  static const String USER_ADDRESS = 'user_address';
  static const String USER_NUMBER = 'user_number';
  static const String USER_EMAIL = 'user_email';
  static const String NOTIFICATION = 'notification';
  static const String NOTIFICATION_COUNT = 'notification_count';
  static const String SEARCH_HISTORY = 'search_history';
  static const String TOPIC = 'all_zone_restaurant';
  static const String ROLE = 'role';
  static const String PRODUCTLIST = 'product_list';
  static const String ORDERLIST = 'order_list';
  static const String TABLELIST = 'table_list';
  static const String LASTORDERID = 'last_order_id';
  static const String CATEGORYLIST = 'category_list';
  static const String EMPLOYEEPROFILE = 'employee_profile';
  static const String EMPLOYEELIST = 'employee_list';
  static const String ZONE_TOPIC = 'zone_topic';
  static const String LOCALIZATION_KEY = 'X-localization';

  // Admin Session Keys
  static const String ADMIN_TOKEN = 'admin_token';
  static const String ADMIN_EMAIL = 'admin_email';
  static const String IS_ADMIN_SESSION = 'is_admin_session';
  static const String RESTAURANT_TOKEN = 'restaurant_token';

  static List<LanguageModel> languages = [
    LanguageModel(
      imageUrl: Images.english,
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: Images.arabic,
      languageName: 'Arabic',
      countryCode: 'SA',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: Images.spanish,
      languageName: 'Spanish',
      countryCode: 'ES',
      languageCode: 'es',
    ),
  ];

  //.........................CUSTOMER MANAGEMENT..............................//
  static const String RESTAURANT_CUSTOMER_LIST_REPORT_URI =
      '/api/v2/vendoremployee/report/restaurant-customer-list';
  static const String EXPORT_CUSTOMER_LIST_EXCEL_URI =
      '/api/v2/vendoremployee/report/export-customer-list-excel';

  // Customer Designations
  static const String customerDesignationsList =
      '/api/v2/vendoremployee/restaurant-settings/customer-designations';
  static const String customerDesignationsAdd =
      '/api/v2/vendoremployee/restaurant-settings/customer-designations';
  static String customerDesignationsToggleStatus(int id) =>
      '/api/v2/vendoremployee/restaurant-settings/customer-designations/$id/toggle-status';
  static String customerDesignationsDelete(int id) =>
      '/api/v2/vendoremployee/restaurant-settings/customer-designations/$id';

  //.........................CUSTOMER MANAGEMENT..............................//
}

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 600;
}

bool isTablet(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  return width >= 600 && width < 1100;
}

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1100;
}
