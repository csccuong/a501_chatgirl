import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:get/get.dart';
import '../../helper/reward_ads_claim_helper.dart';

class PopupCheckinSuccessController extends BaseController {
  final int rewardGems;
  var isClaimingAd = false.obs;

  PopupCheckinSuccessController({required this.rewardGems});

  void onWatchAds() {
    if (isClaimingAd.value) return;
    isClaimingAd.value = true;
    RewardAdsClaimHelper.runClaimFlow(
      onWatchAdSuccess: () {
        isClaimingAd.value = false;
        Get.back(); // Close this popup after success
      },
    ).then((_) {
      isClaimingAd.value = false;
    });
  }
}
