import 'dart:async';

import 'package:cscmobi_app/core/utils/app_util.dart';
import 'package:easy_ads_flutter/helper/adjust_helper.dart';
import 'package:cscmobi_app/helper/firebase_helper.dart';
import 'package:cscmobi_app/utils/app_setting.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'home_inline_ad_models.dart';

class HomeInlineAdPreloadStore {
  static final Map<int, NativeAd> _readyAds = <int, NativeAd>{};
  static final Map<int, Completer<NativeAd?>> _loadingBySlot =
      <int, Completer<NativeAd?>>{};
  static final Map<int, int> _requestTokenBySlot = <int, int>{};
  static final Set<int> _failedSlots = <int>{};

  static bool hasReadySlot(int slotIndex) => _readyAds.containsKey(slotIndex);

  static bool isLoadingSlot(int slotIndex) =>
      _loadingBySlot.containsKey(slotIndex);

  static bool hasFailedSlot(int slotIndex) => _failedSlots.contains(slotIndex);

  static void markSlotFailed(int slotIndex) {
    _failedSlots.add(slotIndex);
    clearSlot(slotIndex);
  }

  static void recycleSlotAd(int slotIndex, NativeAd ad) {
    _readyAds.remove(slotIndex)?.dispose();
    _readyAds[slotIndex] = ad;
    FirebaseHelper.logEventName(
      'home_inline_recycled',
      param: 'slot_$slotIndex',
    );
  }

  static Future<void> warmSlots(
    Iterable<int> slotIndexes, {
    required HomeInlineAdConfig Function(int slotIndex) configBuilder,
    required String source,
  }) async {
    for (final slotIndex in slotIndexes.toSet()) {
      await warmSlot(
        slotIndex,
        config: configBuilder(slotIndex),
        source: source,
      );
    }
  }

  static Future<NativeAd?> warmSlot(
    int slotIndex, {
    required HomeInlineAdConfig config,
    required String source,
  }) async {
    return _ensureLoaded(
      slotIndex,
      config: config,
      source: source,
      claimOnReady: false,
    );
  }

  static Future<NativeAd?> claimOrLoadSlot(
    int slotIndex, {
    required HomeInlineAdConfig config,
    required String source,
  }) async {
    return _ensureLoaded(
      slotIndex,
      config: config,
      source: source,
      claimOnReady: true,
    );
  }

