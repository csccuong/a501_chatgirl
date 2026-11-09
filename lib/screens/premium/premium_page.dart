import 'dart:ui';
import 'package:cscmobi_app/helper/iap_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../Utils/app_setting.dart';
import '../../core/values/app_colors.dart';
import '../../models/premium.dart';
import '../profile/profile_controller.dart';
import 'premium_controller.dart';

class PremiumPage extends GetView<PremiumController> {
  const PremiumPage({super.key});

  @override
  PremiumController get controller => Get.isRegistered<PremiumController>()
      ? Get.find<PremiumController>()
      : Get.put(PremiumController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/png/premium_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Obx(
              () => IndexedStack(
                index: controller.selectedTabIndex.value,
                children: [
                  _buildVipTab(),
                  _buildShopTab(),
                  _buildMissionTab(),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopRow(),
                _buildTabPill(),
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1016),
                  ),
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _buildPrimaryButton(),
                      ),
                      SafeArea(
                        top: false,
                        child: _buildFooterLinks(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.onSelectBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Obx(
          () {
            final sel = controller.selectedTabIndex.value;
            return Row(
              children: [
                _tabSegment('Shop'.tr, 0, sel == 0),
                _tabSegment('VIP'.tr, 1, sel == 1),
                _tabSegment('Mission'.tr, 2, sel == 2),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tabSegment(String label, int index, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVipTab() {
    return GetBuilder<PremiumController>(
      builder: (_) {
        final items = controller.coinItems;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 130),
                    Image.asset(
                      'assets/png/gem.png',
                      width: 88,
                      height: 88,
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      int gems = 0;
                      if (Get.isRegistered<ProfileController>()) {
                        gems = Get.find<ProfileController>().currentUser.value?.gems ?? 0;
                      } else {
                        // Dummy read of an Rx variable to satisfy GetX Obx when ProfileController is not registered yet
                        final _ = AppSetting.isPremiumUser.value;
                      }
                      return Text(
                        gems.toString() + ' Gems'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Loading products…'.tr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 182 / 122,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _buildGemOfferCard(items[index], index),
                      ),
                    const SizedBox(height: 132),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGemOfferCard(PremiumCoinItem item, int index) {
    return Obx(() {
      final selected = controller.selectedGemIndex.value == index;
      final double borderWidth = selected ? 2.0 : 1.0;
      final double innerRadius = 16.0 - borderWidth;

      return GestureDetector(
        onTap: () => controller.selectGemPack(index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? const Color(0xFF29DBFD) : null,
            gradient: selected
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white,
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
          ),
          padding: EdgeInsets.all(borderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF141923).withValues(alpha: 0.5)
                      : const Color(0xFF141923).withValues(alpha: 0.5),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${item.displayCoin}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Sora",
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Image.asset('assets/png/gem.png',
                                      width: 22, height: 22),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (item.bonusCoin > 0)
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.white.withValues(alpha: 0.92),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Sora",
                                    ),
                                    children: [
                                      TextSpan(text: '${item.baseCoin} + '),
                                      TextSpan(
                                        text: "${item.bonusCoin} ${'bonus'.tr}",
                                        style: const TextStyle(
                                          color: Color(0xFF29DBFD),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? null
                                : Colors.white.withValues(alpha: 0.08),
                            gradient: selected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF29DBFD),
                                      Color(0xFF0382C7),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(innerRadius),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              controller.getProductPrice(item.productId),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.badgeText != null && item.badgeText!.isNotEmpty)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF29DBFD), Color(0xFF0382C7)],
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(innerRadius),
                              bottomLeft: const Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            item.badgeText!.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Sora",
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShopTab() {
    return GetBuilder<PremiumController>(
      builder: (_) {
        final list = controller.listPremium;
        if (list.length < 2) {
          return Center(
            child: Text(
              'Loading…'.tr,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }
        return Stack(
          children: [
            // 1. Solid deep dark background to isolate tab from Scaffold background
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0xFF0D1016),
              ),
            ),
            // 2. Character thumbnail
            Positioned.fill(
              child: Column(
                children: [
                  ClipRRect(
                    child: AspectRatio(
                      aspectRatio: 500 / 525,
                      child: Image.asset(
                        'assets/png/premium_thumb.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 3. Smooth vertical dark gradient overlay drowning out bottom mist into #0C0C14
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x880D1016),
                      Color(0xEA0D1016),
                      Color(0xFF0D1016),
                      Color(0xFF0D1016),
                    ],
                    stops: [0.0, 0.22, 0.38, 0.50, 0.62, 1.0],
                  ),
                ),
              ),
            ),
            // 4. Foreground content
            Positioned.fill(
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Unlock'.tr,
                            style: GoogleFonts.orbitron(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF29DBFD), Color(0xFF0382C7)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              'Premium'.tr,
                              style: GoogleFonts.orbitron(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Obx(
                            () {
                              final lines = controller.listTitlePremium;
                              final half = (lines.length + 1) ~/ 2;
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (int i = 0; i < half; i++) ...[
                                          _bullet(lines[i]),
                                          if (i + 1 < half)
                                            const SizedBox(height: 8),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (int i = half;
                                            i < lines.length;
                                            i++) ...[
                                          _bullet(lines[i]),
                                          if (i + 1 < lines.length)
                                            const SizedBox(height: 8),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 112,
                        child: Row(
                          children: [
                            Expanded(
                              child: _subPlanCard(
                                list[0],
                                0,
                                perDayDivisor: 30,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _subPlanCard(
                                list[1],
                                1,
                                perDayDivisor: 365,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        child: Obx(
                          () {
                            final idx = controller.itemSelected.value
                                .clamp(0, list.length - 1);
                            final p = list[idx];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  p.desc.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  p.note.tr,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFC4C4C4),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 132),
                    ],
                  )),
            )
          ],
        );
      },
    );
  }

  Widget _bullet(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            height: 1.25,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subPlanCard(
    Premium p,
    int index, {
    required int perDayDivisor,
  }) {
    return Obx(
      () {
        final selected = controller.itemSelected.value == index;
        return Stack(
          children: [
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => controller.onSelectSubItem(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.backgroundItemColor,
                    border: Border.all(
                      color: selected
                          ? AppColors.main
                          : Colors.white.withValues(alpha: 0.1),
                      width: selected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p.title.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getSubDisplayPrice(p),
                        style: TextStyle(
                          fontSize: index == 1 ? 20 : 18,
                          color: selected ? AppColors.main : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getSubPerDayText(p,
                            perDayDivisor: perDayDivisor),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: p.packageId == IAPHelper.itemYearly
                    ? Center(
                        child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(colors: [
                                  Color(0xFFFB0004),
                                  Color(0xFFFF2B2E)
                                ])),
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Save ".tr +
                                      controller.percentSave.toString() +
                                      "%",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textColor),
                                ),
                              ],
                            )),
                      )
                    : const SizedBox())
          ],
        );
      },
    );
  }

  Widget _buildMissionTab() {
    return Stack(
      children: [
        Positioned.fill(
            child: Column(
          children: [
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 3.2 / 4,
                child: Image.asset(
                  'assets/png/premium_thumb2.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        )),
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Obx(() {
              final streak = controller.checkinStreak.value;
              final watched = controller.adsWatchedToday.value;
              final maxAds = controller.maxAdsPerDay.value;
              final rewardGems = controller.adsRewardGems.value;

              return Column(
                children: [
                  AspectRatio(aspectRatio: 4 / 4),
                  const SizedBox(height: 20),
                  Text(
                    'A Little Surprise Awaits'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Watch quick ads and unlock special waifu'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Watch Ads Row ───
                  _buildWatchAdsRow(rewardGems, watched, maxAds),
                  const SizedBox(height: 16),

                  // ─── Check-in Section ───
                  _buildCheckinSection(streak),
                  const SizedBox(height: 132),
                ],
              );
            }),
          ),
        )
      ],
    );
  }

  Widget _buildWatchAdsRow(int rewardGems, int watched, int maxAds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Gift icon
          Container(
            width: 44,
            height: 44,
            child: Center(
              child: Image.asset(
                'assets/png/gift.png',
                width: 44,
                height: 44,
                fit: BoxFit.fill,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.card_giftcard,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '+$rewardGems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset('assets/png/gem.png', width: 18, height: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${"Earn rewards".tr} ($watched/$maxAds)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Watch button
          GestureDetector(
            onTap: () => controller.onTapClaimMission(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Watch'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinSection(int streak) {
    final scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (streak >= 3 && scrollController.hasClients) {
        const cardWidth = 54.0;
        final nextDay = streak + 1;
        final viewportWidth = scrollController.position.viewportDimension;
        final targetOffset =
            ((nextDay - 1) * cardWidth) - (viewportWidth / 2) + (cardWidth / 2);
        final clampedOffset =
            targetOffset.clamp(0.0, scrollController.position.maxScrollExtent);
        scrollController.jumpTo(clampedOffset);
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: " day".tr),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Days Row
          SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final day = index + 1;
                final isClaimed = day <= streak;
                final isNextToClaim = day == streak + 1;
                final reward = controller.getCheckinRewardForDay(day);
                return _buildMissionDayCard(
                    day, reward, isClaimed, isNextToClaim);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionDayCard(
      int day, int reward, bool isClaimed, bool isNextToClaim) {
    Color bgColor = const Color(0xFF141923);
    Color borderColor = Colors.transparent;

    if (isClaimed) {
      bgColor = AppColors.main;
    } else if (isNextToClaim) {
      borderColor = AppColors.main;
    }

    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: day == 7 ? 54 : 48,
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
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Day $day".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 4),
                day == 7
                    ? Image.asset(
                        'assets/png/gift.png',
                        height: 18,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.card_giftcard,
                          color: Colors.amber,
                          size: 18,
                        ),
                      )
                    : Image.asset('assets/png/gem.png', height: 18),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    day == 7 ? "Mystery\ngift".tr : "+$reward",
                    style: TextStyle(
                      color: day == 7 ? Colors.white70 : Colors.white,
                      fontSize: day == 7 ? 9 : 12,
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
              top: -3,
              right: -3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.green, size: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Obx(
      () {
        final tab = controller.selectedTabIndex.value;
        final isMission = tab == 2;
        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Shimmer(
            duration: const Duration(seconds: 5),
            interval: Duration.zero,
            color: Colors.white,
            colorOpacity: 1,
            enabled: !isMission,
            direction: const ShimmerDirection.fromLTRB(),
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextButton(
                onPressed: () {
                  if (isMission) {
                    controller.onCheckin();
                  } else {
                    controller.onContinuePrimary();
                  }
                },
                child: Obx(() => isMission && controller.isCheckinClaiming.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isMission
                            ? 'Check in'.tr
                            : controller.titleButton.value.tr,
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterLinks() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: controller.onSelectRestore,
              child: Text(
                'Restore Purchase'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC4C4C4),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: controller.onSelectPrivacy,
              child: Text(
                'Privacy Policy'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC4C4C4),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: controller.onSelectTermOfUse,
              child: Text(
                'Terms of Use'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC4C4C4),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
