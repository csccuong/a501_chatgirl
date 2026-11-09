import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Utils/app_setting.dart';
import '../../core/values/app_colors.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import 'character_detail_controller.dart';

class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({Key? key}) : super(key: key);

  static const Color _cardBgColor = Color(0xFF141923);
  static const Color _accentPink = Color(0xFF29DBFD);
  static const Color _subTextColor = Color(0xFF8E95AA);
  static const Color _tagBgColor = Color(0xFF0E2538);
  /// Tạm thời ẩn phần Độ thân mật vì chưa triển khai
  static bool isIntimacyFeatureEnabled = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CharacterDetailController>(
      init: CharacterDetailController(),
      builder: (controller) {
        final char = controller.character;
        final headerImageUrl = (controller.highestUnlockedCardUrl?.isNotEmpty == true)
            ? controller.highestUnlockedCardUrl!
            : controller.formattedAvatarUrl;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              // ─── Scrollable Content ───
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── 1. Top Artwork Header with Name & Tags ───
                    _buildArtworkHeader(context, controller, char, headerImageUrl),

                    // ─── 2. Blackstory Card ───
                    _buildBackstoryCard(char),

                    // ─── 3. Intimacy Card ───
                    _buildIntimacyCard(controller),

                    // ─── 4. Gallery Card ───
                    _buildGalleryCard(controller, char),
                  ],
                ),
              ),

              // ─── Fixed Top Close Button ───
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: GestureDetector(
                  onTap: controller.onBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // ─── Fixed Bottom Chat Now Button & Banner Ad ───
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.backgroundColor.withValues(alpha: 0.0),
                        AppColors.backgroundColor.withValues(alpha: 0.85),
                        AppColors.backgroundColor,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom + 8
                        : 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chat Now Gradient Capsule Button
                      GestureDetector(
                        onTap: controller.startChat,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF29DBFD).withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Chat now".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),

                      // Banner Ad (if enabled)
                      Obx(() {
                        if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
                          return const SizedBox.shrink();
                        }
                        if (!FirebaseRemoteConfigService.getBoolConfigByKey(
                            FirebaseRemoteConfigService.banner_all)) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: EasyBannerAd(
                            adNetwork: AdNetwork.admob,
                            adId: MyAdIdName.bannerAll.getId,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Top Artwork Header with Name & Tags ───
  Widget _buildArtworkHeader(
    BuildContext context,
    CharacterDetailController controller,
    dynamic char,
    String imageUrl,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.46).clamp(340.0, 440.0);

    return Stack(
      children: [
        // Artwork Image
        SizedBox(
          height: headerHeight,
          width: double.infinity,
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF1A1A24),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF1A1A24),
                    child: const Icon(Icons.broken_image, color: Colors.white30, size: 48),
                  ),
                )
              : Container(
                  color: const Color(0xFF1A1A24),
                  child: const Icon(Icons.person, color: Colors.white30, size: 64),
                ),
        ),

        // Gradient fade to background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.backgroundColor.withValues(alpha: 0.15),
                  AppColors.backgroundColor.withValues(alpha: 0.75),
                  AppColors.backgroundColor,
                ],
                stops: const [0.35, 0.65, 0.88, 1.0],
              ),
            ),
          ),
        ),

        // Name and Tags pinned at bottom of artwork
        Positioned(
          left: 16,
          right: 16,
          bottom: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Character Name
              Text(
                char.name?.isNotEmpty == true ? char.name! : "Character".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Tags
              if (char.tags != null && (char.tags as List).isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (char.tags as List<String>)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _tagBgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: _accentPink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Card 1: Blackstory ───
  Widget _buildBackstoryCard(dynamic char) {
    final storyText = (char.introduce?.isNotEmpty == true)
        ? char.introduce!
        : ((char.description?.isNotEmpty == true)
            ? char.description!
            : "No backstory available.".tr);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Book Icon + Blackstory
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: _accentPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Blackstory".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Story text
          Text(
            storyText,
            style: const TextStyle(
              color: _subTextColor,
              fontSize: 13.5,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Card 2: Intimacy (Ẩn - tính năng chưa triển khai) ───
  Widget _buildIntimacyCard(CharacterDetailController controller) {
    if (!isIntimacyFeatureEnabled) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      final interaction = controller.interaction.value;
      final int level = (interaction?.intimacyLevel ?? 1).clamp(1, 99);
      final int maxExp = level >= 2 ? (level - 1) * 100 : 100;
      final int currentExp = (interaction?.intimacyExp != null && interaction!.intimacyExp! > 0)
          ? interaction.intimacyExp!
          : (level > 1 ? (maxExp * 0.64).toInt() : 0);
      final double progress = maxExp > 0 ? (currentExp / maxExp).clamp(0.0, 1.0) : 0.0;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Heart + Intimacy on left, Lv.X on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: _accentPink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Intimacy".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Lv.$level",
                  style: const TextStyle(
                    color: _accentPink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress Bar & Numbers
            Row(
              children: [
                // Filled progress track
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: 10,
                      color: const Color(0xFF2B283F),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: constraints.maxWidth * progress,
                              height: 10,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Exp label (e.g. 320 / 500)
                Text(
                  "$currentExp / $maxExp",
                  style: const TextStyle(
                    color: _subTextColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ─── Card 3: Gallery ───
  Widget _buildGalleryCard(CharacterDetailController controller, dynamic char) {
    final rawCards = char.cards is List ? (char.cards as List) : [];
    final cards = rawCards.isNotEmpty
        ? rawCards
        : [
            {
              'image_url': char.avatarUrl ?? '',
              'price_gems': 0,
              'intimacy_level_required': 1,
              'is_unlocked': true,
            }
          ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Gallery on left, X/Y Unlocked on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.photo_library_rounded,
                    color: _accentPink,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Gallery".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "${controller.getUnlockedCardsCount()}/${cards.length} ${'Unlocked'.tr}",
                style: const TextStyle(
                  color: _subTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2-Column Thumbnails Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final raw = cards[index];
              if (raw is! Map) return const SizedBox.shrink();
              final cardData = Map<String, dynamic>.from(raw);
              final String cardUrl = (cardData['image_url'] ?? '')
                  .toString()
                  .replaceAll('localhost:8000', '20.198.254.31:7005');
              final int priceGems = (cardData['price_gems'] is num)
                  ? (cardData['price_gems'] as num).toInt()
                  : 15;
              final bool isUnlocked = controller.isCardUnlocked(cardData, index);

              return GestureDetector(
                onTap: () => controller.onTapCard(cardData, index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail Image
                      if (cardUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: cardUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF262635),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF262635),
                            child: const Icon(Icons.image, color: Colors.white24, size: 24),
                          ),
                        )
                      else
                        Container(
                          color: const Color(0xFF262635),
                          child: const Icon(Icons.image, color: Colors.white24, size: 24),
                        ),

                      // Locked Overlay
                      if (!isUnlocked) ...[
                        // Backdrop blur & dark overlay
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),

                        // Center lock icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),

                        // Bottom gem price badge
                        Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/png/gem.png', width: 9, height: 9),
                                  const SizedBox(width: 3),
                                  Text(
                                    "$priceGems",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
