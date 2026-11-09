import 'dart:io';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/base/base_controller.dart';
import '../../helper/firebase_helper.dart';

class PopupRatingController extends BaseController {
  PopupRatingController();
  RxDouble currentStar = 5.0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FirebaseHelper.setTrackingScreenName("Rating");
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  updateRating(value) {
    currentStar.value = value;
  }

  onSelectSubmit() {
    if (currentStar.value > 3) {
      if (Platform.isAndroid || Platform.isIOS) {
        final url = Uri.parse(
          Platform.isAndroid
              ? "https://play.google.com/store/apps/details?id=com.aichat.chatbotai.lovechat"
              : "",
        );
        launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        Get.back();
      }
    } else {
      Get.back(result: "showlog");
    }
  }

  onSelectBack() {
    Get.back();
  }
}
