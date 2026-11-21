import 'dart:convert';

import 'package:mygenie_restaurant/data/model/body/notification_body.dart';
import 'package:mygenie_restaurant/data/model/response/category_model.dart';
import 'package:mygenie_restaurant/data/model/response/conversation_model.dart';
import 'package:mygenie_restaurant/data/model/response/delivery_man_model.dart';
import 'package:mygenie_restaurant/data/model/response/product_model.dart';
import 'package:mygenie_restaurant/data/model/response/profile_model.dart';
import 'package:mygenie_restaurant/view/screens/admin/admin_dashboard_screen.dart';
import 'package:mygenie_restaurant/view/screens/auth/sign_in_screen.dart';
import 'package:mygenie_restaurant/view/screens/billing/billing_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/check_in/check_in.dart';
import 'package:mygenie_restaurant/view/screens/KDS/home/kds_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/hyatt/home_screen.dart';
import 'package:mygenie_restaurant/view/screens/new_ui/online_delivery_mode/online_delivery_mode_UI.dart';
import 'package:mygenie_restaurant/view/screens/token_display/token_display.dart';
import 'package:mygenie_restaurant/view/screens/waiter/collect_payment/collect_payment.dart';
import 'package:mygenie_restaurant/view/screens/waiter/home/waiter_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/paid_order/paid_order_detail_page.dart';
import 'package:mygenie_restaurant/view/screens/waiter/room_managment/room_managment.dart';
import 'package:mygenie_restaurant/view/screens/waiter/room_managment/widget/view_room_bills.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/check_in/check_in_tablet.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tablet_screen/home/tablet_home_screen.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/tap_managment.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/widget/tab_bill_detail_page.dart';
import 'package:mygenie_restaurant/view/screens/waiter/tap_managment/widget/view_tab_bills.dart';
import 'package:mygenie_restaurant/view/screens/forget/employee_reset_password.dart';
import 'package:mygenie_restaurant/view/screens/forget/forget_pass_screen.dart';
import 'package:mygenie_restaurant/view/screens/forget/new_pass_screen.dart';
import 'package:mygenie_restaurant/view/screens/splash/splash_screen.dart';
import 'package:get/get.dart';

