import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../core/router/app_route_observer.dart';
import '../../core/values/app_colors.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../utils/app_setting.dart';
import 'splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashController controller = Get.find<SplashController>();

  @override
  void initState() {
    super.initState();
    // Immediately log screen view and event on widget mount (mirroring dxx_shortdrama)
    AppRouteObserver.logScreen('SplashScreen');
  }

  @override
  Widget build(BuildContext context) {
    final bool showBannerSplash = (Platform.isAndroid || Platform.isIOS) &&
        !AppSetting.isPremiumUser.value &&
        !AppSetting.isRemoveAds.value &&
        FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.banner_splash,
        );

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/png/splash_background.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/png/splash_thumb.png",
                            width: 121,
                            height: 121,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Lover AI: AI Character Chat",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 200),
                        ],
                      )),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SafeArea(
                      top: false,
                      bottom: !showBannerSplash,
                      child: Column(
                        children: [
                          Text(
                            "This action can contain advertising".tr,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(() => Container(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: LinearProgressIndicator(
                                  value: controller.startupLoadingRatio.value,
                                  color: AppColors.main,
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(10),
                                  backgroundColor: const Color(0xFF1E2633),
                                ),
                              ))
                        ],
                      ),
                    ),
                    if (showBannerSplash) ...[
                      const SizedBox(height: 12),
                      SafeArea(
                        top: false,
                        child: EasyBannerAd(
                          adId: MyAdIdName.bannerSplash.getId,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else
                      const SizedBox(
                        height: 30,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
