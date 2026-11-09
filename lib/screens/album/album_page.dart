import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../utils/app_setting.dart';
import 'album_controller.dart';

class AlbumPage extends GetView<AlbumController> {
  const AlbumPage({Key? key}) : super(key: key);

  @override
  AlbumController get controller =>
      Get.isRegistered<AlbumController>()
          ? Get.find<AlbumController>()
          : Get.put(AlbumController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1016),
      appBar: AppBar(
        title: Text("Album".tr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.totalItems == 0) {
          return Center(
            child: Text(
              "No images yet".tr,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: controller.totalItems,
          itemBuilder: (context, index) {
            final url = controller.getUrlForIndex(index);
            return GestureDetector(
              onTap: () => controller.openImageAtIndex(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white.withOpacity(0.05),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.white.withOpacity(0.05),
                    child: const Icon(Icons.error, color: Colors.white24),
                  ),
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
          return const SizedBox.shrink();
        }
        if (!FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.banner_all)) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          top: false,
          child: EasyBannerAd(
            adNetwork: AdNetwork.admob,
            adId: MyAdIdName.bannerAll.getId,
            isCollapsible: true,
          ),
        );
      }),
    );
  }
}
