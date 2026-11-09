// ignore_for_file: avoid_print

import 'dart:async';

import 'package:adjust_sdk/adjust_config.dart';
import 'package:collection/collection.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/easy_admob/easy_admob_interstitial_ad.dart';
import 'package:easy_ads_flutter/src/easy_admob/easy_admob_rewarded_ad.dart';
import 'package:easy_ads_flutter/src/services/easy_firebase_service.dart';
import 'package:easy_ads_flutter/src/services/easy_shared_pref_service.dart';
import 'package:easy_ads_flutter/src/utils/easy_app_open_ad_with_2_id.dart';
import 'package:easy_ads_flutter/src/utils/easy_app_open_ad_with_id.dart';
import 'package:easy_ads_flutter/src/utils/easy_event_controller.dart';
import 'package:easy_ads_flutter/src/utils/easy_interstitial_ad_splash.dart';
import 'package:easy_ads_flutter/src/utils/easy_interstitial_ad_splash_with_2_id.dart';
import 'package:easy_ads_flutter/src/utils/easy_logger.dart';
import 'package:easy_ads_flutter/src/utils/extensions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'easy_admob/easy_admob_native_ad.dart';
import 'services/easy_adjust_service.dart';
import 'utils/easy_app_open_ad.dart';
import 'utils/easy_interstitial_ad_splash_with_3_id.dart';
import 'utils/easy_splash_ad_with_interstitial_and_app_open.dart';

class EasyAds {
  EasyAds._easyAds();

  static final EasyAds instance = EasyAds._easyAds();

  AppLifecycleReactor? appLifecycleReactor;

  // SharedPreferences singleton
  static SharedPreferences? _sharedPreferences;

  // Getter for SharedPreferences
  static SharedPreferences? get sharedPreferences => _sharedPreferences;

  /// Google admob's ad request
  AdRequest _adRequest = const AdRequest();
  late final IAdIdManager adIdManager;
  static Widget? _loadingSplashWidget;
  static Widget? _loadingAdPopupWidget;
  static String _defaultLoadingMessage = 'Loading Ads';

  // Expose configured loading splash/message to module widgets
  static Widget? get configuredLoadingSplash => _loadingSplashWidget;
  static Widget? get configuredLoadingAdPopup => _loadingAdPopupWidget;
  static void setLoadingAdPopup(Widget? popup) => _loadingAdPopupWidget = popup;

  static String get configuredLoadingMessage => _defaultLoadingMessage;

  /// True value when there is exist an Ad and false otherwise.
  bool _isFullscreenAdShowing = false;

  /// Flag to disable app open ad from lifecycle when showing manually
  bool _isManualAppOpenAdShowing = false;

  /// Flag to indicate that an IAP (In-App Purchase) flow is active
  bool _isIAPFlowActive = false;
  DateTime? _iapFlowStartTime;
  DateTime? _appOpenAdSuppressedUntil;
  bool Function()? _adSuppressedCallback;

  void setManualAppOpenAdShowing(bool value) =>
      _isManualAppOpenAdShowing = value;

  bool get isManualAppOpenAdShowing => _isManualAppOpenAdShowing;

  void setFullscreenAdShowing(bool value) => _isFullscreenAdShowing = value;

  bool get isFullscreenAdShowing => _isFullscreenAdShowing;

  void setIAPFlowActive(bool value) {
    _isIAPFlowActive = value;
    if (value) {
      _iapFlowStartTime = DateTime.now();
      suppressAppOpenAd(const Duration(minutes: 5));
    } else {
      _iapFlowStartTime = null;
      // When IAP flow finishes (canceled, purchased, error), keep open ad suppressed
      // for a short cooldown period (e.g. 5 seconds) to absorb any lagging resume lifecycle events
      suppressAppOpenAd(const Duration(seconds: 5));
    }
  }

  bool get isIAPFlowActive {
    if (!_isIAPFlowActive) return false;
    // Auto timeout after 10 minutes if no completion was reported
    if (_iapFlowStartTime != null &&
        DateTime.now().difference(_iapFlowStartTime!).inMinutes > 10) {
      _isIAPFlowActive = false;
      _iapFlowStartTime = null;
      return false;
    }
    return true;
  }

