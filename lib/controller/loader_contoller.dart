import 'package:get/get.dart';

class LoadingController extends GetxController implements GetxService {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isError = false;
  String _text = 'Loading..';

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get isError => _isError;
  String get text => _text;

  startLoading(bool data) {
    _isLoading = data;
    update();
  }

  changeStatus({bool data = false}) {
    _isSuccess = data;
    update();
  }

  changeText({String data = 'Please wait..', bool error = false}) {
    _text = data;
    _isError = error;
    update();
  }
}
