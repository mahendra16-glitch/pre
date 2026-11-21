import 'dart:async';
import 'dart:io';
import 'package:mygenie_restaurant/controller/localization_controller.dart';
import 'package:mygenie_restaurant/controller/theme_controller.dart';
import 'package:mygenie_restaurant/data/model/body/notification_body.dart';
import 'package:mygenie_restaurant/helper/notification_helper.dart';
import 'package:mygenie_restaurant/helper/route_helper.dart';
import 'package:mygenie_restaurant/theme/dark_theme.dart';
import 'package:mygenie_restaurant/theme/light_theme.dart';
import 'package:mygenie_restaurant/util/app_constants.dart';
import 'package:mygenie_restaurant/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter/foundation.dart';
import 'package:win_toast/win_toast.dart';
import 'helper/get_di.dart' as di;
import 'package:device_preview/device_preview.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!GetPlatform.isWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();

  // await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  // await Firebase.initializeApp();
  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp();
  }
  final Map<String, Map<String, String>> languages = await di.init();
  if (!GetPlatform.isWindows)
    await RestaurantNotificationHelper().initNotification();
  if (GetPlatform.isWindows) {
    await WinToast.instance().initialize(
      aumId: "com.mygenie.online",
      displayName: "MyGenie Restaurant",

      iconPath:
          "C:\Users\Administrator\Desktop\MygenieRestaurantApp\windows\runner\resources\app_icon.ico", // relative to project root
      clsid: "{1AC9EED6-65F5-48D8-95D4-03C80D66A19B}",
    );
  }
  NotificationBody? body;
  try {
    // Uncomment and update if you want to handle initial notification
    // if (GetPlatform.isMobile) {
    //   final RemoteMessage? remoteMessage =
    //       await FirebaseMessaging.instance.getInitialMessage();
    //   if (remoteMessage != null) {
    //     body = NotificationHelper.convertNotification(remoteMessage.data);
    //   }
    //   await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    //   FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    // }
  } catch (e) {}

  runApp(MyApp(languages: languages, body: body));
  //  runApp(
  //   DevicePreview(
  //     enabled: !bool.fromEnvironment('dart.vm.product'), // Disable in release
  //     builder: (context) => MyApp(languages: languages, body: body),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBody? body;
  const MyApp({Key? key, required this.languages, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return GetBuilder<ThemeController>(builder: (themeController) {
          return GetBuilder<LocalizationController>(
              builder: (localizeController) {
            return GetMaterialApp(
              title: AppConstants.APP_NAME,
              //     useInheritedMediaQuery: true, // <- Important for DevicePreview
              // builder: DevicePreview.appBuilder, // <- Important
              debugShowCheckedModeBanner: false,
              navigatorKey: Get.key,
              theme: themeController.darkTheme ? dark : light,
              locale: localizeController.locale,
              translations: Messages(languages: languages!),
              fallbackLocale: Locale(
                AppConstants.languages[0].languageCode,
                AppConstants.languages[0].countryCode,
              ),
              initialRoute: RouteHelper.getSplashRoute(body),
              getPages: RouteHelper.routes,
              defaultTransition: Transition.topLevel,
              transitionDuration: const Duration(milliseconds: 500),
            );
          });
        });
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
