import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../services/easy_adjust_service.dart';
import '../services/easy_shared_pref_service.dart';

/// Easy Event controller manages events received from all type of ad units
class EasyEventController {
  Stream<AdEvent> get onEvent => _onEventController.stream;
  final _onEventController = StreamController<AdEvent>.broadcast();

  void fireNetworkInitializedEvent(AdNetwork adNetwork, bool status) {
    _onEventController.add(AdEvent(
      type: AdEventType.adNetworkInitialized,
      adNetwork: adNetwork,
      data: status,
    ));
  }

  void setupEvents(EasyAdBase ad) {
    ad.onAdLoaded = (adNetwork, adUnitType, data) {
      _onEventController.add(AdEvent(
        type: AdEventType.adLoaded,
        adNetwork: adNetwork,
        adUnitType: adUnitType,
        data: data,
        customAdUnitId: ad.adUnitId,
      ));
    };
    ad.onAdFailedToLoad = (adNetwork, adUnitType, data, errorMessage) {
      _onEventController.add(AdEvent(
        type: AdEventType.adFailedToLoad,
        adNetwork: adNetwork,
        adUnitType: adUnitType,
        data: data,
        error: errorMessage,
        customAdUnitId: ad.adUnitId,
      ));
    };
    ad.onAdShowed = (adNetwork, adUnitType, data) {
      _onEventController.add(AdEvent(
        type: AdEventType.adShowed,
        adNetwork: adNetwork,
        adUnitType: adUnitType,
        data: data,
        customAdUnitId: ad.adUnitId,
      ));
    };
    ad.onAdFailedToShow = (adNetwork, adUnitType, data, errorMessage) {
      _onEventController.add(AdEvent(
        type: AdEventType.adFailedToShow,
        adNetwork: adNetwork,
        adUnitType: adUnitType,
        data: data,
        error: errorMessage,
        customAdUnitId: ad.adUnitId,
      ));
    };
    ad.onAdDismissed = (adNetwork, adUnitType, data) {
      _onEventController.add(AdEvent(
        type: AdEventType.adDismissed,
        adNetwork: adNetwork,
        adUnitType: adUnitType,
        data: data,
        customAdUnitId: ad.adUnitId,
      ));
    };
    ad.onEarnedReward = _onEarnedRewardMethod;
    ad.onPaidEvent = _onPaidEventMethod;
    ad.onLogAdImpression = _onAdImpressionEventMethod;
  }


  void _onEarnedRewardMethod(AdNetwork adNetwork, AdUnitType adUnitType,
      String? rewardType, num? rewardAmount) {
    _onEventController.add(AdEvent(
      type: AdEventType.earnedReward,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      data: {'rewardType': rewardType, 'rewardAmount': rewardAmount},
    ));
  }

  void _onPaidEventMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  ) {
    EasyAdjustService().logAdRevenue(
      adNetwork,
      ad,
      valueMicros,
      currencyCode,
    );



    if (valueMicros > 0) {
      EasySharedPrefService().setFullAdsValue();
    }

    _onEventController.add(AdEvent(
      type: AdEventType.onPaidEvent,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      ad: ad,
      valueMicros: valueMicros,
      precision: precision,
      currencyCode: currencyCode,
      data: {'valueMicros': valueMicros, 'currencyCode': currencyCode},
    ));
  }

  void _onAdImpressionEventMethod(
    AdNetwork adNetwork,
    AdUnitType adUnitType,
    Ad ad,
    String currencyCode,
    double valueMicros,
  ) {


    _onEventController.add(AdEvent(
      type: AdEventType.onAdImpression,
      adNetwork: adNetwork,
      adUnitType: adUnitType,
      ad: ad,
    ));
  }
}
