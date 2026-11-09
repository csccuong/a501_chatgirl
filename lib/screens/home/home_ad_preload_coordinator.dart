import 'dart:async';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../utils/app_setting.dart';
import 'home_ad_runtime_flags.dart';
import 'home_inline_ad_models.dart';
import 'home_inline_ad_preload_store.dart';

class HomeAdPreloadCoordinator {
  static bool _isInlinePrewarmScheduled = false;

  static void preloadBeforeHome({
    required String source,
  }) {
    if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
      return;
    }

    if (!HomeAdRuntimeFlags.enableInlineAds) {
      _preloadHomeSearch(source);
      return;
    }

    if (!FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_card)) {
      _preloadHomeSearch(source);
      return;
    }

    _preloadInlineSlots(source);
  }

  static void _preloadHomeSearch(String source) {
    if (!HomeAdRuntimeFlags.enableSearchAd) return;
    if (!AppSetting.isInitRemoteConfig.value) {
      late Worker worker;
      worker = ever<bool>(AppSetting.isInitRemoteConfig, (isInit) {
        if (isInit) {
          _preloadHomeSearch(source);
          worker.dispose();
        }
      });
      return;
    }
    if (!FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_search)) {
      return;
    }

    FirebaseHelper.logEventName(
      'home_search_preload_started',
      param: source,
    );
    EasyAds.instance.preloadNativeAd(
      adId: MyAdIdName.nativeHome.getId,
      factoryId: 'nativeMediaSmall',
      height: 90,
      cacheKey: MyAdIdName.nativeHome,
    );
  }

  static void _preloadInlineSlots(String source) {
    if (!HomeAdRuntimeFlags.enableInlineAds) return;
    if (!AppSetting.isInitRemoteConfig.value) {
      late Worker worker;
      worker = ever<bool>(AppSetting.isInitRemoteConfig, (isInit) {
        if (isInit) {
          _preloadInlineSlots(source);
          worker.dispose();
        }
      });
      return;
    }
    if (!FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_card)) {
      return;
    }
    if (_isInlinePrewarmScheduled) return;

    _isInlinePrewarmScheduled = true;
    Future<void>(() async {
      try {
        await HomeInlineAdPreloadStore.warmSlot(
          0,
          config:  HomeInlineAdConfig.homeInline(),
          source: '$source:slot0',
        );

        await Future<void>.delayed(const Duration(milliseconds: 250));
        _preloadHomeSearch('$source:search');
      } finally {
        _isInlinePrewarmScheduled = false;
      }
    });
  }
}
