import 'dart:ui';
import 'package:cscmobi_app/Utils/app_setting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/values/app_colors.dart';
import '../../routes/app_pages.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../premium/premium_controller.dart';
import '../premium/premium_page.dart';
import 'chat_detail_controller.dart';

import 'package:intl/intl.dart';
import '../../core/utils/app_util.dart';
import '../../core/utils/action_localization.dart';

class ChatDetailPage extends GetView<ChatDetailController> {
  ChatDetailPage({Key? key}) : super(key: key);

  @override
  ChatDetailController get controller =>
      Get.isRegistered<ChatDetailController>()
          ? Get.find<ChatDetailController>()
          : Get.put(ChatDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() => controller.bgUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: controller.bgUrl,
                    fit: BoxFit.cover,
                  )
                : Container(color: AppColors.backgroundColor)),
          ),
          // Dark Overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Obx(() {
                          return ListView.builder(
                            controller: controller.scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 60), // added bottom padding to clear buttons
                            itemCount: controller.messages.length + 1 + (controller.isLoading.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _buildIntroHeader();
                              }
                              
                              final msgIndex = index - 1;
                              if (msgIndex == controller.messages.length) {
                                return _buildTypingIndicator();
                              }
                              
                              final msg = controller.messages[msgIndex];
                              final showDate =
                                  controller.shouldShowDateForMessage(msgIndex);
                              
                              return _buildMessageBubble(msg, showDate: showDate);
                            },
                          );
                        }),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: _buildAssetButtons(),
                      ),
                    ],
                  ),
                ),
                _buildInputSection(),
                Obx(() {
                  if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
                    return const SizedBox.shrink();
                  }
                  if (!FirebaseRemoteConfigService.getBoolConfigByKey(
                      FirebaseRemoteConfigService.banner_all)) {
                    return const SizedBox.shrink();
                  }
                  return EasyBannerAd(
                    adNetwork: AdNetwork.admob,
                    adId: MyAdIdName.bannerAll.getId,
                    isCollapsible: true,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: Get.back,
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade900,
            backgroundImage: controller.avatarUrl.isNotEmpty 
                ? CachedNetworkImageProvider(controller.avatarUrl) 
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.characterName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                )),
                Text(
                  "All content is AI-generated".tr,
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                )
              ],
            ),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF141923),
            onSelected: controller.onHeaderMenuSelected,
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text("Clear chat".tr, style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 1, child: Text("Album".tr, style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 2, child: Text("Report".tr, style: TextStyle(color: Colors.white))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIntroHeader() {
    return Obx(() {
      if (controller.intro.isEmpty) return const SizedBox.shrink();

      DateTime dateToShow = DateTime.now();
      if (controller.messages.isNotEmpty) {
        dateToShow = controller.messages.first.createdAt.toLocal();
      }

      final langCode = AppSetting.selectedLanguageCode.isNotEmpty
          ? AppSetting.selectedLanguageCode
          : (Get.locale?.languageCode ?? 'en');

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('d MMMM yyyy', langCode).format(dateToShow),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24, top: 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: RichText(
              text: TextSpan(
                text: "Intro: ".tr,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.4),
                children: [
                  TextSpan(
                    text: controller.intro,
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMessageBubble(dynamic msg, {bool showDate = false}) {
    bool isUser = msg.role == 'user';
    final localCreatedAt = msg.createdAt.toLocal();
    final timeStr = DateFormat('HH:mm').format(localCreatedAt);
    final langCode = AppSetting.selectedLanguageCode.isNotEmpty
        ? AppSetting.selectedLanguageCode
        : (Get.locale?.languageCode ?? 'en');

    return Column(
      children: [
        if (showDate)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('d MMMM yyyy', langCode).format(localCreatedAt),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUser) ...[
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: controller.avatarUrl.isNotEmpty 
                        ? CachedNetworkImageProvider(controller.avatarUrl) 
                        : null,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Builder(builder: (context) {
                    final isImageMessage =
                        controller.isImageMessageContent(msg.content);
                    final imageUrl =
                        controller.extractImageUrlFromContent(msg.content);

                    if (isImageMessage && imageUrl.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.openImagePreview(imageUrl);
                            },
                            onLongPress: () =>
                                controller.showMessageOptions(msg, isUser),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: MediaQuery.of(context).size.width * 0.65,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: 200, height: 200, color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: isUser ? Colors.white.withOpacity(0.7) : Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    }

                    return GestureDetector(
                      onLongPress: () =>
                          controller.showMessageOptions(msg, isUser),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isUser ? AppColors.primaryGradient : null,
                          color: isUser ? null : const Color(0xFF1E2633),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            isUser
                                ? Text(
                                    msg.content,
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
                                  )
                                : MarkdownBody(
                                    data: msg.content,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                                      em: const TextStyle(color: Colors.white70, fontSize: 15, fontStyle: FontStyle.italic),
                                      strong: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            const SizedBox(height: 6),
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: isUser ? Colors.white.withOpacity(0.7) : Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                if (isUser) const SizedBox(width: 24), // spacing for layout symmetry
                if (!isUser) const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF1E2633),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.main,
              backgroundColor: Colors.white24,
              strokeWidth: 2.4,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ),
    );
  }

  // final profileCtrl = controller.profileController;
  Widget _buildAssetButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPillButton("👗", "Outfits".tr, const Color(0xFF0E2538), _showOutfitSheet),
          const SizedBox(width: 8),
          _buildPillButton("😋", "Actions".tr, const Color(0xFF0E2538), _showActionSheet),
          Expanded(child: const SizedBox(width: 12)),
          Obx(() {
            final gems = controller.profileController.currentUser.value?.gems ?? 0;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.onGemsCapsuleTap,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141923),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset('assets/png/gem.png',
                              width: 22, height: 22),
                          Positioned(
                            right: -3,
                            bottom: -2,
                            child: Container(
                              width: 11,
                              height: 11,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF141923), width: 1),
                              ),
                              child: const Icon(Icons.add,
                                  size: 7, color: const Color(0xFF0D1016)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$gems',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPillButton(String emoji, String text, Color baseColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showOutfitSheet() {
    if (!controller.hasOutfits) {
      AppUtil.showNormalToast("No outfits available".tr);
      return;
    }
    Get.bottomSheet(
      Container(
        height: 500,
        decoration: const BoxDecoration(
          color: const Color(0xFF141923),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text("Outfit".tr, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "During the chat, the character will send images according to the selected outfit".tr,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.outfits.length,
                itemBuilder: (context, index) {
                  final outfit = controller.outfits[index];
                  final priceObj = outfit['price_gems'];
                  final int priceGems = (priceObj is int) ? priceObj : 0;
                  final isCustom = outfit['name']?.toString().toLowerCase().contains('custom') ?? false;

                  return GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.handleOutfitSelection(outfit);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: outfit['thumbnail_icon'] ?? '',
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isCustom) ...[
                                    Image.asset('assets/png/gem.png', width: 12, height: 12),
                                    const SizedBox(width: 4),
                                    Text(priceGems.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ] else
                                    Text("Custom".tr, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet() {
    if (!controller.hasActions) {
      AppUtil.showNormalToast("No actions available".tr);
      return;
    }
    Get.bottomSheet(
      Container(
        height: 350,
        decoration: const BoxDecoration(
          color: const Color(0xFF141923),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text("Actions".tr, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.actions.length,
                itemBuilder: (context, index) {
                  final action = controller.actions[index];
                  final priceObj = action['price_gems'];
                  final int priceGems = (priceObj is int) ? priceObj : 0;
                  
                  return GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.handleActionSelection(action);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: action['icon_url'] ?? '',
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => const Icon(Icons.star, color: Colors.grey, size: 36),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(ActionLocalization.getLocalizedName(action['name']), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/png/gem.png', width: 12, height: 12),
                            const SizedBox(width: 4),
                            Text("$priceGems", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.toWithController(
                controllerBuilder: () => PremiumController(),
                page: () => const PremiumPage(),
                routeName: AppRoutes.PREMIUM,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.shopping_bag, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF131722),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      focusNode: controller.focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: "Type a message...".tr,
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.main),
                    onPressed: controller.sendMessage,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
