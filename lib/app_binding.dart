import 'package:get/get.dart';

import 'api_rest/api_repository.dart';
import 'screens/profile/profile_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put(ApiRepository(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}
