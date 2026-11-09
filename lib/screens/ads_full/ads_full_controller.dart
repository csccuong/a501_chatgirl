import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../helper/firebase_remote_config_service.dart';

class AdsFullController extends BaseController {
  RxBool shouldShowCloseNativeFull = false.obs;
  RxBool shouldShowNativeFullAd = false.obs;

  @override
  void onInit() {
    super.onInit();
    showCloseButton();
  }

  showCloseButton() {
    var delay = FirebaseRemoteConfigService.getIntConfigByKey(FirebaseRemoteConfigService.timeDelayCloseNativeFull) > 0
        ? FirebaseRemoteConfigService.getIntConfigByKey(FirebaseRemoteConfigService.timeDelayCloseNativeFull)
        : 3;
    Future.delayed(Duration(seconds: delay), () {
      shouldShowCloseNativeFull.value = true;
    });
  }

  closeAdFull() {
    shouldShowCloseNativeFull.value = false;
    shouldShowNativeFullAd.value = false;
    Get.back();
  }
}