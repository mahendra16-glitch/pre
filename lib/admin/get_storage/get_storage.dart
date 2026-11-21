import 'package:get_storage/get_storage.dart';

class GetStoragePref {
  final box = GetStorage();

  setValue(String key, bool value) {
    box.write(key, value);
  }

  bool getValue(String key) {
    return box.read(key) ?? true;
  }
}
