import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/app_util.dart';

class FullScreenImageController extends BaseController {
  String imageUrl = '';
  var canDismiss = true.obs;
  var selectedReportReason = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is String) {
      imageUrl = Get.arguments as String;
    }
  }

  void downloadImage() {
    AppUtil.showNormalToast("Downloading image...".tr);
  }

  void shareImage() {
    if (imageUrl.isNotEmpty) {
      Share.share("$imageUrl");
    }
  }

  void onScaleStateChanged(PhotoViewScaleState state) {
    canDismiss.value = state == PhotoViewScaleState.initial;
  }

  void reportImage() {
    selectedReportReason.value = 0; // reset
    final reasons = [
      "Inappropriate/Explicit content.".tr,
      "Violence/Gore.".tr,
      "Copyright infringement/Misinformation.".tr,
      "Other.".tr
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF161821),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Report content".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Help us understand what's wrong with this character or image".tr,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...List.generate(reasons.length, (index) {
              return Obx(() {
                final isSelected = selectedReportReason.value == index;
                return GestureDetector(
                  onTap: () {
                    selectedReportReason.value = index;
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE2F063).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE2F063) : Colors.white10,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reasons[index],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFE2F063) : Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFE2F063),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              });
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Get.back();
                AppUtil.showNormalToast("Report submitted successfully.".tr);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2F063),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                "Submit".tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
