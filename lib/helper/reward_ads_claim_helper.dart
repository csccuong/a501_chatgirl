import 'dart:ui';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../api_rest/api_repository.dart';
import '../core/utils/app_util.dart';
import '../models/user_model.dart';
import '../screens/profile/profile_controller.dart';
import '../utils/app_setting.dart';
import '../core/values/constants.dart';
import '../ads/const/ad_id_name.dart';
import '../ads/const/ad_id_extension.dart';

class RewardAdsClaimHelper {
  static Future<void> runClaimFlow({ApiRepository? apiRepository, VoidCallback? onWatchAdSuccess}) async {
    int maxAdsToday = 5;
    int adsWatchedToday = AppSetting().getCountWatchAdReward() ?? 0;

    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      final data = profileCtrl.checkinStatusData.value;
      if (data != null) {
        if (data['ads_max_per_day'] != null) {
          maxAdsToday = (data['ads_max_per_day'] as num).toInt();
        }
        if (data['ads_claimed_today'] != null) {
          adsWatchedToday = (data['ads_claimed_today'] as num).toInt();
        }
      }
    }

    if (adsWatchedToday >= maxAdsToday) {
      AppUtil.showNormalToast("You have reached the maximum number of ads for today.".tr);
      return;
    }

    final api = apiRepository ?? ApiRepository();
    print("show rewarded ad");

    EasyAds.instance.showRewardAd(
      Get.context!,
      adId: MyAdIdName.rewardedAd.getId,
      onShowed: () {
        print("Rewarded ad showed");
      },
      adDissmissed: () async {
        print("rewarded ad finished, claim reward");
        adsWatchedToday++;
        Constants.countWatchAdReward = adsWatchedToday;
        AppSetting().saveCountWatchAdReward();
        
        await _claimReward(api, adsWatchedToday, maxAdsToday);

        if (onWatchAdSuccess != null) {
          onWatchAdSuccess();
        }
      },
      onFailed: () {
        print("Rewarded ad failed to show");
        AppUtil.showNormalToast("No ads available. Please try again later.".tr);
      },
    );
  }

  static Future<void> _claimReward(ApiRepository api, int adsWatchedToday, int maxAdsToday) async {
    String userId = '';
    if (Get.isRegistered<ProfileController>()) {
      userId = Get.find<ProfileController>().currentUser.value?.id ?? '';
    }
    if (userId.isEmpty) {
      userId = await AppUtil().getDeviceId();
    }
    final rewardId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

    final res = await api.claimAdsRewardWeifu(rewardId: rewardId);
    if (res == null) {
      AppUtil.showNormalToast('Claim reward failed. Please try again.'.tr);
      return;
    }

    if (res['success'] == true) {
      final rewardGems = (res['reward_gems'] is num)
          ? (res['reward_gems'] as num).toInt()
          : null;
      final userMap = res['user'];
      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        if (userMap is Map) {
          profileCtrl.currentUser.value =
              UserModel.fromJson(Map<String, dynamic>.from(userMap));
        } else {
          await profileCtrl.fetchProfile();
        }
      }
      final adsClaimedToday = (res['ads_claimed_today'] is num)
          ? (res['ads_claimed_today'] as num).toInt()
          : adsWatchedToday; // fallback
      final adsMaxPerDay = (res['ads_max_per_day'] is num)
          ? (res['ads_max_per_day'] as num).toInt()
          : maxAdsToday; // fallback

      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        final currentData = profileCtrl.checkinStatusData.value ?? <String, dynamic>{};
        currentData['ads_claimed_today'] = adsClaimedToday;
        currentData['ads_max_per_day'] = adsMaxPerDay;
        profileCtrl.checkinStatusData.value = Map<String, dynamic>.from(currentData);
      }

      int remaining = adsMaxPerDay - adsClaimedToday;
      String rewardMsg = rewardGems != null
          ? '+$rewardGems ${"gems received!".tr}'
          : (res['message']?.toString() ?? 'Reward claimed successfully'.tr);
      
      AppUtil.showNormalToast("$rewardMsg\n${"Ads remaining today:".tr} $remaining");
      return;
    }

    AppUtil.showNormalToast(
        res['message']?.toString() ?? 'Could not claim reward.'.tr);
  }
}
