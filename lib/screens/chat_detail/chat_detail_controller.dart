import 'dart:convert';
import 'package:cscmobi_app/core/base/base_controller.dart';


import '../../helper/firebase_remote_config_service.dart';
import '../album/album_page.dart';
import '../album/album_controller.dart';
import 'package:cscmobi_app/screens/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api_rest/api_repository.dart';
import 'package:realm/realm.dart';
import '../../models/db/chat_model.dart';
import '../../core/utils/app_util.dart';
import '../../routes/app_pages.dart';
import '../premium/premium_controller.dart';
import '../premium/premium_page.dart';
import '../profile/profile_controller.dart';
import '../full_screen_image/full_screen_image_page.dart';
import '../full_screen_image/full_screen_image_controller.dart';
import '../popup_out_of_gems/popup_out_of_gems_controller.dart';
import '../popup_out_of_gems/popup_out_of_gems_page.dart';
import 'dart:math';
import '../../models/character_model.dart';

class ChatDetailController extends BaseController {
  late Realm realm;
  final messages = <ChatMessage>[].obs;

  String characterId = '';
  final _characterName = ''.obs;

  String get characterName {
    if (Get.isRegistered<HomeController>()) {
      final char = Get.find<HomeController>().getCharacterById(characterId);
      if (char != null && (char.name?.isNotEmpty ?? false)) {
        return char.name!;
      }
    }
    return _characterName.value;
  }

  set characterName(String v) => _characterName.value = v;

  String avatarUrl = '';
  final _bgUrl = ''.obs;

  String get bgUrl => _bgUrl.value;

  set bgUrl(String v) => _bgUrl.value = v;
  final cardUrls = <String>[].obs;
  final unlockedCardUrls = <String>[].obs;

  final _intro = ''.obs;

  String get intro {
    if (Get.isRegistered<HomeController>()) {
      final char = Get.find<HomeController>().getCharacterById(characterId);
      if (char != null && (char.introduce?.isNotEmpty ?? false)) {
        return char.introduce!;
      }
    }
    return _intro.value;
  }

  set intro(String v) => _intro.value = v;

  void refreshLocalizedInfo() {
    if (Get.isRegistered<HomeController>()) {
      final char = Get.find<HomeController>().getCharacterById(characterId);
      if (char != null) {
        if (char.name != null && char.name!.isNotEmpty) {
          characterName = char.name!;
        }
        if (char.introduce != null && char.introduce!.isNotEmpty) {
          intro = char.introduce!;
        }
        try {
          var session = realm.find<ChatSession>(characterId);
          if (session != null) {
            realm.write(() {
              if (characterName.isNotEmpty) {
                session.characterName = characterName;
              }
            });
          }
        } catch (_) {}
      }
    }
    update();
  }
  DateTime sessionStartDate = DateTime.now();

  final outfits = <dynamic>[].obs;
  final actions = <dynamic>[].obs;

  final isLoading = false.obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();
  static List<String> reportReasons = ["Inappropriate/Explicit content.".tr, "Violence/Gore.".tr, "Copyright infringement/Misinformation.".tr, "Other.".tr];

  ProfileController get profileController => Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