  static Future<NativeAd?> _ensureLoaded(
    int slotIndex, {
    required HomeInlineAdConfig config,
    required String source,
    required bool claimOnReady,
  }) async {
    if (_failedSlots.contains(slotIndex)) {
      return null;
    }

    final readyAd = _takeReadyAd(slotIndex, claim: claimOnReady);
    if (readyAd != null) {
      return readyAd;
    }

    if (_loadingBySlot.containsKey(slotIndex)) {
      final awaitedAd = await _loadingBySlot[slotIndex]!.future;
      if (!claimOnReady) {
        return awaitedAd;
      }
      return _takeReadyAd(slotIndex, claim: true);
    }

    final requestToken = (_requestTokenBySlot[slotIndex] ?? 0) + 1;
    _requestTokenBySlot[slotIndex] = requestToken;

    final completer = Completer<NativeAd?>();
    _loadingBySlot[slotIndex] = completer;
    FirebaseHelper.logEventName(
      'home_inline_preload_started',
      param: '$source:$slotIndex',
    );

    try {
      NativeAd(
        adUnitId: config.resolvedAdUnitId,
        request: const AdRequest(),
        factoryId: config.factoryId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (_requestTokenBySlot[slotIndex] != requestToken) {
              ad.dispose();
              return;
            }

            final loadedAd = ad as NativeAd;
            _readyAds.remove(slotIndex)?.dispose();
            _readyAds[slotIndex] = loadedAd;
            _loadingBySlot.remove(slotIndex);
            if (!completer.isCompleted) {
              completer.complete(loadedAd);
            }
            FirebaseHelper.logEventName(
              'home_inline_preload_loaded',
              param: '$source:$slotIndex',
            );
            AppUtil.showLogFull('### CSC ### Loading Ads Inline: onAdLoaded -> slotIndex: $slotIndex');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (_requestTokenBySlot[slotIndex] != requestToken) {
               return;
            }

            _failedSlots.add(slotIndex);
            _loadingBySlot.remove(slotIndex);
            if (!completer.isCompleted) {
              completer.complete(null);
            }
            FirebaseHelper.logEventName(
              'home_inline_failed',
              param: '$source:$slotIndex:${error.code}',
            );
            AppUtil.showLogFull('### CSC ### Loading Ads Inline: onAdFailedToLoad -> slotIndex: $slotIndex, Code=${error.code}, Domain=${error.domain}, Message=${error.message}');
          },
          onAdImpression: (ad) {
             FirebaseHelper.logAdmobAdImpression(ad: ad);
            FirebaseHelper.logEventName(
              'home_inline_impression',
              param: 'slot_$slotIndex',
            );
            AppUtil.showLogFull('### CSC ### Loading Ads Inline: onAdImpression -> slotIndex: $slotIndex');
          },
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {
            AppSetting.adImpressionCount++;
            AdjustHelper.adjustTrackAdRevenue(
              ad: ad,
              valueMicros: valueMicros,
              precision: precision,
              currencyCode: currencyCode,
              adOnScreen: Get.currentRoute.replaceAll('/', ''),
              adUnit: 'NativeAd',
              adImpressionsCount: AppSetting.adImpressionCount,
            );
            AppUtil.showLogFull('### CSC ### Loading Ads Inline: onPaidEvent -> slotIndex: $slotIndex');
          },
        ),
      ).load();
    } catch (_) {
      _failedSlots.add(slotIndex);
      _loadingBySlot.remove(slotIndex);
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      FirebaseHelper.logEventName(
        'home_inline_failed',
        param: '$source:$slotIndex:exception',
      );
      AppUtil.showLogFull('### CSC ### catch FAIL -> slotIndex: $slotIndex, => Source:  $source, => Stack:$_');

    }

    final loadedAd = await completer.future;
    if (!claimOnReady) {
      return loadedAd;
    }
    return _takeReadyAd(slotIndex, claim: true);
  }

  static NativeAd? _takeReadyAd(int slotIndex, {required bool claim}) {
    if (!claim) {
      return _readyAds[slotIndex];
    }

    final claimedAd = _readyAds.remove(slotIndex);
    if (claimedAd != null) {
      FirebaseHelper.logEventName(
        'home_inline_claimed_preloaded',
        param: 'slot_$slotIndex',
      );
    }
    return claimedAd;
  }

  static void disposeUnusedSlots(Iterable<int> validSlotIndexes) {
    final validSet = validSlotIndexes.toSet();
    final staleReadySlots = _readyAds.keys
        .where((slotIndex) => !validSet.contains(slotIndex))
        .toList();

    for (final slotIndex in staleReadySlots) {
      clearSlot(slotIndex);
    }
  }

  static void clearSlot(int slotIndex) {
    _requestTokenBySlot[slotIndex] = (_requestTokenBySlot[slotIndex] ?? 0) + 1;
    _readyAds.remove(slotIndex)?.dispose();
    final completer = _loadingBySlot.remove(slotIndex);
    if (completer != null && !completer.isCompleted) {
      completer.complete(null);
    }
  }

  static void clearAll() {
    final allSlots = <int>{
      ..._readyAds.keys,
      ..._loadingBySlot.keys,
      ..._requestTokenBySlot.keys,
      ..._failedSlots,
    };
    for (final slotIndex in allSlots) {
      clearSlot(slotIndex);
    }
    _failedSlots.clear();
  }
}
