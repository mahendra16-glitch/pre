import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

Future<void> appLaunchUrl(String url) async {
  final Uri uri = Uri.parse(url);

  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      log('Could not launch $url');
    }
  } catch (e) {
    log("launchUrl error: $e");
  }
}
