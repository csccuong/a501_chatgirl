import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../ads/const/ad_id.dart';
import '../ads/const/ad_id_name.dart';
import '../ads/const/ad_id_extension.dart';
import '../core/utils/app_util.dart';
import '../flavors/build_config.dart';
import '../flavors/environment.dart';
import '../routes/app_pages.dart';
import '../screens/language/language_controller.dart';
import '../screens/onboard/onboard_controller.dart';

class FirebaseHelper {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Locale? userLocale = Get.deviceLocale;

  static const EVENT_USER_LOCALE = 'user_locale';

  //Other service
  static const EVENT_CLICK_SERVICE_PLANT = 'click_service_plant';
  static const EVENT_RESULT_SUCCESS_PLANT = 'result_plant';

  static const premium_view = "premium_view";
  static const paywall_view = "paywall_view";
  static const payment_successful = "payment_successful";
  static const payment_failed = "payment_failed";
  static const payment_cancel = "payment_cancel";
  static const payment_restore = "payment_restore";
  static const sale_popup_view = "sale_popup_view";
  static const sale_banner_view = "sale_banner_view";

  static const inters_ad_view = "inters_ad_view";
  static const inter_splash_view = "inter_splash_view";
  static const banner_splash_view = "banner_splash_view";
  static const native_language_view = "native_language_view";

  static const select_language = "select_language";
  static const native_language_alt_view = "native_language_alt_view";
  static const native_onboarding_1_view = "native_onboarding_1_view";
  static const native_onboarding_full1_view = "native_onboarding_full_view";
  static const native_onboarding_full2_view = "native_onboarding_full_view";
  static const native_onboarding_3_view = "native_onboarding_3_view";
  static const question_view = "question_view";
  static const native_survey_view = "native_question_view";
  static const native_survey_alt_view = "native_question_alt_view";
  static const main_view = "main_view";
  static const preview_sound_view = "preview_sound_view";
  static const preview_name_quiz_view = "preview_name_quiz_view";
  static const preview_image_quiz_view = "preview_image_quiz_view";
  static const game_over_view = "game_over_view";
  static const playing_sound_quiz_view = "playing_sound_quiz_view";
  static const playing_name_quiz_view = "playing_name_quiz_view";
  static const playing_image_quiz_view = "playing_image_quiz_view";
  static const wiki_view = "wiki_view";
  static const wiki_detail_view = "wiki_detail_view";
  static const ranking_view = "ranking_view";
  static const soundboard_view = "soundboard_view";
  static const play_sound_view = "play_sound_view";
  static const language_next_view = "language_next_view";
  static const onboard1_view = "onboard1_view";
  static const onboard2_view = "onboard2_view";
  static const onboard3_view = "onboard3_view";
  static const question_next_view = "question_next_view";

  static const show_dialog_no_internet = "show_dialog_no_internet";
  static const show_dialog_no_internet_in_FO = "show_dialog_no_internet_in_FO";

  static const banner_splash_start_load = "banner_splash_start_load";
  static const inter_open_start_load = "inter_open_start_load";
  static const inter_high_open_start_load = "inter_high_open_start_load";
  static const inter_open_load_10s = "inter_open_load_10s";
  static const inter_open_load_10s_20s = "inter_open_load_10s_20s";
  static const inter_open_load_20s_30s = "inter_open_load_20s_30s";
  static const inter_open_load_30s_40s = "inter_open_load_30s_40s";
  static const inter_open_load_40s_50s = "inter_open_load_40s_50s";
  static const inter_open_load_more_50s = "inter_open_load_more_50s";
  static const inter_fail_to_show = "inter_fail_to_show";
  static const inter_open_call_show = "inter_open_call_show";
  static const inter_open_call_show_priority = "inter_open_call_show_priority";
  static const inter_open_high_call_show = "inter_open_high_call_show";
  static const load_inter_splash_success = "load_inter_splash_success";
  static const load_inter_splash_high_success =
      "load_inter_splash_high_success";
  static const load_inter_splash_fail = "load_inter_splash_fail";
  static const load_inter_splash_high_fail = "load_inter_splash_high_fail";
  static const load_native_language_success = "load_native_language_success";
  static const load_native_language_high_success =
      "load_native_language_high_success";
  static const load_native_language_alt_success =
      "load_native_language_alt_success";
  static const load_native_language_high_alt_success =
      "load_native_language_high_alt_success";
  static const load_native_onboard1_success = "load_native_onboard1_success";
  static const load_native_onboard2_success = "load_native_onboard2_success";
  static const load_native_onboardfull_success =
      "load_native_onboardfull_success";
  static const load_native_question_success = "load_native_question_success";
  static const load_native_question_alt_success =
      "load_native_question_alt_success";

