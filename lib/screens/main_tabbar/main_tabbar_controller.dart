import 'dart:async';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../api_rest/api_repository.dart';
import '../../helper/firebase_helper.dart';

class MainTabbarController extends BaseController {
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _silentGuestLogin();
    FirebaseHelper.setTrackingScreenName("MainTabScreen");
  }

  Future<void> _silentGuestLogin() async {
    try {
      await ApiRepository().loginWeifu(firebaseToken: null);
    } catch (e) {
      print("Silent guest login failed: $e");
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  requestPermisstion() async {
    await Permission.notification.request();
    await FirebaseMessaging.instance.requestPermission(provisional: true);
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      // APNS token is available, make FCM plugin API requests...
    }
  }
}
