import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:get/get.dart';
import '../core/utils/app_util.dart';
import '../core/values/constants.dart';
import 'package:flutter/material.dart';
import '../helper/firebase_remote_config_service.dart';
import '../screens/popup_out_of_free/popup_out_of_free_controller.dart';
import '../screens/popup_out_of_free/popup_out_of_free_page.dart';
import '../ads/const/ad_id_name.dart';
import '../ads/const/ad_id_extension.dart';

class AppSetting {
  static RxBool isPremiumUser = false.obs;
  static RxBool isRemoveAds = false.obs;
  static RxBool isShowingFullAd = false.obs;
  static int adImpressionCount = 1;
  static bool isDialogPremiumShowing = false;
  static var isInReviewing = false;
  static String selectedLanguageCode = AppUtil().getUserChoosedLanguage();
  static RxBool isInitRemoteConfig = false.obs;
  static bool shouldShowSound = true;
  static int interval_inter_ad = 20;
  static bool appInBackground = false;
  static DateTime? lastTimeShowAd;

  static initAppSetting() {
    shouldShowSound = AppUtil.getBool("shouldShowSound");
    // Đồng bộ trạng thái premium/remove ads từ local mỗi lần mở app.
    isPremiumUser.value = AppUtil().getPurchaseStatus();
    isRemoveAds.value = AppUtil().getRemoveAdsStatus();

    ever(isPremiumUser, (bool isPremium) {
      if (isPremium) {
        EasyAds.instance.appLifecycleReactor?.setAllowAppOpenAd(false);
        EasyAds.instance.destroyAllAds();
      }
    });
    ever(isRemoveAds, (bool removeAds) {
      if (removeAds) {
        EasyAds.instance.appLifecycleReactor?.setAllowAppOpenAd(false);
        EasyAds.instance.destroyAllAds();
      }
    });
  }

  static bool canShowInterstitialAd() {
    if (lastTimeShowAd == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastTimeShowAd!).inSeconds;
    debugPrint("AppSetting: time elapsed since last ad: ${difference}s, interval required: ${interval_inter_ad}s");
    return difference >= interval_inter_ad;
  }

  static void updateLastTimeShowAd() {
    lastTimeShowAd = DateTime.now();
    debugPrint("AppSetting: updated lastTimeShowAd to $lastTimeShowAd");
  }

  static void showInterstitialAd(
      BuildContext context, {
        required String adId,
        String? remoteConfigKey,
        bool checkInterval = true,
        required VoidCallback adDismissed,
        required VoidCallback onFailed,
        VoidCallback? onShowed,
      }) {
    final bool showSpecific = remoteConfigKey == null ||
        FirebaseRemoteConfigService.getBoolConfigByKey(remoteConfigKey);
    final bool showInter = showSpecific &&
        FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.inter_all) &&
        !AppSetting.isPremiumUser.value &&
        !AppSetting.isRemoveAds.value;

    final bool allowInterval = !checkInterval || canShowInterstitialAd();

