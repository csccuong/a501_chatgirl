import 'dart:io';

import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/helper/firebase_remote_config_service.dart';
import 'package:cscmobi_app/helper/reward_ads_claim_helper.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:cscmobi_app/screens/language/language_controller.dart';
import 'package:cscmobi_app/screens/premium/premium_controller.dart';
import 'package:cscmobi_app/screens/premium/premium_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/app_util.dart';
import '../../core/values/app_colors.dart';
import '../../core/values/constants.dart';
import '../../models/user_model.dart';
import '../../api_rest/api_repository.dart';
import '../language/language_page.dart';
import '../popup_rating/popup_rating_controller.dart';
import '../popup_rating/popup_rating_page.dart';
import '../premium2/premium2_controller.dart';
import '../premium2/premium2_page.dart';

class ProfileController extends BaseController {
  final ApiRepository _apiRepo = ApiRepository();
  var currentUser = Rx<UserModel?>(null);
  var checkinStatusData = Rx<Map<String, dynamic>?>(null);
  var isLoading = false.obs;
  var appVersion = ''.obs;
  var countTapAbout = 0;

  @override
  void onInit() {
    super.onInit();
    _handleInitialLogin();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    appVersion.value = await AppUtil().getAppVersion();
  }

  Future<void> _handleInitialLogin() async {
    isLoading.value = true;
    try {
      await _apiRepo.loginWeifu(firebaseToken: null);
      await fetchProfile();
    } catch (e) {
      print("Error in initial guest login: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      int? localGems = currentUser.value?.gems;
      bool isReviewerEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.enable_reviewer_add_gems,
      );

      var data = await _apiRepo.getProfileWeifu();
      if (data != null) {
        if (data.containsKey('user') && data.containsKey('checkin_status')) {
          currentUser.value = UserModel.fromJson(data['user']);
          checkinStatusData.value = data['checkin_status'];
        } else {
          currentUser.value = UserModel.fromJson(data);
        }

        if (isReviewerEnabled && currentUser.value != null) {
          if (localGems != null && localGems > 0) {
            currentUser.value!.gems = localGems;
          } else {
            int extraGems = AppUtil.getInt('reviewer_extra_gems');
            if (extraGems > 0) {
              currentUser.value!.gems = (currentUser.value!.gems ?? 0) + extraGems;
            }
          }
        } else {
          // Khi tắt Remote Config, lập tức xóa số Gem test đã lưu trong máy
          AppUtil.saveInt('reviewer_extra_gems', 0);
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool get isReviewerAddGemsEnabled =>
      FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.enable_reviewer_add_gems,
      );

  void onTapCopyUserId() {
    final id = currentUser.value?.deviceId ?? currentUser.value?.id ?? '';
    if (id.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: id));
      AppUtil.showNormalToast("Copied User ID".tr);
    }
  }

  void onAddGemsForReviewer() {
    bool isEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.enable_reviewer_add_gems,
    );
    if (!isEnabled) return;

    final TextEditingController passController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Enter Password".tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: passController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter key...".tr,
            hintStyle: const TextStyle(color: AppColors.textSubColor),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.textSubColor),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.main),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel".tr, style: const TextStyle(color: AppColors.textSubColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (passController.text.trim() == "google") {
                Get.back();
                if (currentUser.value != null) {
                  int currentExtra = AppUtil.getInt('reviewer_extra_gems');
                  int newExtra = currentExtra + 10000;
                  AppUtil.saveInt('reviewer_extra_gems', newExtra);

                  currentUser.value!.gems = (currentUser.value!.gems ?? 0) + 10000;
                  currentUser.refresh();
                  AppUtil.showNormalToast("Added +10,000 Gems successfully!".tr);
                }
              } else {
                AppUtil.showNormalToast("Incorrect password!".tr);
              }
            },
            child: Text("Confirm".tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void onWalletDetailTap() {
    Get.toWithController(
      controllerBuilder: () => PremiumController(),
      page: () => const PremiumPage(),
      routeName: AppRoutes.PREMIUM,
    );
  }

  void onTopUpTap() {
    Get.toWithController(
      controllerBuilder: () => PremiumController(),
      page: () => const PremiumPage(),
      routeName: AppRoutes.PREMIUM,
    );
  }

  void onVipBannerTap() {
    Get.toWithController(
      controllerBuilder: () => Premium2Controller(),
      page: () => Premium2Page(),
      arguments: {"isFromSplash": false},
      routeName: AppRoutes.PREMIUM,
    );
  }

  void onRewardsTap() {
    RewardAdsClaimHelper.runClaimFlow(apiRepository: _apiRepo);
  }

  void onStoreTap() {
    Get.toWithController(
      controllerBuilder: () => PremiumController(),
      page: () => const PremiumPage(),
      routeName: AppRoutes.PREMIUM,
    );
  }

  void onLanguageTap() {
    Get.toWithController(
        controllerBuilder: () => LanguageController(),
        page: () => LanguagePage());
  }

  void onRateAppTap() async {
    var result = await Get.dialog(
      GetBuilder<PopupRatingController>(
        init:
            PopupRatingController(), // Optional: Initialize controller here if needed
        builder: (controller) {
          return PopupRatingPage();
        },
      ),
      arguments: {},
      useSafeArea: false,
    );
    if (result != null) {
      AppUtil.showNormalToast("Thank you for your review".tr);
    }
  }

  void onSettingsTap() {}

  void onTermsOfServiceTap() async {
    final Uri url = Uri.parse(Constants.termOfUser);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void onPrivacyPolicyTap() async {
    final Uri url = Uri.parse(Constants.privacy);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void onVersionTap() async {
    countTapAbout += 1;
    if (countTapAbout == 5) {
      await Clipboard.setData(
          ClipboardData(text: await AppUtil().getDeviceId()));
      countTapAbout = 0;
      AppUtil.showNormalToast("Device Id copied");
    } else {
      var appVersion = await AppUtil().getAppVersion();
      var androidAppVersion = FirebaseRemoteConfigService.getStringConfigByKey(
          FirebaseRemoteConfigService.android_app_version);
      if (androidAppVersion.compareTo(appVersion) >= 0) {
        final url = Uri.parse(
          Platform.isAndroid
              ? "https://play.google.com/store/apps/details?id=com.aichat.chatbotai.lovechat"
              : "",
        );
        launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        AppUtil.showNormalToast("Latest version".tr);
      }
    }
  }
}
