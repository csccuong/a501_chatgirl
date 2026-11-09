import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import '../../utils/app_setting.dart';
import '../../core/anim/ease_in_widget.dart';
import '../../core/router/app_route_observer.dart';
import '../../core/utils/app_util.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/constants.dart';
import '../../core/values/styles.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../routes/app_pages.dart';
import '../language/language_controller.dart';
import '../language/language_page.dart';
import '../premium/premium_controller.dart';
import '../premium/premium_page.dart';
import '../../ads/nativefull/native_full_screen.dart';

class SplashController extends BaseController {
  final int splashDelayDurationMs = 5000;
  final RxBool isProgressVisible = false.obs;
  var isSubsequentAppLaunch = false.obs;
  static final fbEventTracker = FacebookAppEvents();
  int networkMaxAttempts = 20;
  int networkRetryDelaySec = 1;
  int startupHoldDurationMs = 2000;
  Timer? _generalPurposeTimer;
  bool _isNoInternetDialogShown = false;
  StreamSubscription<List<ConnectivityResult>>? _networkStatusSub;
  bool _hasActiveNetwork = false;
  RxDouble startupLoadingRatio = 0.0.obs;
  Timer? _progressSimTicker;
  int _simProgressStep = 0;

  // Compatibility getter for views
  RxDouble get percentLoading => startupLoadingRatio;

  @override
  void onInit() {
    super.onInit();
    // 1. Immediately log Splash screen and event (no network dependency, fully cached offline)
    AppRouteObserver.logScreen('SplashScreen');
    FirebaseHelper.logEventName('splash', param: '');
    FirebaseHelper.logEventName('Splash', param: '');
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
    AdsService.initOrganic();
    isSubsequentAppLaunch.value = AppUtil.getBool("isNoFirstOpenApp");
    _probeNetworkState();
    _monitorConnectivityChanges();
  }

  @override
  void onReady() {
    recordStartupMetrics();
    setupFacebookTracker();
    trackRetentionMilestones();
  }

  @override
  void onClose() {
    _networkStatusSub?.cancel();
    _generalPurposeTimer?.cancel();
    _progressSimTicker?.cancel();
    super.onClose();
  }

  void setupAppPreferencesAndData() {
    AppSetting.initAppSetting();
  }