  void suppressAppOpenAd([Duration duration = const Duration(seconds: 5)]) {
    final newSuppressedUntil = DateTime.now().add(duration);
    if (_appOpenAdSuppressedUntil == null ||
        newSuppressedUntil.isAfter(_appOpenAdSuppressedUntil!)) {
      _appOpenAdSuppressedUntil = newSuppressedUntil;
    }
  }

  bool get isAppOpenAdSuppressed {
    if (isIAPFlowActive) return true;
    if (_appOpenAdSuppressedUntil != null) {
      if (DateTime.now().isBefore(_appOpenAdSuppressedUntil!)) {
        return true;
      }
      _appOpenAdSuppressedUntil = null;
    }
    return false;
  }

  void setAdSuppressedCallback(bool Function()? callback) {
    _adSuppressedCallback = callback;
  }

  bool get isAdSuppressedByCallback => _adSuppressedCallback?.call() ?? false;

  final _eventController = EasyEventController();

  Stream<AdEvent> get onEvent => _eventController.onEvent;

  List<EasyAdBase> get _allAds => [..._interstitialAds, ..._rewardedAds];

  /// All the interstitial ads will be stored in it
  final List<EasyAdBase> _appOpenAds = [];

  /// All the interstitial ads will be stored in it
  final List<EasyAdBase> _interstitialAds = [];

  /// All the rewarded ads will be stored in it
  final List<EasyAdBase> _rewardedAds = [];

  /// Cache pool for preloaded Native Ads
  final Map<String, EasyAdBase> _nativeAdCache = {};

  /// [_logger] is used to show Ad logs in the console
  final EasyLogger _logger = EasyLogger();
  AdSize? adSize;
  bool _initialized = false;

  /// Initializes the Google Mobile Ads SDK.
  ///
  /// Call this method as early as possible after the app launches
  /// [adMobAdRequest] will be used in all the admob requests. By default empty request will be used if nothing passed here.
  /// [fbTestingId] can be obtained by running the app once without the testingId.
  Future<void> initialize(
    IAdIdManager manager, {
    bool unityTestMode = false,
    AdRequest? adMobAdRequest,
    RequestConfiguration? admobConfiguration,
    bool enableLogger = true,
    String? fbTestingId,
    bool fbiOSAdvertiserTrackingEnabled = false,
    GlobalKey<NavigatorState>? navigatorKey,
    Widget? loadingSplash,
    String? loadingMessage,
  }) async {
    // If already initialized, allow updating optional UI configs and return
    if (_initialized) {
      _loadingSplashWidget = loadingSplash ?? _loadingSplashWidget;
      if (loadingMessage != null && loadingMessage.isNotEmpty) {
        _defaultLoadingMessage = loadingMessage;
      }
      return;
    }
    // Initialize SharedPreferences if not already initialized
    _sharedPreferences ??= await SharedPreferences.getInstance();
    if (enableLogger) _logger.enable(enableLogger);
    adIdManager = manager;
    if (adMobAdRequest != null) {
      _adRequest = adMobAdRequest;
    }

    if (manager.admobAdIds?.appId != null) {
      final response = await MobileAds.instance.initialize();
      final status = response.adapterStatuses.values.firstOrNull?.state;
      if (admobConfiguration != null) {
        await MobileAds.instance.updateRequestConfiguration(admobConfiguration);
      }

      _eventController.fireNetworkInitializedEvent(
          AdNetwork.admob, status == AdapterInitializationState.ready);
      if (navigatorKey != null) {
        appLifecycleReactor = AppLifecycleReactor(navigatorKey: navigatorKey);
        appLifecycleReactor!.listenToAppStateChanges();
      }

      if (navigatorKey?.currentContext != null) {
        adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(navigatorKey!.currentContext!).size.width.round());
      }
    }