  static const reload_native_language_success =
      "reload_native_language_success";
  static const reload_native_language_alt_success =
      "reload_native_language_alt_success";
  static const reload_native_language_high_success =
      "reload_native_language_high_success";
  static const reload_native_language_alt_high_success =
      "reload_native_language_alt_high_success";
  static const reload_native_onboard1_success =
      "reload_native_onboard1_success";
  static const reload_native_onboard2_success =
      "reload_native_onboard2_success";
  static const reload_native_onboardfull1_success =
      "reload_native_onboardfull1_success";
  static const reload_native_onboardfull2_success =
      "reload_native_onboardfull2_success";
  static const reload_native_question_success =
      "reload_native_question_success";
  static const reload_native_question_alt_success =
      "reload_native_question_alt_success";

  static const reload_native_language_valid = "reload_native_language_valid";
  static const reload_native_language_new = "reload_native_language_new";
  static const reload_native_language_alt_valid =
      "reload_native_language_alt_valid";
  static const reload_native_language_alt_new =
      "reload_native_language_alt_new";

  //Event purchase
  static const EVENT_CLICK_PURCHASE_WEEKLY = 'click_purchase_weekly';
  static const EVENT_CLICK_PURCHASE_MONTHLY = 'click_purchase_monthly';
  static const EVENT_CLICK_PURCHASE_YEARLY = 'click_purchase_yearly';
  static const EVENT_CLICK_PURCHASE_YEARLY_SALE = 'click_purchase_yearly_sale';
  static const EVENT_CLICK_PURCHASE_LIFETIME = 'click_purchase_yearly';
  static const EVENT_CLICK_PURCHASE_3MONTHS = 'click_purchase_3months';
  static const EVENT_CLICK_PURCHASE_REMOVE_ADS = 'click_purchase_remove_ads';
  static const EVENT_PURCHASE_SUCCESS_WEEKLY = 'purchase_success_weekly';
  static const EVENT_PURCHASE_SUCCESS_MONTHLY = 'purchase_success_monthly';
  static const EVENT_PURCHASE_SUCCESS_YEARLY = 'purchase_success_yearly';
  static const EVENT_PURCHASE_SUCCESS_YEARLY_SALE = 'purchase_success_yearly';
  static const EVENT_PURCHASE_SUCCESS_LIFETIME = 'purchase_success_yearly';
  static const EVENT_PURCHASE_SUCCESS_3MONTHS = 'purchase_success_3months';
  static const EVENT_PURCHASE_SUCCESS_REMOVE_ADS =
      'purchase_success_remove_ads';
  static const EVENT_PURCHASE_ERROR = 'purchase_error';

  static setUserId(String _userId) {
    analytics.setUserId();
  }

  static setTrackingScreenName(String _screenName) async {
    try {
      FirebaseAnalytics.instance.logScreenView(
        screenName: _screenName,
        screenClass: _screenName,
      );

      AppUtil.showLog('setTrackingScreenName: $_screenName');
    } catch (e) {
      print("error setTrackingScreenName " + e.toString());
    }
  }

