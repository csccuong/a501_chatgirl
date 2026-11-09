import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../core/values/app_colors.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../utils/app_setting.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'language_controller.dart';

class LanguagePage extends GetView<LanguageController> {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  LanguageController get controller =>
      Get.isRegistered<LanguageController>()
          ? Get.find<LanguageController>()
          : Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildLanguageTopBar(),
                    Flexible(
                      flex: 1,
                      child: _buildLanguageOptionList(),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(() {
                if (AppSetting.isPremiumUser.value ||
                    AppSetting.isRemoveAds.value ||
                    !controller.isFirstLaunchFlow.value) {
                  return const SizedBox();
                }

                final bool showInitial = controller.isPrimaryLangAdEnabled;
                final bool showAlt = controller.isSecondaryLangAdEnabled;

                if (!showInitial && !showAlt) {
                  return const SizedBox();
                }

                if (controller.isSecondaryAdActive.value && showAlt) {
                  return EasyNativeAdSequential(
                    key: const ValueKey('nativeLanguageClick'),
                    factoryId: 'nativeMedia2',
                    adId: MyAdIdName.nativeLanguageClick.getId,
                    cacheKey: MyAdIdName.nativeLanguageClick,
                    adIdHigh: MyAdIdName.nativeLanguageClickHigh.getId,
                    cacheKeyHigh: MyAdIdName.nativeLanguageClickHigh,
                    height: AdDimen.mediumNativeHeight,
                  );
                }

                if (showInitial) {
                  return EasyNativeAdSequential(
                    key: const ValueKey('nativeLanguage'),
                    factoryId: 'nativeMedia',
                    adId: MyAdIdName.nativeLanguage.getId,
                    cacheKey: MyAdIdName.nativeLanguage,
                    adIdHigh: MyAdIdName.nativeLanguageHigh.getId,
                    cacheKeyHigh: MyAdIdName.nativeLanguageHigh,
                    height: AdDimen.mediumNativeHeight,
                  );
                }

                return const SizedBox();
              }),
            ),
            Obx(() {
              if (!controller.isLanguageLoading.value) return const SizedBox();
              return Positioned.fill(
                child: Container(
                  color: const Color(0xFF131722).withValues(alpha: 0.8),
                  child: Center(
                    child: Lottie.asset(
                      'assets/json/loading.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOptionList() {
    return Obx(() {
      final bool hasAd = controller.isFirstLaunchFlow.value &&
          !AppSetting.isPremiumUser.value &&
          !AppSetting.isRemoveAds.value &&
          (controller.isPrimaryLangAdEnabled || controller.isSecondaryLangAdEnabled);

      return ListView.builder(
        itemCount: controller.availableLanguages.length,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: hasAd ? (AdDimen.mediumNativeHeight + 10) : 20,
          top: 20,
        ),
        itemBuilder: (context, index) {
          final lang = controller.availableLanguages[index];
          return GestureDetector(
            onTap: () {
              controller.selectLanguageOption(index);
            },
            child: Obx(() {
              final isSelected = controller.selectedLangPosition.value == index;
              return Container(
                height: 48,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.backgroundItemColor,
                  border: isSelected ? null : Border.all(color: const Color(0xFF222C3A), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          lang.pngAsset,
                          width: 40,
                          height: 30,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          lang.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.whiteText,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                    isSelected
                        ? Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: AppColors.white,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 1.5,
                                color: const Color(0xFF4B5565),
                              ),
                            ),
                          )
                  ],
                ),
              );
            }),
          );
        },
      );
    });
  }

  Widget _buildLanguageTopBar() {
    return SizedBox(
      height: 72,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Language".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Please select a language to continue.".tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteText.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isFirstLaunchFlow.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: 0,
              bottom: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  controller.navigateBack();
                },
                child: const AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.whiteText,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Obx(() => controller.selectedLangPosition.value != 100 &&
                  controller.canShowProceedButton.value
              ? Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      controller.applyLanguageAndContinue();
                    },
                    child: const SizedBox(
                      width: 80,
                      height: 36,
                      child: Center(
                        child: Icon(
                          Icons.done_all,
                          color: AppColors.main,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Obx(() => controller.selectedLangPosition.value != 100 &&
                  !controller.canShowProceedButton.value
              ? const Positioned(
                  right: 20,
                  bottom: 0,
                  top: 0,
                  child: Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.main,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink())
        ],
      ),
    );
  }
}
