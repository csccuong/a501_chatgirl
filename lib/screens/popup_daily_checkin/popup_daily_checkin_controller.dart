import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:get/get.dart';
import '../../api_rest/api_repository.dart';
import '../../core/utils/app_util.dart';
import '../../utils/app_setting.dart';
import '../profile/profile_controller.dart';
import '../popup_checkin_success/popup_checkin_success_controller.dart';
import '../popup_checkin_success/popup_checkin_success_page.dart';

class PopupDailyCheckinController extends BaseController {
  final ApiRepository _apiRepo = ApiRepository();
  final AppSetting _appSetting = AppSetting();

  var currentStreak = 0.obs;
  var isClaiming = false.obs;
  var rewards = <int>[0, 5, 5, 8, 5, 5, 8, 10].obs; // Index 1-7
  var canClaimToday = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    // Keep local logic as fallback
    final lastCheckin = _appSetting.getLastCheckinDate();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

    int savedStreak = _appSetting.getCheckinStreak();

    if (lastCheckin.isNotEmpty && lastCheckin != today && lastCheckin != yesterday) {
      savedStreak = 0;
      _appSetting.saveCheckinStreak(0);
    }
    
    if (savedStreak >= 7 && lastCheckin != today) {
      savedStreak = 0;
      _appSetting.saveCheckinStreak(0);
    }

    currentStreak.value = savedStreak;

    // Check if we already have it in ProfileController
    Map<String, dynamic>? res;
    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      if (profileCtrl.checkinStatusData.value != null) {
        res = profileCtrl.checkinStatusData.value;
      }
    }

    // Fetch from API to sync if not available
    if (res == null) {
      res = await _apiRepo.dailyCheckinStatusWeifu();
    }

    if (res != null) {
      currentStreak.value = res['current_streak'] ?? 0;
      canClaimToday.value = res['can_claim_today'] ?? false;
      if (res['rewards'] != null && res['rewards'] is List) {
        for (var item in res['rewards']) {
          int d = item['day'];
          int g = item['gems'];
          if (d >= 1 && d <= 7) {
            rewards[d] = g;
          }
        }
      }
    }
  }

  Future<void> onCheckIn() async {
    if (isClaiming.value) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (!canClaimToday.value || _appSetting.getLastCheckinDate() == today) {
      AppUtil.showNormalToast("You have already checked in today.".tr);
      return;
    }

    isClaiming.value = true;
    final targetDayIndex = currentStreak.value + 1; // 1 to 7

    try {
      final res = await _apiRepo.dailyCheckinWeifu(dayIndex: targetDayIndex);
      if (res != null && res['success'] == true) {
        final rewardGems = res['reward_gems'] ?? 0;
        
        // Update local streak
        _appSetting.saveCheckinStreak(targetDayIndex);
        _appSetting.saveLastCheckinDate(today);
        currentStreak.value = targetDayIndex;

        if (Get.isRegistered<ProfileController>()) {
          final profileCtrl = Get.find<ProfileController>();
          if (profileCtrl.currentUser.value != null) {
             profileCtrl.currentUser.value!.gems = res['remaining_gems'] ?? ((profileCtrl.currentUser.value!.gems ?? 0) + (rewardGems as num).toInt());
             profileCtrl.update();
          }
          await profileCtrl.fetchProfile();
        }

        AppUtil.showNormalToast("${'Checked in successfully!'.tr} +$rewardGems ${'Gems'.tr}\n${'Watch ads to earn more gems!'.tr}");
        Get.back(); // Close popup
        
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.put(PopupCheckinSuccessController(rewardGems: (rewardGems as num).toInt()));
          Get.dialog(
            const PopupCheckinSuccessPage(),
            barrierDismissible: true,
            useSafeArea: false,
          ).then((_) {
            Get.delete<PopupCheckinSuccessController>();
          });
        });
      } else {
        AppUtil.showToastError("Check in failed. Please try again later.".tr);
      }
    } catch (e) {
       AppUtil.showToastError("Check in failed. Please try again later.".tr);
    } finally {
      isClaiming.value = false;
    }
  }

  int getRewardForDay(int day) {
    if (day >= 1 && day <= 7) {
      return rewards[day];
    }
    return 5;
  }
}
