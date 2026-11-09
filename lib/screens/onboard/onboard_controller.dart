import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../core/utils/app_util.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../utils/app_setting.dart';
import '../ads_full/ads_full_controller.dart';
import '../ads_full/ads_full_page.dart';
import '../premium2/premium2_controller.dart';
import '../premium2/premium2_page.dart';

class OnboardStep {
  final String title;
  final String desc;
  final String image;
  final String adId;
  final String factoryId;
  final EasyAdBase? fullAd;
  final BoxFit fit;

  OnboardStep({
    this.title = '',
    this.desc = '',
    this.image = '',
    this.adId = '',
    this.factoryId = '',
    this.fullAd,
    this.fit = BoxFit.cover,
  });
}

class OnboardController extends BaseController {
  OnboardController();

  final PageController slideDeckController = PageController();
  final RxInt activeSlideIndex = 0.obs;

  EasyAdBase? fullScreenAdInstance1;
  EasyAdBase? fullScreenAdInstance2;

  final RxInt totalSlidesDeck = 4.obs;
  final RxBool canRenderFullScreenAd1 = false.obs;
  final RxBool canRenderFullScreenAd2 = false.obs;
  final RxBool isDisplayingFullScreenAd1 = false.obs;
  final RxBool isDisplayingFullScreenAd2 = false.obs;

  final RxBool isHeroSlide1AdLoading = false.obs;
  final RxBool isHeroSlide3AdLoading = false.obs;

  final RxInt activeIntroStep = 0.obs;

  StreamSubscription? _onboardAdEventSub;
  final RxBool isSkipAdButtonRevealed = false.obs;
  Timer? _revealSkipCountdownTimer;
  Timer? _heroSlide1AdTimeout;
  Timer? _heroSlide3AdTimeout;
  Timer? _heroSlide1AdGraceTimer;
  Timer? _heroSlide3AdGraceTimer;

  // Compatibility aliases
  PageController get pageController => slideDeckController;
  RxInt get currentIndex => activeSlideIndex;
  RxInt get totalPage => totalSlidesDeck;
  RxBool get shouldShowAdsFull1 => canRenderFullScreenAd1;
  RxBool get shouldShowAdsFull2 => canRenderFullScreenAd2;
  RxBool get isShowingAdsFull1 => isDisplayingFullScreenAd1;
  RxBool get isShowingAdsFull2 => isDisplayingFullScreenAd2;
  RxBool get isIntro1AdLoading => isHeroSlide1AdLoading;
  RxBool get isIntro3AdLoading => isHeroSlide3AdLoading;
  RxInt get currentTabOnboard => activeIntroStep;
  RxBool get isFullAdNextButtonVisible => isSkipAdButtonRevealed;

  @override
  void onInit() {
    super.onInit();
    initializeOnboardingAds();
    FirebaseHelper.setTrackingScreenName("OnboardScreen");
  }

  @override
  void onClose() {
    _onboardAdEventSub?.cancel();
    _revealSkipCountdownTimer?.cancel();
    _heroSlide1AdTimeout?.cancel();
    _heroSlide3AdTimeout?.cancel();
    _heroSlide1AdGraceTimer?.cancel();
    _heroSlide3AdGraceTimer?.cancel();
    fullScreenAdInstance1?.dispose();
    fullScreenAdInstance2?.dispose();
    slideDeckController.dispose();
    super.onClose();
  }

  void handleBackStep() {
    Get.back();
  }

  void onSelectBack() => handleBackStep();

  Future<void> initializeOnboardingAds() async {
    final String keyOnboard1 = FirebaseRemoteConfigService.native_onboarding_1;
    final String keyOnboardFull1 = FirebaseRemoteConfigService.native_onboarding_full_1;
    final String keyOnboardFull2 = FirebaseRemoteConfigService.native_onboarding_full_2;
    final bool isOrganic = await AdsService.isOrganicAsync();

    final bool showAd1 = FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard1);
    if (showAd1 && !AppSetting.isPremiumUser.value) {
      final ad = EasyAds.instance.getCachedNativeAd(MyAdIdName.nativeOnboard1Ad);
      final isAdLoaded = ad != null && ad.isAdLoaded;

      if (isAdLoaded) {
        isHeroSlide1AdLoading.value = true;
        _heroSlide1AdGraceTimer?.cancel();
        _heroSlide1AdGraceTimer = Timer(const Duration(milliseconds: 500), () {
          isHeroSlide1AdLoading.value = false;
          update();
        });
      } else {
        isHeroSlide1AdLoading.value = true;
        _heroSlide1AdTimeout?.cancel();
        _heroSlide1AdTimeout = Timer(const Duration(seconds: 7), () {
          if (isHeroSlide1AdLoading.value) {
            isHeroSlide1AdLoading.value = false;
            update();
          }
        });
      }
    } else {
      isHeroSlide1AdLoading.value = false;
    }
    isHeroSlide3AdLoading.value = false;
    update();

