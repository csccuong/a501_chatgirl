import 'dart:async';
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import '../../models/db/chat_model.dart';
import '../../routes/app_pages.dart';
import '../chat_detail/chat_detail_controller.dart';
import '../chat_detail/chat_detail_page.dart';
import '../home/home_controller.dart';

class ChatsController extends GetxController {
  late Realm realm;
  final sessions = <ChatSession>[].obs;
  final isLoading = true.obs;
  StreamSubscription<RealmResultsChanges<ChatSession>>? _sub;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    try {
      final config =
          Configuration.local([ChatSession.schema, ChatMessage.schema]);
      realm = Realm(config);
      _listenToSessions();
    } catch (e) {
      print("Realm not generated or error: $e");
      isLoading.value = false;
    }
  }

  void _listenToSessions() {
    try {
      final allSessions = realm
          .all<ChatSession>()
          .query('TRUEPREDICATE SORT(lastActiveTime DESC)');
      // Initial load
      sessions.assignAll(allSessions.toList());
      isLoading.value = false;

      // Auto-update on changes from anywhere in the app
      _sub = allSessions.changes.listen((changes) {
        sessions.assignAll(changes.results.toList());
      });
    } catch (e) {
      print("Error listening to sessions: $e");
      isLoading.value = false;
    }
  }

  void loadSessions() {
    try {
      final allSessions = realm
          .all<ChatSession>()
          .query('TRUEPREDICATE SORT(lastActiveTime DESC)');
      sessions.assignAll(allSessions.toList());
    } catch (e) {}
  }

  String getCharacterDisplayName(ChatSession sm) {
    if (Get.isRegistered<HomeController>()) {
      final char = Get.find<HomeController>().getCharacterById(sm.characterId);
      if (char != null && (char.name?.isNotEmpty ?? false)) {
        return char.name!;
      }
    }
    return sm.characterName;
  }

  String getDisplayLastMessage(ChatSession sm) {
    final msg = sm.lastMessage.trim();
    if (msg == 'Starting a conversation...' ||
        msg == 'Bắt đầu một cuộc trò chuyện...' ||
        msg.startsWith('Starting a conversation') ||
        msg.isEmpty) {
      return "Starting a conversation...".tr;
    }
    if (msg == 'Sent an action image' ||
        msg == 'Đã gửi một hình ảnh hành động') {
      return "Sent an action image".tr;
    }
    return sm.lastMessage;
  }

  void updateSessionLocalizations() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        realm.write(() {
          for (final session in realm.all<ChatSession>()) {
            final char = homeCtrl.getCharacterById(session.characterId);
            if (char != null && (char.name?.isNotEmpty ?? false)) {
              session.characterName = char.name!;
            }
          }
        });
      }
      loadSessions();
    } catch (e) {
      print("updateSessionLocalizations error: $e");
    }
  }

  void goToChatDetail(ChatSession sm) {
    // Avoid lazyPut + GetView fallback Get.put fighting over the same type (crash / stale state).
    Get.delete<ChatDetailController>(force: true);
    void onReturn() {
      loadSessions();
      Get.delete<ChatDetailController>(force: true);
    }

    final charName = getCharacterDisplayName(sm);
    String intro = '';
    if (Get.isRegistered<HomeController>()) {
      final char = Get.find<HomeController>().getCharacterById(sm.characterId);
      if (char != null && (char.introduce?.isNotEmpty ?? false)) {
        intro = char.introduce!;
      }
    }

    final future = Get.to(
      () => ChatDetailPage(),
      arguments: {
        'characterId': sm.characterId,
        'characterName': charName,
        'avatarUrl': sm.characterAvatarUrl,
        'intro': intro,
      },
      routeName: AppRoutes.CHAT_DETAIL,
    );
    if (future != null) {
      future.then((_) => onReturn());
    } else {
      onReturn();
    }
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now'.tr;
    if (diff.inMinutes < 60) return '${diff.inMinutes}' + ' min ago'.tr;
    if (diff.inHours < 24) return '${diff.inHours}' + ' hour ago'.tr;
    if (diff.inDays < 7) return '${diff.inDays}' + ' days ago'.tr;
    return '${diff.inDays}' + ' days ago'.tr;
  }

  @override
  void onClose() {
    _sub?.cancel();
    try {
      realm.close();
    } catch (_) {}
    super.onClose();
  }
}
