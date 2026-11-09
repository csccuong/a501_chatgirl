/*
import 'dart:io';

import 'package:code_scanner/core/utils/app_util.dart';
import 'package:flutter/services.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';

class IronSourceHelper with IronSourceImpressionDataListener, IronSourceInitializationListener, IronSourceBannerListener, IronSourceInterstitialListener {
  String flutterVersion = '3.10.2';
  String appKeyAndroid = "1304d220d"; //85460dcd
  String appKeyIOS = "fe6d93e9";

  bool isInterstitialAdAvailable = false;

   Future<void> initIronSource({required String appUserId}) async {
    final appKey = Platform.isAndroid
        ? appKeyAndroid
        : Platform.isIOS
            ? appKeyIOS
            : throw Exception("Unsupported Platform");
    try {
      IronSource.setFlutterVersion(flutterVersion);
      // IronSource.setFlutterVersion('2.8.1');
      IronSource.setImpressionDataListener(this);
      await enableDebug();
      await IronSource.shouldTrackNetworkState(true);

      // GDPR, CCPA, COPPA etc
      await setRegulationParams();

      // Segment info
      // await setSegment();

      // For Offerwall
      // Must be called before init
      // await IronSource.setClientSideCallbacks(true);

      // GAID, IDFA, IDFV
      String id = await IronSource.getAdvertiserId();
      print('AdvertiserID: $id');

      // Do not use AdvertiserID for this.
      await IronSource.setUserId(appUserId);

      // Authorization Request for IDFA use
      if (Platform.isIOS) {
        await checkATT();
      }

      // Finally, initialize
      await IronSource.init(
          appKey: appKey,
          adUnits: [IronSourceAdUnit.RewardedVideo, IronSourceAdUnit.Interstitial, IronSourceAdUnit.Banner, IronSourceAdUnit.Offerwall],
          initListener: this);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  /// For iOS14 IDFA access
  /// Must be called when the app is in the state UIApplicationStateActive
  Future<void> checkATT() async {
    final currentStatus = await ATTrackingManager.getTrackingAuthorizationStatus();
    print('ATTStatus: $currentStatus');
    if (currentStatus == ATTStatus.NotDetermined) {
      final returnedStatus = await ATTrackingManager.requestTrackingAuthorization();
      print('ATTStatus returned: $returnedStatus');
    }
    return;
  }

  Future<void> setRegulationParams() async {
    // GDPR
    await IronSource.setConsent(true);
    await IronSource.setMetaData({
      // CCPA
      'do_not_sell': ['false'],
      // COPPA
      'is_child_directed': ['false']
    });
    return;
  }

  Future<void> enableDebug() async {
    await IronSource.setAdaptersDebug(true);
    // this function doesn't have to be awaited
    IronSource.validateIntegration();
  }

  /// Sample Segment Params
  Future<void> setSegment() {
    final segment = IronSourceSegment();
    segment.age = 20;
    segment.gender = IronSourceUserGender.Female;
    segment.level = 3;
    segment.isPaying = false;
    segment.userCreationDateInMillis = DateTime.now().millisecondsSinceEpoch;
    segment.iapTotal = 1000;
    segment.setCustom(key: 'DemoCustomKey', value: 'DemoCustomVal');
    return IronSource.setSegment(segment);
  }

  loadISBanner() async {
    final isCapped = await IronSource.isBannerPlacementCapped('DefaultBanner');
    print('BN DefaultBanner capped: $isCapped');
    IronSource.setBNListener(this);
    // if (!isCapped) {
      final size = IronSourceBannerSize.SMART;
      // size.isAdaptive = true; // Adaptive Banner
      IronSource.loadBanner(
          size: size,
          position: IronSourceBannerPosition.Top,
          verticalOffset: -50,
          placementName: 'DefaultBanner');
    // }
    IronSource.displayBanner();
  }
  displayISBanner(){
    IronSource.displayBanner();
  }
  hideISBanner(){
    IronSource.hideBanner();
  }

  loadISInterstitial(){
    IronSource.setISListener(this);
    IronSource.loadInterstitial();
  }

  showISInterstitial() async {
    bool isISReady =  await IronSource.isInterstitialReady();
    AppUtil.showLog('showISInterstitial isReady: ${isISReady}');
    IronSource.showInterstitial();
  }

  /// ImpressionData listener ======================================================================
  @override
  void onImpressionSuccess(IronSourceImpressionData? impressionData) {
    print('IronSourceHelper Impression Data: $impressionData');
  }

  /// Initialization listener ======================================================================
  @override
  void onInitializationComplete() {
    print('IronSourceHelper onInitializationComplete');
  }

  /// BN listener ==================================================================================
  @override
  void onBannerAdClicked() {
    print("IronSourceHelper onBannerAdClicked");
  }

  @override
  void onBannerAdLoadFailed(IronSourceError error) {
    print("IronSourceHelper onBannerAdLoadFailed Error:$error");
    // if (mounted) {
    //   setState(() {
    //     _isBNLoaded = false;
    //   });
    // }
  }

  @override
  void onBannerAdLoaded() {
    print("IronSourceHelper onBannerAdLoaded");
    // if (mounted) {
    //   setState(() {
    //     _isBNLoaded = true;
    //   });
    // }
  }

  @override
  void onBannerAdScreenDismissed() {
    print("IronSourceHelper onBannerAdScreenDismissed");
  }

  @override
  void onBannerAdScreenPresented() {
    print("IronSourceHelper onBannerAdScreenPresented");
  }

  @override
  void onBannerAdLeftApplication() {
    print("IronSourceHelper onBannerAdLeftApplication");
  }

  /// IS listener ==================================================================================
  @override
  void onInterstitialAdClicked() {
    print("onInterstitialAdClicked");
  }

  @override
  void onInterstitialAdClosed() {
    print("onInterstitialAdClosed");
    isInterstitialAdAvailable = false;
  }

  @override
  void onInterstitialAdLoadFailed(IronSourceError error) {
    print("onInterstitialAdLoadFailed Error:$error");
    isInterstitialAdAvailable = false;
  }

  @override
  void onInterstitialAdOpened() {
    print("onInterstitialAdOpened");
  }

  @override
  void onInterstitialAdReady() {
    print("onInterstitialAdReady");
    isInterstitialAdAvailable = true;

    showISInterstitial();
  }

  @override
  void onInterstitialAdShowFailed(IronSourceError error) {
    print("onInterstitialAdShowFailed Error:$error");
    isInterstitialAdAvailable = false;
  }

  @override
  void onInterstitialAdShowSucceeded() {
    print("onInterstitialAdShowSucceeded");
  }
}
*/