    if (showInter && allowInterval && adId.trim().isNotEmpty && adId != "null") {
      EasyAds.instance.showInterstitialAd(
        context,
        adId: adId,
        onShowed: () {
          updateLastTimeShowAd();
          onShowed?.call();
        },
        adDissmissed: () {
          updateLastTimeShowAd();
          Future.delayed(const Duration(milliseconds: 400), adDismissed);
        },
        onFailed: () {
          Future.delayed(const Duration(milliseconds: 400), onFailed);
        },
      );
    } else {
      adDismissed();
    }
  }


  static int getFreeUsageCount(String featureId) =>
      AppUtil.getInt('${Constants.kCountFreeUsage}_$featureId');
  static void setFreeUsageCount(String featureId, int value) =>
      AppUtil.saveInt('${Constants.kCountFreeUsage}_$featureId', value);

  static bool canUseFreeFeature(String featureId) {
    print(
        "AppSetting canUseFreeFeature for featureId: $featureId, isPremiumUser: ${AppSetting.isPremiumUser.value}, freeUsageCount: ${getFreeUsageCount(featureId)}");
    return AppSetting.isPremiumUser.value || getFreeUsageCount(featureId) < 1;
  }

  static void useFreeFeature(String featureId) {
    if (!AppSetting.isPremiumUser.value) {
      setFreeUsageCount(featureId, getFreeUsageCount(featureId) + 1);
    }
  }

  static void addExtraFreeUsage(String featureId) {
    if (!AppSetting.isPremiumUser.value) {
      setFreeUsageCount(featureId, getFreeUsageCount(featureId) - 1);
    }
  }

  static void checkLimitAndProceed(String featureId, VoidCallback onProceed) {
    if (canUseFreeFeature(featureId)) {
      useFreeFeature(featureId);
      showInterstitialAd(
        Get.context!,
        adId: MyAdIdName.interAllAd.getId,
        adDismissed: onProceed,
        onFailed: onProceed,
      );
    } else {
      Get.dialog(
        GetBuilder<PopupOutOfFreeController>(
          init: PopupOutOfFreeController(onWatchAdSuccess: () {
            addExtraFreeUsage(featureId);
            onProceed();
          }),
          builder: (controller) => const PopupOutOfFreePage(),
        ),
        barrierDismissible: true,
        useSafeArea: false,
      );
    }
  }

  saveCountWatchAdFull() {
    return AppUtil.saveInt(
        Constants.kCountWatchAdFull, Constants.countWatchAdFull);
  }

  saveCountWatchAdReward() {
    AppUtil.saveString('${Constants.kCountWatchAdReward}_date',
        DateTime.now().toIso8601String().substring(0, 10));
    return AppUtil.saveInt(
        Constants.kCountWatchAdReward, Constants.countWatchAdReward);
  }

  int? getCountWatchAdFull() {
    int? _count = AppUtil.getInt(Constants.kCountWatchAdFull);
    return _count;
  }

  int? getCountWatchAdReward() {
    String savedDate =
        AppUtil.getString('${Constants.kCountWatchAdReward}_date');
    String today = DateTime.now().toIso8601String().substring(0, 10);

    if (savedDate.isNotEmpty && savedDate != today) {
      // Reset on a new day
      Constants.countWatchAdReward = 0;
      AppUtil.saveInt(Constants.kCountWatchAdReward, 0);
      AppUtil.saveString('${Constants.kCountWatchAdReward}_date', today);
      return 0;
    }

    int? _count = AppUtil.getInt(Constants.kCountWatchAdReward);
    Constants.countWatchAdReward = _count ?? 0;
    return _count;
  }

  String getLastCheckinDate() {
    return AppUtil.getString(Constants.kLastCheckinDate);
  }

  saveLastCheckinDate(String date) {
    AppUtil.saveString(Constants.kLastCheckinDate, date);
  }

  int getCheckinStreak() {
    return AppUtil.getInt(Constants.kCheckinStreak) ?? 0;
  }

  saveCheckinStreak(int streak) {
    AppUtil.saveInt(Constants.kCheckinStreak, streak);
  }

  saveFirstTimeOpenApp() {
    return AppUtil.saveString(
        Constants.kUserOpenAppFirstTime, DateTime.now().toIso8601String());
    // return AppUtil.saveString(Constants.kUserOpenAppFirstTime, DateFormat(Styles.FORMAT_TIMEONLY).format(DateTime.now()));
  }

  DateTime? getFirstTimeOpenApp() {
    DateTime? result;
    String strTMPFirstTime = AppUtil.getString(Constants.kUserOpenAppFirstTime);
    if (strTMPFirstTime.isNotEmpty) {
      result = DateTime.parse(strTMPFirstTime);
    }
    // AppUtil.showLogFull('getFirstTimeOpenApp ${result}');

    return result;
  }

  saveEventRetentionDay1() {
    AppUtil.saveBool(Constants.kUserRetentionDay1, true);
  }

  saveEventRetentionDay3() {
    AppUtil.saveBool(Constants.kUserRetentionDay3, true);
  }

  saveEventRetentionDay7() {
    AppUtil.saveBool(Constants.kUserRetentionDay7, true);
  }

  saveEventRetentionDay14() {
    AppUtil.saveBool(Constants.kUserRetentionDay14, true);
  }

  saveEventRetentionDay20() {
    AppUtil.saveBool(Constants.kUserRetentionDay20, true);
  }

  saveEventRetentionDay30() {
    AppUtil.saveBool(Constants.kUserRetentionDay30, true);
  }

  bool checkSendEventRetentionDay1() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay1);
    return isSuccess;
  }

  bool checkSendEventRetentionDay3() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay3);
    return isSuccess;
  }

  bool checkSendEventRetentionDay7() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay7);
    return isSuccess;
  }

  bool checkSendEventRetentionDay14() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay14);
    return isSuccess;
  }

  bool checkSendEventRetentionDay20() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay20);
    return isSuccess;
  }

  bool checkSendEventRetentionDay30() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay30);
    return isSuccess;
  }

}
