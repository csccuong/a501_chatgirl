import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../utils/app_setting.dart';
import 'onboard_controller.dart';

class OnboardPage extends GetView<OnboardController> {
  const OnboardPage({super.key});

  @override
  OnboardController get controller => Get.isRegistered<OnboardController>()
      ? Get.find<OnboardController>()
      : Get.put(OnboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: GetBuilder<OnboardController>(
        builder: (_) {
          final steps = controller.buildOnboardingSequence();
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: controller.slideDeckController,
                    itemCount: steps.length,
                    onPageChanged: (index) {
                      controller.handleSlideTransition(index);
                    },
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      if (step.fullAd != null) {
                        return _renderFullscreenAdSlide(step);
                      } else {
                        return _renderOnboardContentSlide(step, index, steps);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _renderFullscreenAdSlide(OnboardStep step) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: step.fullAd!.show(),
          ),
          Positioned(
            right: 20,
            top: 30,
            child: Obx(() => controller.isSkipAdButtonRevealed.value
                ? GestureDetector(
                    onTap: () {
                      final steps = controller.buildOnboardingSequence();
                      controller.handleContinuePress(steps);
                    },
                    child: SafeArea(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox()),
          ),
        ],
      ),
    );
  }

  Widget _renderOnboardContentSlide(OnboardStep step, int index, List<OnboardStep> steps) {
    final int introIndex = controller.resolveTrueContentIndex(index, steps);
    final bool hasAd = step.adId.isNotEmpty && !AppSetting.isPremiumUser.value;

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  step.image,
                  fit: step.fit,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: hasAd ? 340 : 180), // Dynamic spacer
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ).marginSymmetric(horizontal: 20),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    step.desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ).marginSymmetric(horizontal: 20),
                ),
                const SizedBox(height: 20),
                if (hasAd) ...[
                  // Row with centered dots and text button on right for pages with ads (Onboard 1, 4)
                  Container(
                    height: 40,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 100,
                        ),
                        Obx(() => DotsIndicator(
                              dotsCount: controller.totalSlidesDeck.value,
                              position: controller.activeIntroStep.value.toDouble(),
                              decorator: DotsDecorator(
                                color: const Color(0xFF2A3649),
                                activeColor: AppColors.main,
                                size: const Size(8, 8),
                                activeSize: const Size(8, 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                spacing: const EdgeInsets.only(right: 8),
                              ),
                            )),
                        _renderTextLinkContinue(steps, introIndex),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Native Ad pinned firmly at bottom - completely non-scrollable
                  EasyNativeAd(
                    key: ValueKey('nativeOnboard_${step.adId}'),
                    factoryId: step.factoryId,
                    adId: step.adId,
                    height: AdDimen.mediumNativeHeight,
                  ),
                ] else ...[
                  // Centered dots and big button for pages without ads (Onboard 2, 3)
                  Container(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 20,
                      child: Obx(() => DotsIndicator(
                            dotsCount: controller.totalSlidesDeck.value,
                            position: controller.activeIntroStep.value.toDouble(),
                            decorator: DotsDecorator(
                              color: const Color(0xFF2A3649),
                              activeColor: AppColors.main,
                              size: const Size(8, 8),
                              activeSize: const Size(8, 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              spacing: const EdgeInsets.only(right: 8),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _renderCapsuleButtonContinue(steps, introIndex),
                  const SizedBox(height: 15),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderTextLinkContinue(List<OnboardStep> steps, int introIndex) {
    return Obx(() {
      final isAdLoading = (introIndex == 0 && controller.isHeroSlide1AdLoading.value) ||
          (introIndex == 3 && controller.isHeroSlide3AdLoading.value);

      if (isAdLoading) {
        return Container(
          width: 100,
          alignment: Alignment.centerRight,
          height: 40,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.main),
              ),
            ),
          ),
        );
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller.handleContinuePress(steps);
        },
        child: Container(
          width: 100,
          alignment: Alignment.centerRight,
          height: 40,
          child: Text(
            controller.resolveActionButtonLabel(introIndex),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.main,
            ),
          ),
        ),
      );
    });
  }

  Widget _renderCapsuleButtonContinue(List<OnboardStep> steps, int introIndex) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.handleContinuePress(steps);
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          gradient: AppColors.primaryGradient,
        ),
        height: 50,
        child: Center(
          child: Text(
            controller.resolveActionButtonLabel(introIndex),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
