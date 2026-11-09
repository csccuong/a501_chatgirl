import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/setting/setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_setting.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';

class SettingPage extends GetView<SettingController> {
  @override
  SettingController get controller =>
      Get.isRegistered<SettingController>()
          ? Get.find<SettingController>()
          : Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  buildNavigation(),
                  Expanded(
                    child: buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () => controller.onSelectBack());
  }

  buildBannerPremium() {
    return Container(
      width: double.infinity,
      height: 132,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundItemColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20,right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You’re Premium 🎉".tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor
                    ),
                  ),
                  Text(
                    "Enjoy all features with no ads.".tr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor
                    ),
                  )
                ],
              ),
            ),
          ),
          Image.asset(
            "assets/png/setting_thumb.png",
            width: 169,
            height: 100,
          )
        ],
      ),
    );
  }

  buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => AppSetting.isPremiumUser.value
            ? buildBannerPremium() : const SizedBox()),
            GestureDetector(
              onTap: () {
                controller.onSelectLanguage();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                margin: EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 1, color: Colors.white.withOpacity(0.1))
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_language.png",
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Language".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectShareApp();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: Colors.white.withOpacity(0.1))
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_share.png",
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Share app".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectRateApp();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: Colors.white.withOpacity(0.1))
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_rate_app.png",
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Rate app".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectPrivacy();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: Colors.white.withOpacity(0.1))
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/png/setting_policy.png",
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Privacy policy".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                controller.onSelectVersion();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundItemColor,
                  borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1, color: Colors.white.withOpacity(0.1))
                ),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/png/setting_version.png",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          "Version".tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor),
                        )
                      ],
                    ),
                    Obx(() => Text(
                          controller.appVersion.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        )),
                  ],
                ),
              ),
            ),
            // Obx(() {
            //   if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
            //     return const SizedBox();
            //   }
            //   return Container(
            //     margin: const EdgeInsets.only(top: 10),
            //     child: EasyNativeAd(
            //       key: const ValueKey('nativeAllAd'),
            //       factoryId: 'nativeMediaSmall',
            //       adId: MyAdIdName.nativeAllAd.getId,
            //       height: 120,
            //     ),
            //   );
            // }),
          ],
        ),
      ),
    );
  }

  buildNavigation() {
    return Container(
      height: 64,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Settings".tr,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                controller.onSelectBack();
              },
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.whiteText,
                        size: 25,
                      ),
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
