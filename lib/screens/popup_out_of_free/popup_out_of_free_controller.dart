import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';

class PopupOutOfFreeController extends BaseController {
  final VoidCallback? onWatchAdSuccess;

  PopupOutOfFreeController({this.onWatchAdSuccess});

  void onSelectGoAdFree() {
    Get.back(); // Dismiss the popup
  }

  void onSelectWatchAds() {
    EasyAds.instance.showRewardAd(
      Get.context!,
      adId: MyAdIdName.rewardedAd.getId,
      adDissmissed: () {
        Get.back(); // close popup
        if (onWatchAdSuccess != null) {
          onWatchAdSuccess!();
        }
      },
      onFailed: () {
        // Fallback or alert user
      },
    );
  }

  void onCloseButton() {
    Get.back();
  }
}