  static const native_onboarding_full_1_view = "native_onboarding_full_1_view";
  static const native_onboarding_full_2_view = "native_onboarding_full_2_view";
  static const native_question_view = "native_question_view";

  static String? getAdPlacementEventName(Ad? ad, {AdUnitType? adUnitType}) {
    if (ad == null) return null;
    final adUnitId = ad.adUnitId;
    final isProd = BuildConfig.instance.environment == Environment.PRODUCTION;
    final platform = Platform.isAndroid ? 'android' : 'ios';

    final envKey = isProd ? 'prod' : 'dev';
    final platformMap = myAdsId[envKey]?[platform] ?? {};

    String? matchKey;
    platformMap.forEach((key, val) {
      if (val == adUnitId) matchKey = key;
    });

    if (matchKey != null && isProd) {
      switch (matchKey) {
        case MyAdIdName.appOpenResume:
          return "resume_open_app";
        case MyAdIdName.interSplashHigh:
          return "inter_splash_view";
        case MyAdIdName.interSplash:
          return "inter_splash_view";
        case MyAdIdName.nativeLanguage:
          return "native_language_view";
        case MyAdIdName.nativeLanguageHigh:
          return "native_language_view";
        case MyAdIdName.nativeLanguageClick:
          return "native_language_alt_view";
        case MyAdIdName.nativeLanguageClickHigh:
          return "native_language_alt_view";
        case MyAdIdName.nativeOnboard1Ad:
          return "native_onboarding_1_view";
        case MyAdIdName.nativeOnboardFull1Ad:
          return "native_onboarding_full_1_view";
        case MyAdIdName.nativeOnboardFull2Ad:
          return "native_onboarding_full_2_view";
        case MyAdIdName.nativeOnboard3Ad:
          return "native_onboarding_3_view";
      }
    }

    // Dev / Test mode fallback using screen & state heuristics
    final route = Get.currentRoute;
    if (route == AppRoutes.SPLASH) {
      if (adUnitType == AdUnitType.interstitial ||
          adUnitId == MyAdIdName.interSplash.getId ||
          adUnitId == MyAdIdName.interSplashHigh.getId) {
        return "inter_splash_view";
      }
    } else if (route == AppRoutes.LANGUAGE) {
      if (Get.isRegistered<LanguageController>()) {
        final langController = Get.find<LanguageController>();
        if (langController.isShowAltAds.value) {
          return "native_language_alt_view";
        } else {
          return "native_language_view";
        }
      }
      return "native_language_view";
    } else if (route.contains('Onboard')) {
      if (adUnitId == MyAdIdName.nativeOnboardFull1Ad.getId) {
        return "native_onboarding_full_1_view";
      } else if (adUnitId == MyAdIdName.nativeOnboardFull2Ad.getId) {
        return "native_onboarding_full_2_view";
      } else if (adUnitId == MyAdIdName.nativeOnboard1Ad.getId) {
        return "native_onboarding_1_view";
      } else if (adUnitId == MyAdIdName.nativeOnboard3Ad.getId) {
        return "native_onboarding_3_view";
      }
    } else if (route.contains('Permission')) {
      return "native_question_view";
    }
    return null;
  }


  static logAdmobAdImpression({required Ad ad, AdUnitType? adUnitType}) async {
    try {
      // 1. Log custom ad placement event matching the checklist
      final placementEvent = getAdPlacementEventName(ad, adUnitType: adUnitType);
      if (placementEvent != null) {
        await analytics.logEvent(name: placementEvent);
        AppUtil.showLog('Firebase logged ad placement event: $placementEvent');
      }

      // 2. Log standard Firebase ad_impression
      await analytics.logAdImpression(
        adFormat: ad is BannerAd ? 'Banner' : (ad is AppOpenAd ? 'OpenAd' : (ad is NativeAd ? 'Native' : 'Interstitial')),
        adPlatform: 'Admob',
        adSource: ad.responseInfo?.loadedAdapterResponseInfo?.adSourceName,
        adUnitName: ad.adUnitId,
        currency: 'USD',
      );
    } catch (e) {
      print("error logAdmobAdImpression: $e");
    }
  }