import '../view/screens/deliveryman/home_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String initialWaiterDashboard = '/initial-waiter-dashboard';
  static const String initialBillingDashboard = '/initial-billing-dashboard';
  static const String initialDeliveryDashboard = '/initial-delivery-dashboard';
  // static const String initialTabWaiterDashboard =
  //     '/initial-tab-waiter-dashboard';
  static const String signIn = '/sign-in';
  static const String verification = '/verification';
  static const String main = '/main';
  // static const String waiter_home = '/waiter-home';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String employeeResetPassword = '/employee-reset-password';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String notification = '/notification';
  static const String bankInfo = '/bank-info';
  static const String wallet = '/wallet';
  static const String withdrawHistory = '/withdraw-history';
  static const String restaurant = '/restaurant';
  static const String campaign = '/campaign';
  static const String campaignDetails = '/campaign-details';
  static const String product = '/product';
  static const String addProduct = '/add-product';
  static const String categories = '/categories';
  static const String subCategories = '/sub-categories';
  static const String restaurantSettings = '/restaurant-settings';
  static const String addons = '/addons';
  // static const String productDetails = '/product-details';
  static const String deliveryMan = '/delivery-man';
  static const String pos = '/pos';
  static const String tapManagement = '/tab-management';
  static const String roomManagement = '/room-management';
  static const String tabletTapManagement = '/tablet-tab-management';
  static const String kdsHome = '/kdsHome';
  static const String tokenDisplayHome = '/token-display-home';
  static const String homeScreenTableView = '/homeScreenTableView';
  static const String initialBuffetHome = '/initial-buffet-home';
  // static const String posCartScreen = '/pos-cart-screen';
  // static const String editWalkInOrder = '/edit-walkin-order';
  // static const String editWalkInAddProduct = '/edit-walkin-add-product';
  static const String addDeliveryMan = '/add-delivery-man';
  static const String deliveryManDetails = '/delivery-man-details';
  static const String terms = '/terms-and-condition';
  static const String privacy = '/privacy-policy';
  static const String update = '/update';
  static const String chatScreen = '/chat-screen';
  static const String conversationListScreen = '/chat-list-screen';
  static const String restaurantRegistration = '/restaurant-registration';
  static const String subscriptionView = '/subscriptionView';
  static const String renewSubscription = '/renew-subscription';
  static const String coupon = '/coupon';
  static const String expense = '/expense';
  static const String collectPayment = '/collect-payment';
  static const String paidOrderDetail = '/paid-order-detail';
  static const String viewTabBills = '/view-tab-bills';
  static const String viewRoomBills = '/view-room-bills';
  static const String tabletViewTabBills = '/tablet-view-tab-bills';
  static const String tabBillDetail = '/tab-bill-detail';
  static const String checkIn = '/check-in';
  static const String checkInTablet = '/check-in-tablet';
  static const String tabletTabBillDetail = '/tablet-tab-bill-detail';
  static const String adminDashboard = '/admin-dashboard';

  static String getInitialRoute() => initial;
  static String getBuffetInitialRoute() => '$initialBuffetHome';
  static String getWaiterDashboardInitialRoute() => initialWaiterDashboard;
  static String getBillingDashboardInitialRoute() => initialBillingDashboard;
  static String getDeliveryDashboardInitialRoute() => initialDeliveryDashboard;
  // static String getTablateWaiterDashboardInitialRoute() =>
  //     initialTabWaiterDashboard;
  static String getSplashRoute(NotificationBody? body) {
    String _data = 'null';
    if (body != null) {
      List<int> _encoded = utf8.encode(jsonEncode(body.toJson()));
      _data = base64Encode(_encoded);
    }
    return '$splash?data=$_data';
  }

  static String getLanguageRoute(String page) => '$language?page=$page';
  static String getSignInRoute() => signIn;
  static String getVerificationRoute(String email) =>
      '$verification?email=$email';
  static String getMainRoute(String page) => '$main?page=$page';
  static String getForgotPassRoute() => forgotPassword;
  static String getResetPasswordRoute(
          String phone, String token, String page) =>
      '$resetPassword?phone=$phone&token=$token&page=$page';
  static String getEmployeeResetPasswordRoute(
          String phone, String token, String page,
          {String password = ''}) =>
      '$employeeResetPassword?phone=$phone&token=$token&page=$page&password=$password';
  static String getOrderDetailsRoute(int orderID) =>
      '$orderDetails?id=$orderID';
  static String getProfileRoute() => profile;
  static String getTapManagementRoute() => tapManagement;
  static String getRoomManagementRoute() => roomManagement;
  // static String getWaiterHomeRoute() => waiter_home;
  static String getUpdateProfileRoute() => updateProfile;
  static String getNotificationRoute({bool fromNotification = false}) =>
      '$notification?from_notification=$fromNotification';
  static String getBankInfoRoute() => bankInfo;
  static String getWalletRoute() => wallet;
  static String getAdminDashboardRoute() => adminDashboard;

  static String getWaiterCollectPaymentRoute(String orderId) {
    return '$collectPayment?orderId=$orderId';
  }

  static String gePaidOrderDetailtRoute(String orderId) {
    return '$paidOrderDetail?orderId=$orderId';
  }

  static String getViewTabBills(String customerId, String name, String phone) {
    return '$viewTabBills?customerId=$customerId&name=$name&phone=$phone';
  }

  static String getViewRoomBills(String roomId, String roomName) {
    return '$viewRoomBills?room_id=$roomId&roomName=$roomName';
  }

  static String getTabletViewTabBills(
      String customerId, String name, String phone) {
    return '$tabletViewTabBills?customerId=$customerId&name=$name&phone=$phone';
  }

  static String getTabBillDetail(String orderId, String name, String phone) {
    return '$tabBillDetail?orderId=$orderId&name=$name&phone=$phone';
  }

  static String getCheckIn(String email, String name, String phone) {
    return '$checkIn?email$email&name=$name&phone=$phone';
  }

  static String getCheckInTablet(String email, String name, String phone) {
    return '$checkInTablet?email$email&name=$name&phone=$phone';
  }

  static String getTabletTabBillDetail(
      String orderId, String name, String phone) {
    return '$tabletTabBillDetail?orderId=$orderId&name=$name&phone=$phone';
  }

  static String getKdsHomeRoute() => kdsHome;
  static String gettokenDisplayHomeRoute() => tokenDisplayHome;
  static String getTableViewHomeRoute() => homeScreenTableView;
  static String getWithdrawHistoryRoute() => withdrawHistory;
  static String getRestaurantRoute() => restaurant;
  static String getCampaignRoute() => campaign;
  static String getCampaignDetailsRoute(int id) => '$campaignDetails?id=$id';
  static String getUpdateRoute(bool isUpdate) => '$update?update=$isUpdate';
  static String getProductRoute(Product? productModel) {
    if (productModel == null) {
      return '$product?data=null';
    }
    List<int> _encoded = utf8.encode(jsonEncode(productModel.toJson()));
    String _data = base64Encode(_encoded);
    return '$product?data=$_data';
  }

  static String getAddProductRoute(
      Product? productModel, List<Translation> translations) {
    String _translations = base64Encode(utf8.encode(jsonEncode(translations)));
    if (productModel == null) {
      return '$addProduct?data=null&translations=$_translations';
    }
    String _data = base64Encode(utf8.encode(jsonEncode(productModel.toJson())));
    return '$addProduct?data=$_data&translations=$_translations';
  }

  static String getCategoriesRoute() => categories;
  static String getCouponRoute() => coupon;
  static String getSubCategoriesRoute(CategoryModel categoryModel) {
    List<int> _encoded = utf8.encode(jsonEncode(categoryModel.toJson()));
    String _data = base64Encode(_encoded);
    return '$subCategories?data=$_data';
  }

  static String getRestaurantSettingsRoute(Restaurant restaurant) {
    List<int> _encoded = utf8.encode(jsonEncode(restaurant.toJson()));
    String _data = base64Encode(_encoded);
    return '$restaurantSettings?data=$_data';
  }

  static String getAddonsRoute() => addons;

  static String getPosRoute() => pos;
  static String getDeliveryManRoute() => deliveryMan;
  static String getAddDeliveryManRoute(DeliveryManModel? deliveryMan) {
    if (deliveryMan == null) {
      return '$addDeliveryMan?data=null';
    }
    List<int> _encoded = utf8.encode(jsonEncode(deliveryMan.toJson()));
    String _data = base64Encode(_encoded);
    return '$addDeliveryMan?data=$_data';
  }

  static String getDeliveryManDetailsRoute(DeliveryManModel deliveryMan) {
    List<int> _encoded = utf8.encode(jsonEncode(deliveryMan.toJson()));
    String _data = base64Encode(_encoded);
    return '$deliveryManDetails?data=$_data';
  }

  static String getTermsRoute() => terms;
  static String getPrivacyRoute() => privacy;
  static String getChatRoute({
    required NotificationBody notificationBody,
    User? user,
    int? conversationId,
  }) {
    String _notificationBody = 'null';
    String _user = 'null';

    _notificationBody = base64Encode(utf8.encode(jsonEncode(notificationBody)));
    if (user != null) {
      _user = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    return '$chatScreen?notification_body=$_notificationBody&user=$_user&conversation_id=$conversationId';
  }

  static String getConversationListRoute() => conversationListScreen;
  static String getRestaurantRegistrationRoute() => restaurantRegistration;
  static String getSubscriptionViewRoute() => subscriptionView;
  static String getRenewSubscriptionRoute() => renewSubscription;
  static String getExpenseRoute() => expense;

  static List<GetPage> routes = [
    // GetPage(name: initialWaiterDashboard, page: () => WaiterHomeScreen()),
    GetPage(name: initialBillingDashboard, page: () => BillingHomeScreen()),
    GetPage(name: initialDeliveryDashboard, page: () => DeliveyMenHomeScreen()),
    GetPage(name: initialBuffetHome, page: () => BuffetHomeScreen()),

    // GetPage(
    //     name: initialTabWaiterDashboard, page: () => TabletWaiterHomeScreen()),
    GetPage(
        name: splash,
        page: () {
          NotificationBody? _data;
          if (Get.parameters['data'] != 'null') {
            List<int> _decode =
                base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
            _data = NotificationBody.fromJson(jsonDecode(utf8.decode(_decode)));
          }
          return SplashScreen(body: _data ?? NotificationBody());
        }),
    GetPage(name: signIn, page: () => SignInScreen()),
    GetPage(name: forgotPassword, page: () => ForgetPassScreen()),
    GetPage(
        name: resetPassword,
        page: () => NewPassScreen(
              resetToken: Get.parameters['token'] ?? '',
              email: Get.parameters['phone'] ?? '',
              fromPasswordChange: Get.parameters['page'] == 'password-change',
            )),
    GetPage(
        name: employeeResetPassword,
        page: () => EmployeeResetPassword(
              resetToken: Get.parameters['token'] ?? '',
              email: Get.parameters['phone'] ?? '',
              password: Get.parameters['password'] ?? '',
              fromPasswordChange: Get.parameters['page'] == 'password-change',
            )),
    // GetPage(name: waiter_home, page: () => WaiterHomeScreen()),
    GetPage(name: tapManagement, page: () => TapManagementPage()),
    GetPage(name: roomManagement, page: () => RoomManagementPage()),
    GetPage(name: kdsHome, page: () => KDSHomeScreen()),
    GetPage(name: tokenDisplayHome, page: () => TokenDisplayHomeScreen()),
    GetPage(name: homeScreenTableView, page: () => OrderManagementScreen()),
    GetPage(
        name: collectPayment,
        page: () {
          return CollectPayment(orderId: Get.parameters['orderId'] ?? '');
        }),
    GetPage(
        name: paidOrderDetail,
        page: () {
          return PaidOrderDetailPage(orderId: Get.parameters['orderId'] ?? '');
        }),
    GetPage(
        name: viewTabBills,
        page: () {
          return ViewTabBills(
              name: '${Get.parameters['name']}',
              phone: '${Get.parameters['phone']}',
              customerId: '${Get.parameters['customerId']}');
        }),
    GetPage(
        name: viewRoomBills,
        page: () {
          return ViewRoomBills(
              roomId: '${Get.parameters['room_id']}',
              roomName: '${Get.parameters['roomName']}');
        }),
    GetPage(
        name: tabBillDetail,
        page: () {
          return TabBillDetailPage(
              name: '${Get.parameters['name']}',
              phone: '${Get.parameters['phone']}',
              orderId: '${Get.parameters['orderId']}');
        }),
    GetPage(
        name: checkIn,
        page: () {
          return CheckIn();
        }),
    GetPage(
        name: checkInTablet,
        page: () {
          return CheckInTablet();
        }),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardScreen(),
    ),
  ];
}
