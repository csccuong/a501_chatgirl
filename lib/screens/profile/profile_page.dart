import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/values/app_colors.dart';
import '../../utils/app_setting.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  static const Color _cardBgColor = Color(0xFF141923);
  static const Color _accentPink = Color(0xFF29DBFD);
  static const Color _subTextColor = Color(0xFF8E95AA);
  static const Color _chevronColor = Color(0xFF8E95AA);

  @override
  ProfileController get controller =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          final user = controller.currentUser.value;
          final String displayName = (user?.username?.isNotEmpty == true)
              ? user!.username!
              : "Guest_${user?.id?.substring(0, 6) ?? '586722'}";
          final String displayId = (user?.deviceId?.isNotEmpty == true)
              ? user!.deviceId!.substring(0, (user.deviceId!.length >= 8 ? 8 : user.deviceId!.length))
              : (user?.id?.substring(0, 8) ?? 'd54ff81c');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 110.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),

                // ─── 1. Header (User Info) ───
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                      backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(user.avatarUrl!)
                          : const AssetImage('assets/png/user.png') as ImageProvider,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: controller.onTapCopyUserId,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "ID: $displayId",
                                  style: const TextStyle(
                                    color: _subTextColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.copy_rounded,
                                  color: _subTextColor,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ─── 2. My Wallet Card ───
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top Row: My Wallet + Detail >
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "My Wallet".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: controller.onWalletDetailTap,
                            child: Row(
                              children: [
                                Text(
                                  "Detail".tr,
                                  style: const TextStyle(
                                    color: _chevronColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: _chevronColor,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bottom Row: Gem count + Top up button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Gem icon and amount
                          if (controller.isReviewerAddGemsEnabled)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: controller.onAddGemsForReviewer,
                              child: Row(
                                children: [
                                  Image.asset('assets/png/gem.png', width: 26, height: 26),
                                  const SizedBox(width: 10),
                                  Text(
                                    "${user?.gems ?? 0}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "+10k",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              children: [
                                Image.asset('assets/png/gem.png', width: 26, height: 26),
                                const SizedBox(width: 10),
                                Text(
                                  "${user?.gems ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                          // Top up button
                          GestureDetector(
                            onTap: controller.onTopUpTap,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(19),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Top up".tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ─── 3. Unlock VIP Banner (bg_unlock_vip.png) ───
                _buildVipBanner(isPremium: AppSetting.isPremiumUser.value),
                const SizedBox(height: 14),

                // ─── 4. Menu Items ───
                _buildMenuItem(
                  icon: Icons.workspace_premium_outlined,
                  title: "Rewards".tr,
                  hasBonusBadge: true,
                  onTap: controller.onRewardsTap,
                ),
                _buildMenuItem(
                  icon: Icons.storefront_outlined,
                  title: "Store".tr,
                  onTap: controller.onStoreTap,
                ),
                _buildMenuItem(
                  icon: Icons.language_rounded,
                  title: "Language".tr,
                  onTap: controller.onLanguageTap,
                ),
                _buildMenuItem(
                  icon: Icons.thumb_up_alt_outlined,
                  title: "Rate App".tr,
                  onTap: controller.onRateAppTap,
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: "Terms of Service".tr,
                  onTap: controller.onTermsOfServiceTap,
                ),
                _buildMenuItem(
                  icon: Icons.shield_outlined,
                  title: "Privacy Policy".tr,
                  onTap: controller.onPrivacyPolicyTap,
                ),
                _buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: "Version".tr,
                  trailingText: controller.appVersion.value.isEmpty
                      ? ''
                      : controller.appVersion.value,
                  onTap: controller.onVersionTap,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Menu Item Card ───
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool hasBonusBadge = false,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: _accentPink,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasBonusBadge) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E2538),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Get free bonus".tr,
                      style: const TextStyle(
                        color: _accentPink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (trailingText != null && trailingText.isNotEmpty)
                  Text(
                    trailingText,
                    style: const TextStyle(
                      color: _chevronColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _chevronColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── VIP Banner with bg_unlock_vip.png ───
  Widget _buildVipBanner({required bool isPremium}) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/png/bg_unlock_vip.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29DBFD).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isPremium ? null : controller.onVipBannerTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPremium ? "You're Premium 🎉".tr : "Unlock VIP".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isPremium
                            ? "Enjoy unlimited access and ad-free experience.".tr
                            : "Upgrade to VIP for exclusive features and unlimited access!".tr,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