  static logEventName(String eventName, {required String param}) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: {"param": param},
      );
    } catch (e) {
      print("error logEventName " + e.toString());
    }
  }

  static logEventUserLocale({
    required String languageCode,
    required String countryCode,
    required String scriptCode,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_USER_LOCALE,
      parameters: {
        "language_code": languageCode,
        "country_code": countryCode,
        "script_code": scriptCode,
      },
    );
  }


  static logEventClickPurchaseRemoveAds({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_REMOVE_ADS,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseMonthly({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_MONTHLY,
      parameters: {
        "product_id": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseYearly({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseYearlySale({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventClickPurchaseLifetime({required String productId}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_CLICK_PURCHASE_YEARLY,
      parameters: {
        "productID": productId,
        "store": Platform.isIOS ? "Apple" : "Google",
      },
    );
  }

  static logEventPurchaseSuccessWeekly(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String? countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode;
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_WEEKLY,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_${countryCode}',
      },
    );
  }

  static logEventPurchaseSuccessMonthly(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String? countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode;
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_MONTHLY,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_${countryCode}',
      },
    );
  }

  static logEventPurchaseSuccessYearly(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String? countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode;
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_YEARLY,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_${countryCode}',
      },
    );
  }

  static logEventPurchaseSuccessYearlySale(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String? countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode;
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_YEARLY_SALE,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_${countryCode}',
      },
    );
  }

  static logEventPurchaseSuccessLifetime(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String? countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode;
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_LIFETIME,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_${countryCode}',
      },
    );
  }

  static logEventPurchaseSuccess3Months(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String? countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode;
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_3MONTHS,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_${countryCode}',
      },
    );
  }

  static logEventPurchaseSuccessRemoveAds(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    String languageCode = '';
    String? countryCode = '';
    try {
      if (userLocale != null) {
        languageCode = userLocale!.languageCode;
        countryCode = userLocale!.countryCode;
      }
    } catch (_) {}
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_SUCCESS_REMOVE_ADS,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "demand": '',
        "decimalvalue": productDetail.rawPrice.toString(),
        "currencyCode": productDetail.currencyCode,
        "store": isGoogle ? "Google" : "Apple",
        "locale": '${languageCode}_${countryCode}',
      },
    );
  }

  static logEventPurchaseError(
      {required PurchaseDetails purchase, required bool isGoogle}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: EVENT_PURCHASE_ERROR,
      parameters: {
        "purchase_id": purchase.purchaseID.toString(),
        "product_id": purchase.productID,
        "status": purchase.status.name,
        "store": isGoogle ? "Google" : "Apple",
      },
    );
  }

  static logInAppPurchaseCustom(
      {required PurchaseDetails purchase,
      required ProductDetails productDetail,
      required bool isGoogle}) async {
    await analytics.logEvent(
      name: 'in_app_purchase_custom',
      //source: "Là định danh chính xác cho các gói nạp, định danh này là duy nhất, ko trùng lặp và thể hiện sát ý nghĩa của gói bán đó
      // demand: Là các động lực dẫn đến việc mua inapp:
      // + default : ban đầu tạo tài khoản và khi các động lực khác được giải quyết xong
      // + (định nghĩa các động lực mua inapp khác ví dụ: sale_popup)
      //
      // Lưu ý: Khi các nhu cầu được giải quyết ( là khi khác default và mua 1 gói inapp bất kỳ) thì set lại thuộc tính này về giá trị là default
      //decimalvalue: Giá trị gói nạp đó theo USD, dạng số ( ví dụ: 0.99, 1.99 , ....)
      parameters: {
        "source": purchase.purchaseID.toString(),
        "demand": 'default',
        "decimalvalue": productDetail.rawPrice.toString(),
        "store": isGoogle ? "Google" : "Apple",
      },
    );
  }
}
