import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EasyAds IAP and App Open Ad Suppression Tests', () {
    setUp(() {
      EasyAds.instance.setIAPFlowActive(false);
      EasyAds.instance.setAdSuppressedCallback(null);
    });

    test('IAP flow active sets suppression', () {
      expect(EasyAds.instance.isIAPFlowActive, isFalse);

      EasyAds.instance.setIAPFlowActive(true);
      expect(EasyAds.instance.isIAPFlowActive, isTrue);
      expect(EasyAds.instance.isAppOpenAdSuppressed, isTrue);

      EasyAds.instance.setIAPFlowActive(false);
      expect(EasyAds.instance.isIAPFlowActive, isFalse);
      // Immediately after IAP ends, cooldown suppression remains active
      expect(EasyAds.instance.isAppOpenAdSuppressed, isTrue);
    });

    test('adSuppressedCallback works correctly', () {
      bool isPremium = false;
      EasyAds.instance.setAdSuppressedCallback(() => isPremium);

      expect(EasyAds.instance.isAdSuppressedByCallback, isFalse);

      isPremium = true;
      expect(EasyAds.instance.isAdSuppressedByCallback, isTrue);
    });

    test('AppLifecycleReactor setPausedByIAP', () {
      final navKey = GlobalKey<NavigatorState>();
      final reactor = AppLifecycleReactor(navigatorKey: navKey);
      reactor.setAllowAppOpenAd(true);
      reactor.setOnSplashScreen(false);

      reactor.setPausedByIAP(true);
      // Trigger inactive then resume: ad should not show because wasPausedByIAP is true
      reactor.didChangeAppLifecycleState(AppLifecycleState.inactive);
      reactor.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Verify that after resumed, the one-time flag resets cleanly
      expect(EasyAds.instance.isFullscreenAdShowing, isFalse);
    });
    test('createBanner, createNative, createInterstitial return null when suppressed', () {
      bool isPremium = true;
      EasyAds.instance.setAdSuppressedCallback(() => isPremium);

      final banner = EasyAds.instance.createBanner(
        adNetwork: AdNetwork.admob,
        adSize: AdSize.banner,
        adId: 'test_banner',
        isCollapsible: false,
      );
      expect(banner, isNull);

      final native = EasyAds.instance.createNative(
        adNetwork: AdNetwork.admob,
        factoryId: 'factory',
        adId: 'test_native',
        height: 100,
      );
      expect(native, isNull);

      final inter = EasyAds.instance.createInterstitial(
        adNetwork: AdNetwork.admob,
        adId: 'test_inter',
      );
      expect(inter, isNull);
    });

    test('destroyAllAds works cleanly', () {
      expect(() => EasyAds.instance.destroyAllAds(), returnsNormally);
    });
  });
}
