import '../../easy_ads_flutter.dart';

class EasyAdmobAppOpenAd extends EasyAdBase {
  final AdRequest _adRequest;

  EasyAdmobAppOpenAd(super.adUnitId, this._adRequest);

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdLoadedFailed = false;
  DateTime? _loadTime;

  @override
  AdNetwork get adNetwork => AdNetwork.admob;

  @override
  AdUnitType get adUnitType => AdUnitType.appOpen;

  @override
  bool get isAdLoaded => _isAdLoaded;

  @override
  bool get isAdLoading => _isAdLoading;

  @override
  bool get isAdLoadedFailed => _isAdLoadedFailed;

  @override
  void dispose() {
    _isAdLoadedFailed = false;
    _isAdLoaded = false;
    _isAdLoading = false;
    _loadTime = null;
    _isShowingAd = false;
    try {
      _appOpenAd?.dispose();
    } catch (_) {}
    _appOpenAd = null;
  }

  @override
  Future<void> load() async {
    // Check if ad is expired (App Open Ads expire after 4 hours)
    if (_loadTime != null &&
        DateTime.now().difference(_loadTime!).inHours >= 4) {
      dispose();
    }

    if (isAdLoaded) {
      return;
    }
    _isAdLoading = true;
    _loadTime = DateTime.now(); // Track load time

    return AppOpenAd.load(
      adUnitId: adUnitId,
      request: _adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _appOpenAd?.onPaidEvent = (ad, valueMicros, precision, currencyCode) {
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
          _isAdLoading = false;
          _isAdLoadedFailed = false;
          onAdLoaded?.call(adNetwork, adUnitType, ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _appOpenAd = null;
          _isAdLoaded = false;
          _isAdLoading = false;
          _isAdLoadedFailed = true;
          _loadTime = null;
          onAdFailedToLoad?.call(
              adNetwork, adUnitType, error, error.toString());
        },
      ),
    );
  }

  @override
  dynamic show() async {
    if (!isAdLoaded) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null, 'Ad not loaded');
      return;
    }

    if (_isShowingAd) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null,
          'Tried to show ad while already showing an ad.');
      return;
    }

    final ad = _appOpenAd;
    if (ad == null) {
      onAdFailedToShow?.call(adNetwork, adUnitType, null, 'Ad is null');
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = true;
        onAdShowed?.call(adNetwork, adUnitType, ad);
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;
        onAdDismissed?.call(adNetwork, adUnitType, ad);
        try {
          ad.dispose();
        } catch (_) {}
        _appOpenAd = null;
        _isAdLoaded = false;
        _loadTime = null;
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;
        onAdFailedToShow?.call(adNetwork, adUnitType, ad, error.toString());
        try {
          ad.dispose();
        } catch (_) {}
        _appOpenAd = null;
        _isAdLoaded = false;
        _loadTime = null;
      },
    );

    try {
      await ad.show();
    } catch (e) {
      _isShowingAd = false;
      onAdFailedToShow?.call(adNetwork, adUnitType, ad, e.toString());
      try {
        await ad.dispose();
      } catch (_) {}
      _appOpenAd = null;
      _isAdLoaded = false;
      _loadTime = null;
    }
  }
}
