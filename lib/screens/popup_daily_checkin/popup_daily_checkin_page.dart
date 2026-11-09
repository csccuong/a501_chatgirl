import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'popup_daily_checkin_controller.dart';
import '../../core/values/app_colors.dart';
import '../profile/profile_controller.dart';

class PopupDailyCheckinPage extends GetView<PopupDailyCheckinController> {
  const PopupDailyCheckinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    
    void scrollToNextDay() {
      if (!scrollController.hasClients) return;
      final streak = controller.currentStreak.value;
      if (streak < 3) return; // No need to scroll for first few days
      // Each card is ~60px wide (52-58 + 8 margin). Calculate offset to center the next day.
      const cardWidth = 60.0;
      final nextDay = streak + 1; // 1-indexed, next card to claim
      // Scroll so that the next-day card appears near the center of the viewport
      final viewportWidth = scrollController.position.viewportDimension;
      final targetOffset = ((nextDay - 1) * cardWidth) - (viewportWidth / 2) + (cardWidth / 2);
      final clampedOffset = targetOffset.clamp(0.0, scrollController.position.maxScrollExtent);
      scrollController.jumpTo(clampedOffset);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToNextDay();
    });

    // Re-scroll when streak updates from API
    ever(controller.currentStreak, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToNextDay();
      });
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.35),
                blurRadius: 30,
                spreadRadius: 4,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Hero Banner Section ───
              _buildHeroBanner(),

              // ─── Bottom Content Section ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Obx(() {
                  final streak = controller.currentStreak.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Streak text
                      RichText(
                        text: TextSpan(
                          text: "Checked in for ".tr,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "$streak",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: " day".tr),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Days Row
                      SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(7, (index) {
                            final day = index + 1;
                            final isClaimed = day <= streak;
                            final isNextToClaim = day == streak + 1;
                            final reward = controller.getRewardForDay(day);
                            return _buildDayCard(day, reward, isClaimed, isNextToClaim);
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Check In Button
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ElevatedButton(
                          onPressed: controller.isClaiming.value ? null : () => controller.onCheckIn(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          child: controller.isClaiming.value
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  "Check in".tr,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero banner with background image, title, subtitle, balance badge, and close button
  Widget _buildHeroBanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/png/bg_daily_checkin.png',
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),

          // Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Text content on the left
          Positioned(
            left: 20,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Rewards".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Check in every day and get\namazing rewards! 💎".tr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                // Balance badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Balance:".tr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset('assets/png/gem.png', width: 20, height: 20),
                      const SizedBox(width: 4),
                      GetBuilder<ProfileController>(
                        builder: (profileCtrl) {
                          final gems = profileCtrl.currentUser.value?.gems ?? 0;
                          return Text(
                            "$gems",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Close button (top right)
          Positioned(
            right: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(int day, int reward, bool isClaimed, bool isNextToClaim) {
    Color bgColor = const Color(0xFF2C2C2C);
    Color borderColor = Colors.transparent;

    if (isClaimed) {
      bgColor = AppColors.main;
    } else if (isNextToClaim) {
      borderColor = AppColors.main;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: day == 7 ? 58 : 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Day $day".tr,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 6),
                day == 7
                    ? Image.asset('assets/png/gift.png', height: 20, errorBuilder: (c, e, s) => const Icon(Icons.card_giftcard, color: Colors.amber, size: 20))
                    : Image.asset('assets/png/gem.png', height: 20),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    day == 7 ? "Mystery\ngift".tr : "+$reward",
                    style: TextStyle(
                      color: day == 7 ? Colors.white70 : Colors.white,
                      fontSize: day == 7 ? 9.5 : 13,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          if (isClaimed)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
