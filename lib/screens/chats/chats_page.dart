import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/values/app_colors.dart';
import 'chats_controller.dart';

class ChatsPage extends GetView<ChatsController> {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  ChatsController get controller => Get.isRegistered<ChatsController>()
      ? Get.find<ChatsController>()
      : Get.put(ChatsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text("Chats".tr,
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.sessions.isEmpty) {
          return _buildEmptyState('No conversations yet.'.tr);
        }
        return ListView.separated(
          itemCount: controller.sessions.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final sm = controller.sessions[index];
            return GestureDetector(
              onTap: () {
                controller.goToChatDetail(sm);
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade900,
                      backgroundImage: sm.characterAvatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(sm.characterAvatarUrl)
                          : null,
                      child: sm.characterAvatarUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.getCharacterDisplayName(sm),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                controller.timeAgo(sm.lastActiveTime),
                                style: const TextStyle(
                                    color: AppColors.textSubColor,
                                    fontSize: 12),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.getDisplayLastMessage(sm),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFFB0B0B0), fontSize: 14),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/png/empty.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSubColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
