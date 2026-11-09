import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../core/values/constants.dart';

class FirebaseRemoteConfigService {
  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  static final String android_app_version = "android_app_version";
  static final String resume_ad = "resume_ad";
  static final String banner_splash = "banner_splash";
  static final String inter_splash_high = "inter_splash_high";
  static final String inter_splash = "inter_splash";
  static final String native_full_splash = "native_full_splash";
  static final String native_full_splash_2f = "native_full_splash_2f";
  static final String native_full_high_inter_splash = "native_full_high_inter_splash";
  static final String native_full_inter_splash = "native_full_inter_splash";
  static final String native_language_high = "native_language_high";
  static final String native_language = "native_language";
  static final String native_language_high_alt = "native_language_high_alt";
  static final String native_language_alt = "native_language_alt";
  static final String native_onboarding_1 = "native_onboarding_1";
  static final String native_onboarding_full_2 = "native_onboarding_full_2";
  static final String native_onboarding_full_1 = "native_onboarding_full_1";
  static final String native_onboarding_3 = "native_onboarding_3";
  static final String native_question = "native_question";
  static final String native_full_click = "native_full_click";
  static final String native_permission = "native_permission";
  static final String native_banner = "native_banner";
  static final String inter_all = "inter_all";
  static final String inter_back = "inter_back";
  static final String inter_ob = "inter_ob";
  static final String inter_home = "inter_home";
  static final String native_card = "native_card";
  static final String native_search = "native_search";
  static final String remove_characters = "remove_characters";
  static final String interval_inter_ad = "interval_inter_ad";
  static final String time_reload_ads_native_game =
      "time_reload_ads_native_game";
  static final String time_reload_ads_native_home =
      "time_reload_ads_native_home";
  static final String timeDelayCloseNativeFull = "timeDelayCloseNativeFull";
  static final String native_home = "native_home";
  static final String native_all = "native_all";
  static final String banner_all = "banner_all";
  static final String banner_rectangle = "banner_rectangle";
  static final String collap_banner_scan = "collap_banner_scan";
  static final String reward_ad = "reward_ad";
  static final String native_identify = "native_identify";
  static final String percent_discount_yearly = "percent_discount_yearly";
  static final String open_premium_first = "open_premium_first";
  static final String open_flashsale = "open_flashsale";
  static final String time_flash_sale = "time_flash_sale";
  static final String show_rating_case_1 = "show_rating_case_1";
  static final String show_rating_case_2 = "show_rating_case_2";
  static final String time_to_show_rating = "time_to_show_rating";
  static final String time_delay_close_premium = "time_delay_close_premium";
  static final String collap = "collap";
  static final String banner_home = "banner_home";
  static final String banner_home_reload_interval =
      "banner_home_reload_interval";
  static final String native_inline_interval = "native_inline_interval";

  static final String percentSaveVIP = "percentSaveVIP";
  static final String percentSaveYearlySale = "percentSaveYearlySale";
  static final String premium_yearly_2_view = "premium_yearly_2_view";

  static final String show_activity_iap = "show_activity_iap";
  static final String enable_reviewer_add_gems = "enable_reviewer_add_gems";

  static final Map<String, dynamic> _defaultValues = {
    android_app_version: "1.0.0",
    resume_ad: true,
    banner_splash: true,
    inter_splash_high: true,
    inter_splash: true,
    native_full_splash: true,
    native_full_splash_2f: true,
    native_full_high_inter_splash: true,
    native_full_inter_splash: true,
    native_language_high: true,
    native_language: true,
    native_language_high_alt: true,
    native_language_alt: true,
    native_onboarding_1: true,
    native_onboarding_full_2: true,
    native_onboarding_full_1: true,
    native_onboarding_3: true,
    native_question: true,
    native_full_click: true,
    native_permission: true,
    native_banner: true,
    inter_all: true,
    inter_back: true,
    inter_ob: true,
    inter_home: true,
    native_card: true,
    native_search: true,
    remove_characters: false,
    interval_inter_ad: 30,
    time_reload_ads_native_game: 15,
    time_reload_ads_native_home: 15,
    timeDelayCloseNativeFull: 0,
    native_home: true,
    native_all: true,
    banner_all: true,
    banner_rectangle: true,
    collap_banner_scan: true,
    reward_ad: true,
    native_identify: true,
    percent_discount_yearly: 50,
    open_premium_first: true,
    open_flashsale: true,
    time_flash_sale: 3600,
    show_rating_case_1: true,
    show_rating_case_2: true,
    time_to_show_rating: 3,
    time_delay_close_premium: 0,
    collap: true,
    banner_home: true,
    banner_home_reload_interval: 15,
    native_inline_interval: 15,
    percentSaveVIP: 70,
    percentSaveYearlySale: 50,
    premium_yearly_2_view: true,
    show_activity_iap: true,
    enable_reviewer_add_gems: false,
  };

  static Future<void> initFirebaseRemoteConfig() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 3),
          minimumFetchInterval: const Duration(seconds: 60),
        ),
      );
      await remoteConfig.setDefaults(_defaultValues);
      // Fetch and activate latest server values in background without blocking cold start / runApp()
      unawaited(
        remoteConfig.fetchAndActivate().timeout(
              const Duration(seconds: 3),
              onTimeout: () => false,
            ),
      );
    } catch (e) {}
  }

  static String getStringConfigByKey(String key) {
    return remoteConfig.getString(key);
  }

  static bool getBoolConfigByKey(String key) {
    return remoteConfig.getBool(key);
  }

  static bool get isNativeFullSplashHighEnabled =>
      getBoolConfigByKey(native_full_high_inter_splash) ||
      getBoolConfigByKey(native_full_splash_2f);

  static bool get isNativeFullSplashEnabled =>
      getBoolConfigByKey(native_full_inter_splash) ||
      getBoolConfigByKey(native_full_splash);

  static int getIntConfigByKey(String key) {
    return remoteConfig.getInt(key);
  }

  String getAppVersionConfig() {
    if (Platform.isIOS) {
      return remoteConfig.getString(Constants.KeyAppConfigIOS);
    } else {
      return remoteConfig.getString(Constants.KeyAppConfigAndroid);
    }
  }

  String getAdsConfig() {
    if (Platform.isIOS) {
      return remoteConfig.getString(Constants.KeyAppAdsIOS);
    } else {
      return remoteConfig.getString(Constants.KeyAppAdsAndroid);
    }
  }

/* const FirebaseRemoteConfigService({
    required this.firebaseRemoteConfig,
  });

  final FirebaseRemoteConfig firebaseRemoteConfig;

  Future<void> init() async {
    try {
      await firebaseRemoteConfig.ensureInitialized();
      await firebaseRemoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await firebaseRemoteConfig.fetchAndActivate();
    } on FirebaseException catch (e, st) {
      developer.log(
        'Unable to initialize Firebase Remote Config',
        error: e,
        stackTrace: st,
      );
    }
  }

  getAppConfigByPlatform() {
    if (Platform.isIOS) {
      firebaseRemoteConfig.getString(Constants.KeyAppConfigIOS);
    } else {
      firebaseRemoteConfig.getString(Constants.KeyAppConfigAndroid);
    }
  }*/
}