  @override
  void onInit() {
    super.onInit();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 350), () {
          _scrollToBottom();
        });
      }
    });

    final args = Get.arguments;
    if (args != null) {
      characterId = args['characterId'] ?? '';
      characterName = args['characterName'] ?? '';
      avatarUrl = args['avatarUrl'] ?? '';
      bgUrl = args['bgUrl'] ?? avatarUrl;
      intro = args['intro'] ?? '';
    }

    _fetchAssets();
    try {
      final config = Configuration.local([ChatSession.schema, ChatMessage.schema]);
      realm = Realm(config);
      _initSession();
      loadMessages();
    } catch (e) {
      print("Realm init error: $e");
    }
  }



  void onGemsCapsuleTap() {
    Get.toWithController(
      controllerBuilder: () => PremiumController(),
      page: () => const PremiumPage(),
      routeName: AppRoutes.PREMIUM,
    );
  }

  void _initSession() {
    try {
      var session = realm.find<ChatSession>(characterId);
      if (session == null) {
        realm.write(() {
          realm.add(ChatSession(
            characterId,
            characterId,
            characterName,
            avatarUrl,
            "Starting a conversation...".tr,
            DateTime.now(),
          ));
        });
      } else {
        if (characterName.isNotEmpty && session.characterName != characterName) {
          realm.write(() {
            session.characterName = characterName;
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _fetchAssets() async {
    if (characterId.isNotEmpty) {
      try {
        dynamic charData;
        try {
          final homeController = Get.find<HomeController>();
          charData = homeController.getCharacterById(characterId);
          if (charData == null && homeController.categories.isNotEmpty) {
            for (var cat in homeController.categories) {
              final chars = cat.characters ?? [];
              for (var c in chars) {
                if (c.id == characterId) {
                  charData = c;
                  break;
                }
              }
              if (charData != null) break;
            }
          }
        } catch (e) {
          print("HomeController not found or error: $e");
        }

        if (charData == null) {
          try {
            final chars = await ApiRepository().getCharactersWeifu();
            for (final c in chars) {
              if (c is Map && (c['_id']?.toString() == characterId || c['id']?.toString() == characterId)) {
                charData = CharacterModel.fromJson(Map<String, dynamic>.from(c));
                break;
              }
            }
          } catch (_) {}
        }

        if (charData != null) {
          final resolvedName = charData is CharacterModel
              ? charData.name
              : (charData is Map ? charData['name']?.toString() : null);
          final resolvedIntro = charData is CharacterModel
              ? charData.introduce
              : (charData is Map ? charData['introduce']?.toString() : null);
          final avatarValue = charData is CharacterModel
              ? (charData.avatarUrl ?? '')
              : (charData is Map ? (charData['avatar_url']?.toString() ?? '') : '');
          final cards = charData is CharacterModel
              ? (charData.cards ?? [])
              : (charData is Map ? (charData['cards'] as List? ?? []) : []);

          if (resolvedName != null && resolvedName.isNotEmpty) {
            characterName = resolvedName;
          }
          if (resolvedIntro != null && resolvedIntro.isNotEmpty) {
            intro = resolvedIntro;
          }
          if (avatarUrl.isEmpty && avatarValue.isNotEmpty) {
            avatarUrl = avatarValue;
          }

          if (cardUrls.isEmpty) {
            final urls = <String>[];
            final unlockedUrls = <String>[];
            final unlockedIdsFromLocal = _loadUnlockedCardIdsFromLocal();

            for (final item in cards) {
              if (item is Map) {
                final card = Map<String, dynamic>.from(item);
                final url = (card['image_url'] ?? '').toString();
                if (url.isNotEmpty) {
                  final normalizedUrl = _normalizeImageUrl(url);
                  urls.add(normalizedUrl);

                  final cardId = (card['_id'] ?? card['id'] ?? card['card_id'])?.toString();
                  final isUnlocked = card['is_unlocked'] == true ||
                      card['unlocked'] == true ||
                      card['status'] == 'unlocked' ||
                      card['unlocked_at'] != null ||
                      (cardId != null && unlockedIdsFromLocal.contains(cardId)) ||
                      urls.length == 1;

                  if (isUnlocked) {
                    unlockedUrls.add(normalizedUrl);
                  }
                }
              }
            }
            cardUrls.assignAll(urls);
            unlockedCardUrls.assignAll(unlockedUrls.toSet().toList());
          }
          if (bgUrl.isEmpty) {
            bgUrl = avatarValue;
            if (cardUrls.isNotEmpty) {
              bgUrl = cardUrls.first;
            }
          }
          bgUrl = _normalizeImageUrl(bgUrl);

          try {
            var session = realm.find<ChatSession>(characterId);
            if (session != null) {
              realm.write(() {
                if (characterName.isNotEmpty) {
                  session.characterName = characterName;
                }
                if (avatarUrl.isNotEmpty) {
                  session.characterAvatarUrl = avatarUrl;
                }
              });
            }
          } catch (_) {}
        }

        final outRes = await ApiRepository().getCharacterOutfits(characterId);
        outfits.assignAll(outRes);

        final actRes = await ApiRepository().getCharacterActions(characterId);
        actions.assignAll(actRes);
      } catch (e) {
        print("Fetch assets error: $e");
      }
    }
  }

  void loadMessages() {
    try {
      final msgs = realm.all<ChatMessage>().query('sessionId == \$0 SORT(createdAt ASC)', [characterId]);
      messages.assignAll(msgs.toList());
      if (messages.isNotEmpty) {
        sessionStartDate = messages.first.createdAt;
      }
      _scrollToBottom();
    } catch (e) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> handleOutfitSelection(dynamic outfit) async {
    final priceObj = outfit['price_gems'];
    final int priceGems = (priceObj is int) ? priceObj : 0;

    // Validate Gems if profile is registered
    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      final currentGems = profileCtrl.currentUser.value?.gems ?? 0;
      if (currentGems < priceGems) {
        AppUtil.showNormalToast('You need'.tr + '$priceGems' + '💎 to use this outfit.'.tr);
        return;
      }

      // Proceed API Call
      AppUtil.showNormalToast("Applying outfit...".tr);
      final outfitId = outfit['id']?.toString() ?? outfit['_id']?.toString() ?? '';
      if (outfitId.isEmpty) return;

      final res = await ApiRepository().useOutfitWeifu(outfitId);
      bool isReviewerEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.enable_reviewer_add_gems,
      );

      final isSuccess = (res != null && res['success'] == true) || isReviewerEnabled;

      if (isSuccess) {
        // Update user remaining gems locally
        profileCtrl.currentUser.update((val) {
          if (val != null) {
            val.gems = isReviewerEnabled
                ? ((val.gems ?? 0) - priceGems).clamp(0, 9999999)
                : (res?['remaining_gems'] ?? val.gems);
          }
        });

        // Show random result image
        final List<dynamic> images = outfit['result_urls'] ?? [];
        String imageUrl = outfit['thumbnail_icon'] ?? '';

        if (images.isNotEmpty) {
          final randomInt = Random().nextInt(images.length);
          imageUrl = images[randomInt].toString();
        }

        if (imageUrl.isNotEmpty) {
          // Send image into chat locally
          final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

          // "assistant" role to ensure it shows up on the left side
          final botMsg = ChatMessage(timestamp, characterId, "assistant", "![Outfit Image]($imageUrl)", DateTime.now());
          try {
            realm.write(() {
              realm.add(botMsg);
              var session = realm.find<ChatSession>(characterId);
              if (session != null) {
                session.lastMessage = "Sent an image".tr;
                session.lastActiveTime = DateTime.now();
              }
            });
            loadMessages();
          } catch (e) {
            AppUtil.showLog("Realm error injecting outfit image: $e");
          }
        }

        //reload gems
        reloadGemsAfterSuccessAction();
      } else {
        AppUtil.showNormalToast(res?['message'] ?? "Could not apply outfit.".tr);
      }
    }
  }

  Future<void> handleActionSelection(dynamic action) async {
    final priceObj = action['price_gems'];
    final int priceGems = (priceObj is int) ? priceObj : 0;

    // Validate Gems if profile is registered
    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      final currentGems = profileCtrl.currentUser.value?.gems ?? 0;
      if (currentGems < priceGems) {
        AppUtil.showNormalToast("You need".tr + "$priceGems" + "💎 to use this action.".tr);
        return;
      }

      // Proceed API Call
      AppUtil.showNormalToast("Applying action...".tr);
      final actionId = action['id']?.toString() ?? action['_id']?.toString() ?? '';
      if (actionId.isEmpty) return;

      final res = await ApiRepository().useActionWeifu(actionId);
      bool isReviewerEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.enable_reviewer_add_gems,
      );

      final isSuccess = (res != null && res['success'] == true) || isReviewerEnabled;

      if (isSuccess) {
        // Update user remaining gems locally
        profileCtrl.currentUser.update((val) {
          if (val != null) {
            val.gems = isReviewerEnabled
                ? ((val.gems ?? 0) - priceGems).clamp(0, 9999999)
                : (res?['remaining_gems'] ?? val.gems);
          }
        });

        // Show random result image
        final List<dynamic> images = action['result_urls'] ?? [];
        String imageUrl = action['icon_url'] ?? ''; // fallback

        if (images.isNotEmpty) {
          final randomInt = Random().nextInt(images.length);
          imageUrl = images[randomInt].toString();
        }

        if (imageUrl.isNotEmpty) {
          // Send image into chat locally
          final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

          // "assistant" role to ensure it shows up on the left side
          final botMsg = ChatMessage(timestamp, characterId, "assistant", "![Action Image]($imageUrl)", DateTime.now());
          try {
            realm.write(() {
              realm.add(botMsg);
              var session = realm.find<ChatSession>(characterId);
              if (session != null) {
                session.lastMessage = "Sent an action image".tr;
                session.lastActiveTime = DateTime.now();
              }
            });
            loadMessages();
          } catch (e) {
            AppUtil.showLog("Realm error injecting action image: $e");
          }
        }

        //reload gems
        reloadGemsAfterSuccessAction();
      } else {
        AppUtil.showNormalToast(res?['message'] ?? "Could not apply action.".tr);
      }
    }
  }

  reloadGemsAfterSuccessAction() async {
    bool isReviewerEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.enable_reviewer_add_gems,
    );
    if (isReviewerEnabled) {
      final currentGems = profileController.currentUser.value?.gems ?? 0;
      if (currentGems > 0) {
        profileController.currentUser.value?.gems = currentGems - 1;
        profileController.currentUser.refresh();
      }
      return;
    }

    try {
      await profileController.fetchProfile();
      final currentGems = profileController.currentUser.value?.gems ?? 0;

      AppUtil.showLogFull("sendChatMessageWeifu currentGems: $currentGems");
      if (currentGems == 0) {
        AppUtil.showToastError('You just used your last gem.');
      }
    } catch (e) {}
  }

  void _showOutOfGemsPopup() {
    Get.dialog(
      GetBuilder<PopupOutOfGemsController>(
        init: PopupOutOfGemsController(
          onWatchAdSuccess: () async {
            if (Get.isRegistered<ProfileController>()) {
              await Get.find<ProfileController>().fetchProfile();
              update();
            }
          },
          onGoPremium: () {
            Get.toWithController(
              controllerBuilder: () => PremiumController(),
              page: () => const PremiumPage(),
              routeName: AppRoutes.PREMIUM,
            );
          },
        ),
        builder: (_) => const PopupOutOfGemsPage(),
      ),
      barrierDismissible: true,
      useSafeArea: false,
    );
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final currentGems = profileController.currentUser.value?.gems ?? 0;
    if (currentGems == 0) {
      _showOutOfGemsPopup();
      return;
    }

    textController.clear();

    final userMsgId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMsg = ChatMessage(userMsgId, characterId, "user", text, DateTime.now());

    try {
      realm.write(() {
        realm.add(userMsg);
        var session = realm.find<ChatSession>(characterId);
        if (session == null) {
          session = ChatSession(characterId, characterId, characterName, avatarUrl, text, DateTime.now());
          realm.add(session);
        } else {
          session.lastMessage = text;
          session.lastActiveTime = DateTime.now();
        }
      });
      loadMessages();
    } catch (e) {
      print(e);
      return;
    }

    isLoading.value = true;

    // take last 10 messages for history
    List<Map<String, dynamic>> history = [];
    final recent = messages.take(messages.length - 1).toList();
    final maxHist = min(recent.length, 10);
    for (var m in recent.sublist(recent.length - maxHist)) {
      history.add({"role": m.role, "content": m.content});
    }

    try {
      final stream = ApiRepository().sendChatMessageWeifu(characterId, history, text);

      final aiMsgId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      final aiMsg = ChatMessage(aiMsgId, characterId, "assistant", "", DateTime.now());
      var isFirstChunk = true;

      await for (final chunk in stream) {
        if (isFirstChunk) {
          isLoading.value = false;
          realm.write(() {
            realm.add(aiMsg);
          });
          messages.add(aiMsg);
          isFirstChunk = false;
        }

        if (chunk.isNotEmpty) {
          realm.write(() {
            aiMsg.content += chunk;
            var session = realm.find<ChatSession>(characterId);
            if (session != null) {
              session.lastMessage = aiMsg.content;
              session.lastActiveTime = DateTime.now();
            }
          });
          messages.refresh();
          _scrollToBottom();
        }
      }

      //reload gems
      reloadGemsAfterSuccessAction();
    } catch (e) {
      print("Chat error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onHeaderMenuSelected(int value) {
    if (value == 0) clearChat();
    if (value == 1) openAlbum();
    if (value == 2) reportChat();
  }

  bool shouldShowDateForMessage(int msgIndex) {
    if (msgIndex == 0) return intro.isEmpty;
    final msgLocal = messages[msgIndex].createdAt.toLocal();
    final prevMsgLocal = messages[msgIndex - 1].createdAt.toLocal();
    return msgLocal.day != prevMsgLocal.day || msgLocal.month != prevMsgLocal.month || msgLocal.year != prevMsgLocal.year;
  }

  bool isImageMessageContent(String content) {
    return content.startsWith("![") && content.endsWith(")");
  }

  String extractImageUrlFromContent(String content) {
    if (!isImageMessageContent(content)) return '';
    final start = content.indexOf('](') + 2;
    final end = content.length - 1;
    if (start >= 2 && end > start && end < content.length) {
      return content.substring(start, end);
    }
    return '';
  }

  void openImagePreview(String imageUrl) {
    Get.toWithController(
      controllerBuilder: () => FullScreenImageController(),
      page: () => const FullScreenImagePage(),
      arguments: imageUrl,
      routeName: AppRoutes.FULL_SCREEN_IMAGE,
    );
  }

  void showMessageOptions(ChatMessage msg, bool isUser) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xFF24242A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.white),
                title: Text("Delete".tr, style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  deleteMessage(msg.id);
                },
              ),
              if (!isUser)
                ListTile(
                  leading: const Icon(Icons.report_outlined, color: Colors.white),
                  title: Text("Report".tr, style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    reportMessage(msg.id);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get hasOutfits => outfits.isNotEmpty;

  bool get hasActions => actions.isNotEmpty;

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    try {
      realm.close();
    } catch (_) {}
    super.onClose();
  }

  void deleteMessage(String msgId) {
    try {
      final msg = realm.find<ChatMessage>(msgId);
      if (msg != null) {
        realm.write(() {
          realm.delete(msg);
        });
        loadMessages();
      }
    } catch (e) {
      AppUtil.showLog("Delete msg error: $e");
    }
  }

  void reportMessage(String msgId) {
    var selectedReportReason = 0.obs;
    final reasons = ["Inappropriate/Explicit content.".tr, "Violence/Gore.".tr, "Copyright infringement/Misinformation.".tr, "Other.".tr];

    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF24242A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Report Message".tr, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
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
          const SizedBox(height: 16),
          Obx(() => Column(
                children: List.generate(reasons.length, (index) {
                  return Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors.white54,
                    ),
                    child: RadioListTile<int>(
                      title: Text(reasons[index], style: const TextStyle(color: Colors.white, fontSize: 14)),
                      value: index,
                      activeColor: const Color(0xFF9061FF),
                      groupValue: selectedReportReason.value,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) selectedReportReason.value = val;
                      },
                    ),
                  );
                }),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9061FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                Get.back();
                AppUtil.showNormalToast("Thank you, we have received your report and will process it within 24 hours.".tr);
              },
              child: Text("Submit".tr, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ));
  }

  void clearChat() {
    try {
      final sessionMessages = realm.all<ChatMessage>().query("sessionId == \$0", [characterId]);
      realm.write(() {
        realm.deleteMany(sessionMessages);
        var session = realm.find<ChatSession>(characterId);
        if (session != null) {
          session.lastMessage = "Starting a conversation...";
          session.lastActiveTime = DateTime.now();
        }

        if (intro.isNotEmpty) {
          // (Reverted intro as message)
        }
      });
      messages.clear(); // Clear memory
      AppUtil.showNormalToast("Chat history cleared.".tr);
    } catch (e) {
      AppUtil.showLog("Clear chat error: $e");
    }
  }

  void reportChat() {
    var selectedReportReason = 0.obs;
    final reasons = ["Inappropriate/Explicit content.".tr, "Violence/Gore.".tr, "Copyright infringement/Misinformation.".tr, "Other.".tr];

    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF24242A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Report Conversation".tr, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
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
          const SizedBox(height: 16),
          Obx(() => Column(
                children: List.generate(reasons.length, (index) {
                  return Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors.white54,
                    ),
                    child: RadioListTile<int>(
                      title: Text(reasons[index], style: const TextStyle(color: Colors.white, fontSize: 14)),
                      value: index,
                      activeColor: const Color(0xFF9061FF),
                      groupValue: selectedReportReason.value,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) selectedReportReason.value = val;
                      },
                    ),
                  );
                }),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9061FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                Get.back();
                AppUtil.showNormalToast("Thank you, we have received your report and will process it within 24 hours.".tr);
              },
              child: Text("Submit".tr, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ));
  }

  void openAlbum() {
    final openedCardSet = unlockedCardUrls.map(_normalizeImageUrl).toSet();
    final nonCardChatUrls = <String>[];
    final normalizedCardUrls = cardUrls.map(_normalizeImageUrl).toSet();

    for (var msg in messages) {
      if (msg.content.startsWith("![") && msg.content.endsWith(")")) {
        int start = msg.content.indexOf('](') + 2;
        int end = msg.content.length - 1;
        if (start >= 2 && end > start && end < msg.content.length) {
          final imageUrl = _normalizeImageUrl(msg.content.substring(start, end));

          if (normalizedCardUrls.contains(imageUrl)) {
            openedCardSet.add(imageUrl);
          } else {
            nonCardChatUrls.add(imageUrl);
          }
        }
      }
    }

    final albumCardUrls = cardUrls.map(_normalizeImageUrl).where((url) => openedCardSet.contains(url)).toList();

    Get.toWithController(
      controllerBuilder: () => AlbumController(),
      page: () => const AlbumPage(),
      arguments: {'cardUrls': albumCardUrls, 'chatUrls': nonCardChatUrls},
      routeName: AppRoutes.ALBUM,
    );
  }

  String _normalizeImageUrl(String url) {
    return url.replaceAll('localhost:8000', '20.198.254.31:7005');
  }

  Set<String> _loadUnlockedCardIdsFromLocal() {
    final result = <String>{};
    try {
      final raw = AppUtil.getString('character_unlocked_cards_$characterId');
      if (raw.isEmpty) return result;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final item in decoded) {
          final id = item?.toString() ?? '';
          if (id.isNotEmpty) {
            result.add(id);
          }
        }
      }
    } catch (_) {}
    return result;
  }
}
