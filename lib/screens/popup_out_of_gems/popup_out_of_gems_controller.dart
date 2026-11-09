import 'dart:io';
import 'dart:ui';
import 'package:cscmobi_app/core/utils/app_util.dart';
import 'package:cscmobi_app/core/values/constants.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/base/base_controller.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/reward_ads_claim_helper.dart';
import '../../routes/app_pages.dart';
import '../../utils/app_setting.dart';
import '../premium/premium_controller.dart';
import '../premium/premium_page.dart';
import '../profile/profile_controller.dart';

class PopupOutOfGemsController extends BaseController {
  final VoidCallback? onWatchAdSuccess;
  final VoidCallback? onGoPremium;

  PopupOutOfGemsController({this.onWatchAdSuccess, this.onGoPremium});

  var adsWatchedToday = 0.obs;
  var maxAdsToday = 5.obs;

  ProfileController get profileController =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  @override
  void onInit() {
    super.onInit();
    FirebaseHelper.setTrackingScreenName("PopupOutOfGems");
    _fetchAdsCount();
  }

  void _fetchAdsCount() {
    adsWatchedToday.value = AppSetting().getCountWatchAdReward() ?? 0;
    // Sync with server data if available
    if (Get.isRegistered<ProfileController>()) {
      final checkinData = Get.find<ProfileController>().checkinStatusData.value;
      if (checkinData != null) {
        if (checkinData['ads_claimed_today'] != null) {
          adsWatchedToday.value = checkinData['ads_claimed_today'];
        }
        if (checkinData['ads_max_per_day'] != null) {
          maxAdsToday.value = (checkinData['ads_max_per_day'] as num).toInt();
        }
      }
    }
  }

  void onCloseButton() {
    Get.back();
  }

  void onWatchAd() {
    RewardAdsClaimHelper.runClaimFlow(
      onWatchAdSuccess: () {
        _fetchAdsCount();
        
        if (this.onWatchAdSuccess != null) {
          this.onWatchAdSuccess!();
        }

        Get.back(); // close popup
      },
    );
  }

  void onGoToShop() {
    Get.back();
    if (onGoPremium != null) {
      onGoPremium!();
    } else {
      Get.toWithController(
        controllerBuilder: () => PremiumController(),
        page: () => const PremiumPage(),
        routeName: AppRoutes.PREMIUM,
      );
    }
  }
}
