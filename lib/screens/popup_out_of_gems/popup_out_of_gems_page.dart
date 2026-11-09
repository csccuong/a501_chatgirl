import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';
import 'popup_out_of_gems_controller.dart';

class PopupOutOfGemsPage extends GetView<PopupOutOfGemsController> {
  const PopupOutOfGemsPage({super.key});

  @override
  PopupOutOfGemsController get controller => Get.isRegistered<PopupOutOfGemsController>() ? Get.find<PopupOutOfGemsController>() : Get.put(PopupOutOfGemsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
              // padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                // color: const Color(0xFF101828), // matching app theme color from image
                borderRadius: BorderRadius.circular(21),
                image: const DecorationImage(
                  image: AssetImage('assets/png/bg_popup_outofgems.png'),
                  fit: BoxFit.fill,
                ),
                // border: Border.all(color: AppColors.hexToColor("#FF4ABC"), width: 2)
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF29DBFD),
                    Color.fromRGBO(3, 130, 199, 0.5),
                  ],
                ),
                // borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => controller.onCloseButton(),
                          child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1)),
                              child: const Icon(Icons.close, color: Colors.white, size: 18)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "You are all out of ".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: "gems!".tr,
                            style: const TextStyle(
                              color: AppColors.main, // Pink text
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Get more gems to keep conversation going and\ncontinue the fun".tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/png/gem.png', width: 24, height: 24),
                          const SizedBox(width: 8),
                          Obx(() => Text(
                            '${controller.profileController.currentUser.value?.gems ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Gems left'.tr,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Left Card: Watch an ad
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                Image.asset('assets/png/watch_video.png', height: 60),
                                const SizedBox(height: 8),
                                Text(
                                  "Watch an ad".tr,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "+8 Gems".tr,
                                  style: const TextStyle(color: AppColors.main, fontSize: 12, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: controller.onWatchAd,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: Obx(() => Text(
                                      "Watch ads".tr + " (${controller.adsWatchedToday.value}/${controller.maxAdsToday.value})",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right Card: Get more gems
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.main.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                Image.asset('assets/png/getmoregems.png', height: 60),
                                const SizedBox(height: 8),
                                Text(
                                  "Get more gems".tr,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Buy gems in Shop".tr,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: controller.onGoToShop,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Go to Shop".tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: controller.onGoToShop,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/png/king.png', width: 16, height: 16),
                          const SizedBox(width: 6),
                          RichText(
                            text: TextSpan(
                              text: "Go Premium".tr,
                              style: const TextStyle(color: AppColors.main, fontWeight: FontWeight.w600, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: " - Unlimited Chats".tr,
                                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/png/diamond.png',
                  width: 210,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