    if (!AppSetting.isPremiumUser.value && !isOrganic) {
      if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboardFull1)) {
        fullScreenAdInstance1 = EasyAds.instance.createNative(
          adNetwork: AdNetwork.admob,
          factoryId: 'nativeFull',
          adId: MyAdIdName.nativeOnboardFull1Ad.getId,
          height: Get.height,
        );
        final originalLoaded = fullScreenAdInstance1?.onAdLoaded;
        fullScreenAdInstance1?.onAdLoaded = (adNetwork, adUnitType, data) {
          originalLoaded?.call(adNetwork, adUnitType, data);
          canRenderFullScreenAd1.value = true;
          isDisplayingFullScreenAd1.value = true;
          update();
        };
        fullScreenAdInstance1?.load();
      }
      if (FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboardFull2)) {
        fullScreenAdInstance2 = EasyAds.instance.createNative(
          adNetwork: AdNetwork.admob,
          factoryId: 'nativeFull',
          adId: MyAdIdName.nativeOnboardFull2Ad.getId,
          height: Get.height,
        );
        final originalLoaded = fullScreenAdInstance2?.onAdLoaded;
        fullScreenAdInstance2?.onAdLoaded = (adNetwork, adUnitType, data) {
          originalLoaded?.call(adNetwork, adUnitType, data);
          canRenderFullScreenAd2.value = true;
          isDisplayingFullScreenAd2.value = true;
          update();
        };
        fullScreenAdInstance2?.load();
      }
    }

    _onboardAdEventSub = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitId == MyAdIdName.nativeOnboard1Ad.getId) {
        if (event.type == AdEventType.adLoaded || event.type == AdEventType.adFailedToLoad) {
          _heroSlide1AdGraceTimer?.cancel();
          _heroSlide1AdGraceTimer = Timer(const Duration(milliseconds: 500), () {
            if (!isClosed) {
              isHeroSlide1AdLoading.value = false;
              _heroSlide1AdTimeout?.cancel();
              update();
            }
          });
        }
      } else if (event.adUnitId == MyAdIdName.nativeOnboard3Ad.getId) {
        if (event.type == AdEventType.adLoaded || event.type == AdEventType.adFailedToLoad) {
          _heroSlide3AdGraceTimer?.cancel();
          _heroSlide3AdGraceTimer = Timer(const Duration(milliseconds: 500), () {
            if (!isClosed) {
              isHeroSlide3AdLoading.value = false;
              _heroSlide3AdTimeout?.cancel();
              update();
            }
          });
        }
      } else if (event.adUnitId == MyAdIdName.nativeOnboardFull1Ad.getId) {
        if (event.type == AdEventType.adLoaded) {
          canRenderFullScreenAd1.value = true;
          isDisplayingFullScreenAd1.value = true;
          update();
        }
      } else if (event.adUnitId == MyAdIdName.nativeOnboardFull2Ad.getId) {
        if (event.type == AdEventType.adLoaded) {
          canRenderFullScreenAd2.value = true;
          isDisplayingFullScreenAd2.value = true;
          update();
        }
      }
    });
  }

  void reloadAds() => initializeOnboardingAds();

  List<OnboardStep> buildOnboardingSequence() {
    final bool showAd1 = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_onboarding_1);
    final bool showAd3 = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_onboarding_3);

    final List<OnboardStep> steps = [];

    // Intro 1
    steps.add(OnboardStep(
      title: "Discover Your AI Soulmate".tr,
      desc: "Find your ideal match and stay connected with someone who is always there for you".tr,
      image: "assets/png/onboard1.webp",
      adId: showAd1 ? MyAdIdName.nativeOnboard1Ad.getId : "",
      factoryId: showAd1 ? "nativeMedia" : "",
      fit: BoxFit.cover,
    ));

    // Full Ad 1 (inserted if loaded/showable, not premium, and not organic) - between 1 & 2
    if (!AppSetting.isPremiumUser.value &&
        !AdsService.isOrganic.value &&
        canRenderFullScreenAd1.value &&
        fullScreenAdInstance1 != null) {
      steps.add(OnboardStep(
        fullAd: fullScreenAdInstance1,
      ));
    }

    // Intro 2
    steps.add(OnboardStep(
      title: "Share Your Deepest Thoughts".tr,
      desc: "Experience endless, private chats with a partner who truly gets you".tr,
      image: "assets/png/onboard2.webp",
      fit: BoxFit.cover,
    ));

    // Intro 3
    steps.add(OnboardStep(
      title: "Design Your Dream Partner".tr,
      desc: "Tailor her personality, looks, and energy to perfectly match your desires".tr,
      image: "assets/png/onboard3.webp",
      fit: BoxFit.cover,
    ));

    // Full Ad 2 (inserted if loaded/showable, not premium, and not organic) - between 3 & 4
    if (!AppSetting.isPremiumUser.value &&
        !AdsService.isOrganic.value &&
        canRenderFullScreenAd2.value &&
        fullScreenAdInstance2 != null) {
      steps.add(OnboardStep(
        fullAd: fullScreenAdInstance2,
      ));
    }

    // Intro 4
    steps.add(OnboardStep(
      title: "She is Waiting for You".tr,
      desc: "Jump in, say hello, and spark a meaningful connection today".tr,
      image: "assets/png/onboard4.webp",
      adId: showAd3 ? MyAdIdName.nativeOnboard3Ad.getId : "",
      factoryId: showAd3 ? "nativeMedia" : "",
      fit: BoxFit.cover,
    ));

    return steps;
  }

  List<OnboardStep> getSteps() => buildOnboardingSequence();

  int resolveTrueContentIndex(int index, List<OnboardStep> steps) {
    int introCount = 0;
    for (int i = 0; i <= index && i < steps.length; i++) {
      if (steps[i].fullAd == null) {
        introCount++;
      }
    }
    return (introCount - 1).clamp(0, 3);
  }

  int getIntroIndex(int index, List<OnboardStep> steps) =>
      resolveTrueContentIndex(index, steps);

  void handleSlideTransition(int value) {
    activeSlideIndex.value = value;

    final steps = buildOnboardingSequence();
    if (value >= 0 && value < steps.length) {
      final step = steps[value];
      if (step.fullAd != null) {
        isSkipAdButtonRevealed.value = false;
        _revealSkipCountdownTimer?.cancel();
        _revealSkipCountdownTimer = Timer(const Duration(seconds: 3), () {
          isSkipAdButtonRevealed.value = true;
        });
      } else {
        isSkipAdButtonRevealed.value = false;
      }

      if (step.title == "Your AI Companion Awaits".tr) {
        final String keyOnboard3 = FirebaseRemoteConfigService.native_onboarding_3;
        final bool showAd3 = FirebaseRemoteConfigService.getBoolConfigByKey(keyOnboard3);
        if (showAd3 && !AppSetting.isPremiumUser.value) {
          final ad = EasyAds.instance.getCachedNativeAd(MyAdIdName.nativeOnboard3Ad);
          final isAdLoaded = ad != null && ad.isAdLoaded;

          if (isAdLoaded) {
            isHeroSlide3AdLoading.value = true;
            _heroSlide3AdTimeout?.cancel();
            _heroSlide3AdGraceTimer?.cancel();
            _heroSlide3AdGraceTimer = Timer(const Duration(milliseconds: 500), () {
              isHeroSlide3AdLoading.value = false;
              update();
            });
          } else {
            isHeroSlide3AdLoading.value = true;
            _heroSlide3AdTimeout?.cancel();
            _heroSlide3AdTimeout = Timer(const Duration(seconds: 5), () {
              if (isHeroSlide3AdLoading.value) {
                isHeroSlide3AdLoading.value = false;
                update();
              }
            });
          }
        } else {
          isHeroSlide3AdLoading.value = false;
        }
      }
    }

    int introCount = 0;
    for (int i = 0; i <= value && i < steps.length; i++) {
      if (steps[i].fullAd == null) {
        introCount++;
      }
    }
    activeIntroStep.value = (introCount - 1).clamp(0, 3);

    update();
  }

  void onChangePage(int value) => handleSlideTransition(value);

  Future<void> _proceedToAppExperience() async {
    final bool showIap = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.show_activity_iap);
    final bool isOrganic = await AdsService.isOrganicAsync();

    if (showIap && !AppSetting.isPremiumUser.value) {
      if (!isOrganic &&
          FirebaseRemoteConfigService.getBoolConfigByKey(
              FirebaseRemoteConfigService.native_full_click)) {
        Get.toWithController(
          controllerBuilder: () => AdsFullController(),
          page: () => AdsFullPage(),
        ).then((_) {
          Get.offAllWithController(
            controllerBuilder: () => Premium2Controller(),
            arguments: {"isFromSplash": true},
            page: () => Premium2Page(),
          );
        });
      } else {
        Get.offAllWithController(
          controllerBuilder: () => Premium2Controller(),
          arguments: {"isFromSplash": true},
          page: () => Premium2Page(),
        );
      }
    } else {
      Get.offAllNamed(
        AppRoutes.HOME,
        arguments: {"isFromSplash": true},
      );
    }
  }

  Future<void> handleContinuePress(List<OnboardStep> steps) async {
    if (activeSlideIndex.value < steps.length - 1) {
      activeSlideIndex.value++;
      slideDeckController.animateToPage(
        activeSlideIndex.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AppUtil.saveBool("isNoFirstOpenApp", true);
      final bool isOrganic = await AdsService.isOrganicAsync();
      final bool showInterOb = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.inter_ob,
      );

      if (!isOrganic && showInterOb) {
        AppSetting.showInterstitialAd(
          Get.context!,
          adId: MyAdIdName.interstitialOnboard.getId,
          remoteConfigKey: FirebaseRemoteConfigService.inter_ob,
          checkInterval: false,
          adDismissed: () {
            _proceedToAppExperience();
          },
          onFailed: () {
            _proceedToAppExperience();
          },
        );
      } else {
        _proceedToAppExperience();
      }
    }
    update();
  }

  void onSelectNext(List<OnboardStep> steps) => handleContinuePress(steps);

  String resolveActionButtonLabel(int introIndex) {
    if (introIndex == 3) {
      return "Get started".tr;
    } else {
      return "Next".tr;
    }
  }

  String getTitleButton(int introIndex) => resolveActionButtonLabel(introIndex);
}
