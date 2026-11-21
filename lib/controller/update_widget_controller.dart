import 'package:get/get.dart';

class UpdateWidgetController extends GetxController implements GetxService {
  String _orderId = '';
  String _itemId = '';
  bool _isInternetConnection = false;
  String get orderId => _orderId;
  String get itemId => _itemId;
  bool get isInternetConnection => _isInternetConnection;

  void updateWidget(String orderId) {
    _orderId = orderId;
    update();
  }

  void updateFoodUi(String orderId) {
    _itemId = orderId;
    update();
  }

  void updateInternetStatus(bool value) {
    _isInternetConnection = value;
    update();
  }
}