    _loadingSplashWidget = loadingSplash;
    if (loadingMessage != null && loadingMessage.isNotEmpty) {
      _defaultLoadingMessage = loadingMessage;
    }
    _initialized = true;
  }

  Future<void> initAdjust(AdjustConfig config) async {
    await EasyAdjustService().initAdjust(config);
  }

  Future<void> initFirebaseAnalytics(FirebaseAnalytics analytics) async {
    EasyFirebaseService().init(analytics);
  }

  /// Returns [EasyAdBase] if ad is created successfully. It assumes that you have already assigned banner id in Ad Id Manager
  ///
  /// if [adNetwork] is provided, only that network's ad would be created. For now, only unity and admob banner is supported
  /// [adSize] is used to provide ad banner size
  EasyAdBase? createBanner({
    required AdNetwork adNetwork,
    required AdSize? adSize,
    required String adId,
    required bool isCollapsible,
  }) {
    if (isAdSuppressedByCallback) return null;
    EasyAdBase? ad;

    switch (adNetwork) {
      case AdNetwork.admob:
        ad = EasyAdmobBannerAd(
          adId,
          adSize: adSize,
          adRequest: isCollapsible
              ? AdRequest(
                  httpTimeoutMillis: _adRequest.httpTimeoutMillis,
                  extras: {'collapsible': 'bottom'},
                )
              : _adRequest,
        );
        _eventController.setupEvents(ad);
        break;
      default:
        ad = null;
    }
    return ad;
  }

  EasyAdBase? createNative({
    required AdNetwork adNetwork,
    required String factoryId,
    required String adId,
    required double height,
  }) {
    if (isAdSuppressedByCallback) return null;
    EasyAdBase? ad;
    ad = EasyAdmobNativeAd(
      adId,
      factoryId,
      height,
      adRequest: _adRequest,
    );
    _eventController.setupEvents(ad);
    return ad;
  }

  EasyAdBase? createInterstitial({
    required AdNetwork adNetwork,
    required String adId,
    bool immersiveModeEnabled = true,
  }) {
    if (isAdSuppressedByCallback) return null;
    EasyAdBase? ad;
    ad = EasyAdmobInterstitialAd(adId, _adRequest, immersiveModeEnabled);
    _eventController.setupEvents(ad);
    return ad;
  }

  EasyAdBase? createReward({
    required AdNetwork adNetwork,
    required String adId,
    bool immersiveModeEnabled = true,
  }) {
    EasyAdBase? ad;
    ad = EasyAdmobRewardedAd(adId, _adRequest, immersiveModeEnabled);
    _eventController.setupEvents(ad);
    return ad;
  }

  EasyAdBase? createAppOpenAd({
    required AdNetwork adNetwork,
    required String adId,
    // int orientation = AppOpenAd.orientationPortrait,
  }) {
    EasyAdBase? ad;
    ad = EasyAdmobAppOpenAd(adId, _adRequest);
    _eventController.setupEvents(ad);
    return ad;
  }

  /// Preloads a native ad with a specific ID, factory ID, and height, and stores it in the cache under a unique cacheKey.
  Future<void> preloadNativeAd({
    required String adId,
    required String factoryId,
    required double height,
    required String cacheKey,
    AdNetwork adNetwork = AdNetwork.admob,
  }) async {
    if (isAdSuppressedByCallback || adId.isEmpty || cacheKey.isEmpty) return;

    // If already preloading or loaded, don't load again
    if (_nativeAdCache.containsKey(cacheKey)) {
      final cachedAd = _nativeAdCache[cacheKey]!;
      if (cachedAd.isAdLoaded || cachedAd.isAdLoading) {
        _logger.logInfo('Native Ad with cacheKey $cacheKey is already loaded or loading.');
        return;
      }
    }

    _logger.logInfo('Preloading Native Ad for cacheKey $cacheKey with adId $adId and height: $height');
    final ad = createNative(
      adNetwork: adNetwork,
      factoryId: factoryId,
      adId: adId,
      height: height,
    );

    if (ad != null) {
      _nativeAdCache[cacheKey] = ad;
      await ad.load();
    }
  }

  /// Retrieves a cached native ad by its cache key.
  EasyAdBase? getCachedNativeAd(String cacheKey) {
    return _nativeAdCache[cacheKey];
  }

  /// Disposes and removes a specific cached native ad.
  void disposeCachedNativeAd(String cacheKey) {
    if (_nativeAdCache.containsKey(cacheKey)) {
      _logger.logInfo('Disposing cached Native Ad for cacheKey: $cacheKey');
      _nativeAdCache[cacheKey]?.dispose();
      _nativeAdCache.remove(cacheKey);
    }
  }

  /// Disposes and clears all cached native ads.
  void clearNativeAdCache() {
    _logger.logInfo('Clearing all cached Native Ads');
    for (final ad in _nativeAdCache.values) {
      ad.dispose();
    }
    _nativeAdCache.clear();
  }

  /// Disposes all cached ads and disables app open ads.
  void destroyAllAds() {
    clearNativeAdCache();
    appLifecycleReactor?.setAllowAppOpenAd(false);
  }

  Future<void> initAdmob({
    String? appOpenAdUnitId,
    // int appOpenAdOrientation = AppOpenAd.orientationPortrait,
  }) async {
    if (appOpenAdUnitId != null &&
        _appOpenAds.doesNotContain(AdNetwork.admob, AdUnitType.appOpen)) {
      final appOpenAdManager = EasyAdmobAppOpenAd(appOpenAdUnitId, _adRequest);
      _appOpenAds.add(appOpenAdManager);
      _eventController.setupEvents(appOpenAdManager);
      try {
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  /// Displays random ad network [adUnitType] ad.
  /// It will randomly display one network and if that network's ad is not loaded, it will try second and so on until it exhaust all the network ads.
  /// Returns bool indicating whether ad has been successfully displayed or not
  ///
  /// [adUnitType] should be mentioned here, only interstitial or rewarded should be mentioned here
  bool showRandomAd(AdUnitType adUnitType) {
    assert(
        adUnitType == AdUnitType.interstitial ||
            adUnitType == AdUnitType.rewarded,
        'Only interstitial and rewarded types should be passed to this method');

    final List<EasyAdBase> ads = (adUnitType == AdUnitType.rewarded
            ? _rewardedAds
            : _interstitialAds)
        .toList(growable: false)
      ..shuffle();

    for (final ad in ads) {
      if (ad.isAdLoaded) {
        ad.show();
        return true;
      } else {
        _logger.logInfo(
            '${ad.adNetwork} ${ad.adUnitType} was not loaded, so called loading');
        ad.load();
      }
    }

    return false;
  }

  /// Show app open ad with a specific ad ID
  /// This is used when you want to show app open ad with a custom ID (not from app lifecycle)
  void showAppOpenAdWithId(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
    Function()? callback,
  }) {
    if (_isFullscreenAdShowing ||
        _isManualAppOpenAdShowing ||
        isIAPFlowActive ||
        isAppOpenAdSuppressed ||
        isAdSuppressedByCallback) {
      return;
    }
    _isManualAppOpenAdShowing = true;
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) =>
            EasyAppOpenAdWithId(
          adNetwork: adNetwork,
          adId: adId,
          onShowed: onShowed,
          adDismissed: adDissmissed,
          onFailed: () {
            _isManualAppOpenAdShowing = false;
            onFailed?.call();
          },
          callback: () {
            _isManualAppOpenAdShowing = false;
            callback?.call();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// Show app open ad with 2 IDs (high priority and all users)
  /// This is used to replace showInterstitialAdSplashWith2Id at Splash screen
  /// It will try to show the high priority ad first, then fallback to all users ad
  void showAppOpenAdWith2Id(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String appOpenHigh,
    required String appOpenAll,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
    Function()? callback,
  }) {
    if (_isFullscreenAdShowing ||
        _isManualAppOpenAdShowing ||
        isIAPFlowActive ||
        isAppOpenAdSuppressed ||
        isAdSuppressedByCallback) {
      return;
    }
    _isManualAppOpenAdShowing = true;
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) =>
            EasyAppOpenAdWith2Id(
          adNetwork: adNetwork,
          appOpenHigh: appOpenHigh,
          appOpenAll: appOpenAll,
          onShowed: onShowed,
          adDismissed: () {
            _isManualAppOpenAdShowing = false;
            adDissmissed?.call();
          },
          onFailed: () {
            _isManualAppOpenAdShowing = false;
            onFailed?.call();
          },
          callback: () {
            _isManualAppOpenAdShowing = false;
            callback?.call();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  /// Displays [adUnitType] ad from [adNetwork]. It will check if first ad it found from list is loaded,
  /// it will be displayed if [adNetwork] is not mentioned otherwise it will load the ad.
  ///
  /// Returns bool indicating whether ad has been successfully displayed or not
  ///
  /// [adUnitType] should be mentioned here, only interstitial or rewarded should be mentioned here
  /// if [adNetwork] is provided, only that network's ad would be displayed
  /// if [random] is true, any random loaded ad would be displayed
  Future<bool> showAd(AdUnitType adUnitType,
      {AdNetwork adNetwork = AdNetwork.any}) async {
    List<EasyAdBase> ads = [];
    if (adUnitType == AdUnitType.rewarded) {
      ads = _rewardedAds;
    } else if (adUnitType == AdUnitType.interstitial) {
      ads = _interstitialAds;
    } else if (adUnitType == AdUnitType.appOpen) {
      ads = _appOpenAds;
    }

    // Simple logic: Show if loaded, otherwise try to load once (but not for app open ads)
    for (final ad in ads) {
      if (ad.isAdLoaded) {
        if (adNetwork == AdNetwork.any || adNetwork == ad.adNetwork) {
          ad.show();
          return true;
        }
      } else if (adUnitType != AdUnitType.appOpen) {
        // Only auto-load for non-app-open ads (app open ads use loadAndShowAppOpenAd)
        _logger.logInfo(
            '${ad.adNetwork} ${ad.adUnitType} was not loaded, trying to load');
        await ad.load();
        // Give it a moment to load
        await Future.delayed(const Duration(seconds: 1));
        if (ad.isAdLoaded) {
          if (adNetwork == AdNetwork.any || adNetwork == ad.adNetwork) {
            ad.show();
            return true;
          }
        }
      } else {
        // For app open ads, don't auto-load here - use loadAndShowAppOpenAd instead
        _logger.logInfo(
            '${ad.adNetwork} ${ad.adUnitType} not loaded, skipping auto-load (use loadAndShowAppOpenAd)');
      }
    }

    _logger.logInfo('Failed to show ${adUnitType.name} ad');
    return false;
  }

  /// This will load both rewarded and interstitial ads.
  /// If a particular ad is already loaded, it will not load it again.
  /// Also you do not have to call this method everytime. Ad is automatically loaded after being displayed.
  ///
  /// if [adNetwork] is provided, only that network's ad would be loaded
  void loadAd({AdNetwork adNetwork = AdNetwork.any}) {
    for (final e in _rewardedAds) {
      if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
        e.load();
      }
    }

    for (final e in _interstitialAds) {
      if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
        e.load();
      }
    }
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isRewardedAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _rewardedAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isInterstitialAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _interstitialAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    return ad?.isAdLoaded ?? false;
  }

  /// Returns bool indicating whether ad has been loaded
  ///
  /// if [adNetwork] is provided, only that network's ad would be checked
  bool isAppOpenAdLoaded({AdNetwork adNetwork = AdNetwork.any}) {
    final ad = _appOpenAds.firstWhereOrNull((e) =>
        (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
        e.isAdLoaded);
    bool isLoaded = ad?.isAdLoaded ?? false;
    return isLoaded;
  }

  /// This will load app open ads.
  /// If a particular ad is already loaded, it will not load it again.
  /// Also you do not have to call this method everytime. Ad is automatically loaded after being displayed.
  ///
  /// if [adNetwork] is provided, only that network's ad would be loaded
  void loadAppOpenAd({AdNetwork adNetwork = AdNetwork.any}) {
    for (final e in _appOpenAds) {
      if (adNetwork == AdNetwork.any || adNetwork == e.adNetwork) {
        e.load();
      }
    }
  }

  /// Do not call this method until unless you want to remove ads entirely from the app.
  /// Best user case for this method could be removeAds In app purchase.
  ///
  /// After this, ads would stop loading. You would have to call initialize again.
  ///
  /// if [adNetwork] is provided only that network's ads will be disposed otherwise it will be ignored
  /// if [adUnitType] is provided only that ad unit type will be disposed, otherwise it will be ignored
  void destroyAds(
      {AdNetwork adNetwork = AdNetwork.any, AdUnitType? adUnitType}) {
    for (final e in _allAds) {
      if ((adNetwork == AdNetwork.any || adNetwork == e.adNetwork) &&
          (adUnitType == null || adUnitType == e.adUnitType)) {
        e.dispose();
      }
    }
  }

  void showInterstitialAd(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
  }) {
    if (_isFullscreenAdShowing) {
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) => EasyInterstitialAd(
          adNetwork: adNetwork,
          adId: adId,
          onShowed: onShowed,
          onFailed: onFailed,
          adDismissed: adDissmissed,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void showInterstitialAdSplash(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
  }) {
    if (_isFullscreenAdShowing) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EasyInterstitialAdSplash(
          adNetwork: adNetwork,
          adId: adId,
          onShowed: onShowed,
          onFailed: onFailed,
          adDismissed: adDissmissed,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void showInterstitialAdSplashWith3Id(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String interSplashHigh,
    required String interSplashMedium,
    required String interSplashAll,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
  }) {
    if (_isFullscreenAdShowing) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EasyInterstitialAdSplashWith3Id(
          adNetwork: adNetwork,
          adIdHigh: interSplashHigh,
          adIdMedium: interSplashMedium,
          adIdAll: interSplashAll,
          onShowed: onShowed,
          onFailed: onFailed,
          adDismissed: adDissmissed,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void showInterstitialAdSplashWith2Id(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String interSplashHigh,
    required String interSplashAll,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
  }) {
    if (_isFullscreenAdShowing) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EasyInterstitialAdSplashWith2Id(
          adNetwork: adNetwork,
          adIdHigh: interSplashHigh,
          adIdAll: interSplashAll,
          onShowed: onShowed,
          onFailed: onFailed,
          adDismissed: adDissmissed,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void showRewardAd(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String adId,
    Function()? onShowed,
    Function()? adDissmissed,
    Function()? onFailed,
  }) {
    if (_isFullscreenAdShowing) {
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) => EasyRewardAd(
          adNetwork: adNetwork,
          adId: adId,
          onShowed: onShowed,
          onFailed: onFailed,
          adDismissed: adDissmissed,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void showSplashAdWithInterstitialAndAppOpen(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    required String interstitialSplashAdId,
    required String appOpenAdId,
    Function()? onShowed,
    Function()? onDismissed,
    Function()? onFailedToLoad,
  }) {
    if (_isFullscreenAdShowing) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EasySplashAdWithInterstitialAndAppOpen(
          adNetwork: adNetwork,
          interstitialSplashAdId: interstitialSplashAdId,
          appOpenAdId: appOpenAdId,
          onShowed: onShowed,
          onDismissed: onDismissed,
          onFailedToLoad: onFailedToLoad,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void showAppOpenAd(
    BuildContext context, {
    AdNetwork adNetwork = AdNetwork.admob,
    Function()? callback,
  }) {
    if (_isFullscreenAdShowing ||
        isIAPFlowActive ||
        isAppOpenAdSuppressed ||
        isAdSuppressedByCallback) {
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        // cho phép nền sau hiển thị mờ
        barrierColor: Colors.black54,
        // màu nền mờ
        pageBuilder: (context, animation, secondaryAnimation) =>
            EasyAppOpenAd(adNetwork: adNetwork),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
