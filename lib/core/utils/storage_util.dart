import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil extends GetxService {
  Future<SharedPreferences> init() async {
    return await SharedPreferences.getInstance();
  }
}
