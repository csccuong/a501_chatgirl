import 'dart:io';
import '../../flavors/build_config.dart';
import '../../flavors/environment.dart';

class MyAdIdName {
  //app id here

  /// test
  static String get appID {
    final isProd = BuildConfig.instance.environment == Environment.PRODUCTION;
    if (isProd) {
      if (Platform.isAndroid) {
        return "ca-app-pub-9900730300733887~3917983027";
      } else {
        return "ca-app-pub-3940256099942544/5575463023";
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544~3347511713";
      } else {
        return "ca-app-pub-3940256099942544/5575463023";
      }
    }
  }

  //ads id name here
  static const appOpenResume = "appOpenResume";
  static const interSplash = "interSplash";
  static const interSplashHigh = "interSplashHigh";
  static const nativeLanguage = "nativeLanguage";
  static const nativeLanguageHigh = "nativeLanguageHigh";
  static const nativeLanguageClick = "nativeLanguageClick";
  static const nativeLanguageClickHigh = "nativeLanguageClickHigh";
  static const nativeOnboard1Ad = "nativeOnboard1Ad";
  static const nativeOnboardFull1Ad = "nativeOnboardFull1Ad";
  static const nativeOnboardFull2Ad = "nativeOnboardFull2Ad";
  static const nativeOnboard3Ad = "nativeOnboard3Ad";
  static const interAllAd = "interAllAd";
  static const nativeFull = "nativeFull";
  static const rewardedAd = "rewardedAd";
  static const bannerAll = "bannerAll";
  static const interstitialOnboard = "interstitialOnboard";
  static const nativeHome = "nativeHome";
  static const bannerSplash = "bannerSplash";
  static const nativeFullSplash = "nativeFullSplash";
  static const nativeFullSplashHigh = "nativeFullSplashHigh";
}

enum AdType { nativeExpand, nativeCollapse }

