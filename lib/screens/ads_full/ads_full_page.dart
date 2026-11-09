import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/ads_full/ads_full_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';

class AdsFullPage extends GetView<AdsFullController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: EasyNativeAd(
                key: const ValueKey('nativeFull'),
                factoryId: MyAdIdName.nativeFull,
                adId: MyAdIdName.nativeFull.getId,
                height: Get.height,
                onLoaded: () {
                  controller.shouldShowNativeFullAd.value = true;
                },
                onFailedToLoad: () {
                  controller.closeAdFull();
                },
              ),
            ),
            Positioned(
              right: 20,
              top: 50,
              child: Obx(() => controller.shouldShowCloseNativeFull.value
                  ? GestureDetector(
                onTap: controller.closeAdFull,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ) : const SizedBox()),
            )
          ],
        ),
      ),
    );
  }
}