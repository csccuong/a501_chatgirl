import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../Utils/app_setting.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import 'full_screen_image_controller.dart';

class FullScreenImagePage extends GetView<FullScreenImageController> {
  const FullScreenImagePage({Key? key}) : super(key: key);

  @override
  FullScreenImageController get controller =>
      Get.isRegistered<FullScreenImageController>()
          ? Get.find<FullScreenImageController>()
          : Get.put(FullScreenImageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable Image
          Center(
            child: Obx(() => Dismissible(
              key: const Key('photo_view_dismissible'),
              direction: controller.canDismiss.value
                  ? DismissDirection.vertical
                  : DismissDirection.none,
              onDismissed: (_) => Get.back(),
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(controller.imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4.0,
                scaleStateChangedCallback: controller.onScaleStateChanged,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
            )),
          ),

          // Action Buttons Top-Left
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
          
          // Action Buttons Top-Right
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Row(
              children: [
                _buildActionButton(Icons.download, controller.downloadImage),
                const SizedBox(width: 12),
                _buildActionButton(Icons.share, controller.shareImage),
                const SizedBox(width: 12),
                _buildActionButton(Icons.report, controller.reportImage),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 8),
              child: Obx(() {
                if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
                  return const SizedBox.shrink();
                }
                if (!FirebaseRemoteConfigService.getBoolConfigByKey(
                    FirebaseRemoteConfigService.banner_all)) {
                  return const SizedBox.shrink();
                }
                return EasyBannerAd(
                  adNetwork: AdNetwork.admob,
                  adId: MyAdIdName.bannerAll.getId,
                  isCollapsible: true,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
