import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../easy_ad_base.dart';
import '../enums/ad_network.dart';
import '../enums/ad_unit_type.dart';

class EasyAdmobRewardedAd extends EasyAdBase {
  final AdRequest _adRequest;
  final bool _immersiveModeEnabled;

  EasyAdmobRewardedAd(
    String adUnitId,
    this._adRequest,
    this._immersiveModeEnabled,
  ) : super(adUnitId);

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.rewarded;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoading => _isAdLoading;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  void dispose() {
    _isAdLoaded = false;
    _isAdLoading = false;
    _isAdLoadedFailed = false;
    try {
      _rewardedAd?.dispose();
    } catch (_) {}
    _rewardedAd = null;
  }

  @override
  Future<void> load() async {
    if (_isAdLoaded) {
      return;
    }
    _isAdLoading = true;
    await RewardedAd.load(
        adUnitId: adUnitId,
        request: _adRequest,
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _rewardedAd?.onPaidEvent =
              (ad, valueMicros, precision, currencyCode) {
            onPaidEvent?.call(
              adNetwork,
              adUnitType,
              ad,
              valueMicros,
              precision,
              currencyCode,
            );
            onLogAdImpression?.call(
              adNetwork,
              adUnitType,
              ad,
              currencyCode,
              valueMicros,
            );
          };
          _isAdLoaded = true;
          _isAdLoadedFailed = false;
          _isAdLoading = false;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        }, onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isAdLoaded = false;
          _isAdLoadedFailed = true;
          _isAdLoading = false;
          onAdFailedToLoad?.call(
              adNetwork, adUnitType, error, error.toString());
        }));
  }

  @override
  dynamic show() async {
    final ad = _rewardedAd;
    if (ad == null) return;

    _rewardedAd = null;
    _isAdLoaded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        onAdDismissed?.call(adNetwork, adUnitType, ad);

        try {
          ad.dispose();
        } catch (_) {}
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());

        try {
          ad.dispose();
        } catch (_) {}
      },
    );

    try {
      await ad.setImmersiveMode(_immersiveModeEnabled);
    } catch (e) {
      // Ignore if setImmersiveMode fails (e.g. ad already null or disposed on native)
    }

    try {
      await ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onEarnedReward?.call(adNetwork, adUnitType, reward.type, reward.amount);
      });
    } catch (e) {
      onAdFailedToShow?.call(adNetwork, adUnitType, ad, e.toString());
      try {
        await ad.dispose();
      } catch (_) {}
    }
  }
}