  void runProgressSimulation() {
    _progressSimTicker?.cancel();
    _progressSimTicker = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      _simProgressStep++;
      startupLoadingRatio.value = _simProgressStep.toDouble() / 100;
      if (_simProgressStep >= 100) {
        _progressSimTicker?.cancel();
        handlePostLaunchTransition();
      }
    });
  }

  // Check initial internet connection
  Future<void> _probeNetworkState() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    _onConnectivityStateChanged(connectivityResults);
  }

  // Listen for connectivity changes
  void _monitorConnectivityChanges() {
    _networkStatusSub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _onConnectivityStateChanged(results);
    });
  }

  // Handle connectivity status
  void _onConnectivityStateChanged(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _hasActiveNetwork = false;
    } else if (results.length == 1) {
      _hasActiveNetwork = !results.contains(ConnectivityResult.none) &&
          !results.contains(ConnectivityResult.bluetooth);
    } else {
      _hasActiveNetwork = true;
    }

    if (_hasActiveNetwork) {
      AppUtil.showLogFull(
          '_onConnectivityStateChanged _hasActiveNetwork: TRUE, isShowDialogNoInternet: $_isNoInternetDialogShown');
      if (_isNoInternetDialogShown &&
          Get.currentRoute == AppRoutes.SPLASH) {
        Get.back();
        _isNoInternetDialogShown = false;
      }
      setupAdsInfrastructure();
      setupFirebaseServices();
      runProgressSimulation();
    } else {
      AppUtil.showLogFull(
          '_onConnectivityStateChanged _hasActiveNetwork: FALSE, isShowDialogNoInternet: $_isNoInternetDialogShown');
      _progressSimTicker?.cancel();
      displayNoConnectionPrompt();
    }
  }

  Future<void> setupFacebookTracker() async {
    fbEventTracker.setAutoLogAppEventsEnabled(true);
    fbEventTracker.setUserID(await AppUtil().getDeviceId());
  }

  Future<void> setupAdsInfrastructure() async {
    if (Constants.isMobileAdsSDKInit) return;

    AppUtil.showLogFull(
        'setupAdsInfrastructure isMobileAdsSDKInit: ${Constants.isMobileAdsSDKInit}');

    // Set up global ad event listener
    EasyAds.instance.onEvent.listen((AdEvent event) {
      AppUtil.showLogFull("EasyAds Event: ${event.type} - ${event.adUnitType}");

      // 1. Paid Event (Revenue)
      if (event.type == AdEventType.onPaidEvent) {
        AppSetting.adImpressionCount++;
      }
      // 2. Impression Logging
      else if (event.type == AdEventType.onAdImpression) {
        if (event.ad == null) return;
        FirebaseHelper.logAdmobAdImpression(
          ad: event.ad!,
          adUnitType: event.adUnitType,
        );
      }
      // 3. Interstitial Show Count
      else if (event.type == AdEventType.adShowed &&
          event.adUnitType == AdUnitType.interstitial) {
        AppSetting.updateLastTimeShowAd();
        Constants.countWatchAdFull = AppSetting().getCountWatchAdFull() ?? 0;
        Constants.countWatchAdFull++;
        AppSetting().saveCountWatchAdFull();
        if (AppSetting().getCountWatchAdFull() == 5) {
          AdjustHelper().trackEventWatch5AdFull();
        } else if (AppSetting().getCountWatchAdFull() == 10) {
          AdjustHelper().trackEventWatch10AdFull();
        }
      }
    });

    Constants.isMobileAdsSDKInit = true;
    requestPreloadAdvertisements();
  }

  Future<void> requestPreloadAdvertisements() async {
    FirebaseHelper.logEventName("Start_load_ads", param: "");
    EasyAds.instance.loadAd();

    // Preload native full splash if enabled and not organic (priority: high loaded first)
    final bool isOrganic = await AdsService.isOrganicAsync();
    final bool showNativeFullHigh =
        FirebaseRemoteConfigService.isNativeFullSplashHighEnabled;
    final bool showNativeFull =
        FirebaseRemoteConfigService.isNativeFullSplashEnabled;
    if (!isOrganic &&
        (showNativeFullHigh || showNativeFull) &&
        !AppSetting.isPremiumUser.value &&
        !AppSetting.isRemoveAds.value) {
      if (showNativeFullHigh) {
        EasyAds.instance.preloadNativeAd(
          adId: MyAdIdName.nativeFullSplashHigh.getId,
          factoryId: MyAdIdName.nativeFull,
          height: AdDimen.largeNativeAdHeight,
          cacheKey: MyAdIdName.nativeFullSplashHigh,
        );
      }
      if (showNativeFull) {
        EasyAds.instance.preloadNativeAd(
          adId: MyAdIdName.nativeFullSplash.getId,
          factoryId: MyAdIdName.nativeFull,
          height: AdDimen.largeNativeAdHeight,
          cacheKey: MyAdIdName.nativeFullSplash,
        );
      }
    }

    // Preload native language ads if enabled in Remote Config (ONLY on first launch)
    if (!isSubsequentAppLaunch.value) {
      final bool showLanguageAd = FirebaseRemoteConfigService.getBoolConfigByKey(
              FirebaseRemoteConfigService.native_language) ||
          FirebaseRemoteConfigService.getBoolConfigByKey(
              FirebaseRemoteConfigService.native_language_high);
      final bool showLanguageClickAd = FirebaseRemoteConfigService.getBoolConfigByKey(
              FirebaseRemoteConfigService.native_language_alt) ||
          FirebaseRemoteConfigService.getBoolConfigByKey(
              FirebaseRemoteConfigService.native_language_high_alt);

      if (showLanguageAd) {
        EasyAds.instance.preloadNativeAd(
          adId: MyAdIdName.nativeLanguageHigh.getId,
          factoryId: 'nativeMedia',
          height: AdDimen.mediumNativeHeight,
          cacheKey: MyAdIdName.nativeLanguageHigh,
        );
      }
      if (showLanguageClickAd) {
        EasyAds.instance.preloadNativeAd(
          adId: MyAdIdName.nativeLanguageClickHigh.getId,
          factoryId: 'nativeMedia2',
          height: AdDimen.mediumNativeHeight,
          cacheKey: MyAdIdName.nativeLanguageClickHigh,
        );
      }
    }
  }

  void recordStartupMetrics() {
    AppRouteObserver.logScreen('SplashScreen');
    FirebaseHelper.logEventName('splash', param: '');
  }

  void handlePostLaunchTransition() {
    String choosedLangCode = AppUtil().getUserChoosedLanguage();
    if (choosedLangCode.isEmpty) {
      choosedLangCode = 'en';
    }
    final Locale targetLocale = Locale(choosedLangCode);
    initializeDateFormatting(choosedLangCode);
    Get.updateLocale(targetLocale);
    update();

    final bool showInterSplash = (FirebaseRemoteConfigService.getBoolConfigByKey(
                FirebaseRemoteConfigService.inter_splash) ||
            FirebaseRemoteConfigService.getBoolConfigByKey(
                FirebaseRemoteConfigService.inter_splash_high)) &&
        !AppSetting.isPremiumUser.value &&
        !AppSetting.isRemoveAds.value;

    if (showInterSplash) {
      EasyAds.instance.showInterstitialAdSplashWith2Id(
        Get.context!,
        interSplashHigh: MyAdIdName.interSplashHigh.getId,
        interSplashAll: MyAdIdName.interSplash.getId,
        onShowed: () {
          FirebaseHelper.logEventName(FirebaseHelper.inter_splash_view,
              param: "");
        },
        adDissmissed: () {
          showNativeFullOrNavigate();
        },
        onFailed: () {
          showNativeFullOrNavigate();
        },
      );
    } else {
      showNativeFullOrNavigate();
    }
  }

  Future<void> showNativeFullOrNavigate() async {
    final bool isOrganic = await AdsService.isOrganicAsync();
    final bool showNativeFullHigh =
        FirebaseRemoteConfigService.isNativeFullSplashHighEnabled;
    final bool showNativeFull =
        FirebaseRemoteConfigService.isNativeFullSplashEnabled;
    final bool canShowNativeFull = !isOrganic &&
        (showNativeFullHigh || showNativeFull) &&
        !AppSetting.isPremiumUser.value &&
        !AppSetting.isRemoveAds.value;

    if (canShowNativeFull) {
      Get.to(
        () => NativeFullScreen(
          nativeFullId: MyAdIdName.nativeFullSplash.getId,
          nativeFullHighId: showNativeFullHigh
              ? MyAdIdName.nativeFullSplashHigh.getId
              : null,
          handleNavigate: () {
            routeToAppropriateScreen();
          },
        ),
      );
    } else {
      routeToAppropriateScreen();
    }
  }

  void routeToAppropriateScreen() {
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
    final bool enableResumeAd = !AppSetting.isPremiumUser.value &&
        FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.resume_ad);
    EasyAds.instance.appLifecycleReactor?.setAllowAppOpenAd(enableResumeAd);
    setupAppPreferencesAndData();

    if (isSubsequentAppLaunch.value) {
      final bool showIap = FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.show_activity_iap);
      if (showIap && !AppSetting.isPremiumUser.value) {
        Get.offAllWithController(
          controllerBuilder: () => PremiumController(),
          page: () => const PremiumPage(),
          arguments: {"isFromSplash": true},
        );
      } else {
        Get.offAllNamed(
          AppRoutes.HOME,
          arguments: {"isFromSplash": true},
        );
      }
    } else {
      Get.offAllWithController(
        controllerBuilder: () => LanguageController(),
        page: () => const LanguagePage(),
        arguments: {'isFirstLaunch': true},
      );
    }
  }

  int calculateCalendarDaySpan(
      {required DateTime later, required DateTime earlier}) {
    later = DateTime.utc(later.year, later.month, later.day);
    earlier = DateTime.utc(earlier.year, earlier.month, earlier.day);
    return later.difference(earlier).inDays;
  }

  void trackRetentionMilestones() {
    final DateTime? firstTimeOpenApp = AppSetting().getFirstTimeOpenApp();
    if (firstTimeOpenApp == null) {
      AppUtil.showLogFull('getFirstTimeOpenApp NULL ==> Save firsttime');
      AppSetting().saveFirstTimeOpenApp();
    } else {
      AppUtil.showLogFull(
          'getFirstTimeOpenApp ${firstTimeOpenApp.toIso8601String()}');
      final int diffDays = calculateCalendarDaySpan(
          earlier: firstTimeOpenApp, later: DateTime.now());
      AppUtil.showLogFull('getFirstTimeOpenApp diffDays: $diffDays');

      if (diffDays >= 30) {
        final bool check30 = AppSetting().checkSendEventRetentionDay30();
        if (!check30) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 30');
          AdjustHelper().trackEventUserRetentionDay30();
          AppSetting().saveEventRetentionDay30();
        }
      } else if (diffDays >= 20) {
        final bool check20 = AppSetting().checkSendEventRetentionDay20();
        if (!check20) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 20');
          AdjustHelper().trackEventUserRetentionDay20();
          AppSetting().saveEventRetentionDay20();
        }
      } else if (diffDays >= 14) {
        final bool check14 = AppSetting().checkSendEventRetentionDay14();
        if (!check14) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 14');
          AdjustHelper().trackEventUserRetentionDay14();
          AppSetting().saveEventRetentionDay14();
        }
      } else if (diffDays >= 7) {
        final bool check7 = AppSetting().checkSendEventRetentionDay7();
        if (!check7) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 7');
          AdjustHelper().trackEventUserRetentionDay7();
          AppSetting().saveEventRetentionDay7();
        }
      } else if (diffDays >= 3) {
        final bool check3 = AppSetting().checkSendEventRetentionDay3();
        if (!check3) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 3');
          AdjustHelper().trackEventUserRetentionDay3();
          AppSetting().saveEventRetentionDay3();
        }
      } else if (diffDays >= 1) {
        final bool check1 = AppSetting().checkSendEventRetentionDay1();
        if (!check1) {
          AppUtil.showLogFull('getFirstTimeOpenApp log event and save 1');
          AdjustHelper().trackEventUserRetentionDay1();
          AppSetting().saveEventRetentionDay1();
        }
      }
    }
  }

  Future<void> displayNoConnectionPrompt() async {
    if (_isNoInternetDialogShown) {
      AppUtil.showLogFull('displayNoConnectionPrompt isShowDialogNoInternet: TRUE');
      return;
    }
    _isNoInternetDialogShown = true;
    if (isSubsequentAppLaunch.value) {
      FirebaseHelper.logEventName(FirebaseHelper.show_dialog_no_internet,
          param: "");
    } else {
      FirebaseHelper.logEventName(FirebaseHelper.show_dialog_no_internet_in_FO,
          param: "");
    }
    await Get.dialog(
      Center(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15.0),
                  Center(
                    child: Text(
                            '🎮 Connect to the Internet to Start the Fun!'.tr,
                            style: Styles.styleTextButtonMainColorBold,
                            textAlign: TextAlign.center)
                        .marginOnly(bottom: 5),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      'Please turn on Wi-Fi or mobile data to continue. The game needs an internet connection to load content and give you the best experience!'
                          .tr,
                      style: Styles.styleTextNormalMainColorLight,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.center,
                    child: EaseInWidget(
                      onTap: () {
                        const OpenSettingsPlusAndroid().wifi();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF5547AE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          height: 40,
                          width: 200,
                          child: Center(
                            child: Text(
                              "Settings".tr,
                              style: Styles.styleTextNormalWhiteColorBold,
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      useSafeArea: true,
    );
  }

  bool _hasConfiguredFirebaseServices = false;

  Future<void> setupFirebaseServices() async {
    if (_hasConfiguredFirebaseServices) return;
    _hasConfiguredFirebaseServices = true;
    try {
      AppRouteObserver.logScreen("SplashScreen");
      await fetchAppRemoteConfiguration();
    } catch (e) {
      AppUtil.showLogFull("error setup firebase: $e");
    }
  }

  Future<void> fetchAppRemoteConfiguration() async {
    try {
      await FirebaseRemoteConfigService.initFirebaseRemoteConfig();
      AppSetting.isInitRemoteConfig.value = true;
      final remoteInterval = FirebaseRemoteConfigService.getIntConfigByKey(
          FirebaseRemoteConfigService.interval_inter_ad);
      AppSetting.interval_inter_ad = remoteInterval > 0 ? remoteInterval : 35;
    } catch (e) {
      AppUtil.showLogFull("error fetch remote config: $e");
    }
  }
}
