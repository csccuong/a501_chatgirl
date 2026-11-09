import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../helper/reward_ads_claim_helper.dart';

class PopupNotEnoughGemsController extends GetxController {
  final String title;
  final String message;
  final VoidCallback? onWatchAdSuccess;
  final VoidCallback? onGoPremium;

  PopupNotEnoughGemsController({
    required this.title,
    required this.message,
    this.onWatchAdSuccess,
    this.onGoPremium,
  });

  void onSelectGoPremium() {
    Get.back();
    onGoPremium?.call();
  }

  void onSelectWatchAds() {
    RewardAdsClaimHelper.runClaimFlow(
      onWatchAdSuccess: () {
        Get.back();
        onWatchAdSuccess?.call();
      },
    );
  }

  void onCloseButton() {
    Get.back();
  }
}
