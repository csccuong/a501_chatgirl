import 'dart:convert';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:get/get.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../models/character_model.dart';
import '../../models/interaction_model.dart';
import '../../api_rest/api_repository.dart';
import '../../core/utils/app_util.dart';
import '../../routes/app_pages.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../utils/app_setting.dart';
import '../ads_full/ads_full_controller.dart';
import '../ads_full/ads_full_page.dart';
import '../popup_not_enough_gems/popup_not_enough_gems_controller.dart';
import '../popup_not_enough_gems/popup_not_enough_gems_page.dart';
import '../premium/premium_controller.dart';
import '../premium/premium_page.dart';
import '../profile/profile_controller.dart';
import '../chat_detail/chat_detail_controller.dart';
import '../chat_detail/chat_detail_page.dart';
import '../full_screen_image/full_screen_image_controller.dart';
import '../full_screen_image/full_screen_image_page.dart';

class CharacterDetailController extends BaseController {
  late CharacterModel character;
  var interaction = Rxn<InteractionModel>();
  var isLoading = true.obs;
  final Set<String> _unlockingCardIds = <String>{};
  final RxSet<String> unlockedCardIds = <String>{}.obs;

  final ApiRepository _apiRepo = ApiRepository();

  String get _unlockCacheKey => 'character_unlocked_cards_${character.id ?? 'unknown'}';

  String get formattedAvatarUrl => (character.avatarUrl ?? '').replaceAll('localhost:8000', '20.198.254.31:7005');

  String? get highestUnlockedCardUrl {
    if (character.cards != null && character.cards!.isNotEmpty) {
      return (character.cards![0]['image_url'] ?? '').toString().replaceAll('localhost:8000', '20.198.254.31:7005');
    }
    return null;
  }

  String get formattedCreatorName {
    final name = character.creatorUsername ?? 'unknown';
    return "Created by ".tr + (name.startsWith('@') ? name : '@$name');
  }

  @override
  void onInit() {
    super.onInit();
    character = Get.arguments as CharacterModel;
    _bootstrapUnlockedCards();
    _fetchInteractionStats();
  }

  void onBack() {
    AppSetting.showInterstitialAd(
      Get.context!,
      adId: MyAdIdName.interAllAd.getId,
      adDismissed: () async {
        final bool isOrganic = await AdsService.isOrganicAsync();
        if (!isOrganic &&
            FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_full_click) &&
            !AppSetting.isPremiumUser.value) {
          Get.toWithController(
            controllerBuilder: () => AdsFullController(),
            page: () => AdsFullPage(),
          )?.then((_) {
            Get.back();
          });
        } else {
          Get.back();
        }
      },
      onFailed: () {
        Get.back();
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _bootstrapUnlockedCards() {
    _loadUnlockedCardsFromLocal();
    final cards = character.cards ?? [];
    for (int i = 0; i < cards.length; i++) {
      final item = cards[i];
      if (item is! Map) continue;
      final card = Map<String, dynamic>.from(item);
      final cardId = _cardIdOf(card);
      if (cardId == null || cardId.isEmpty) continue;
      final isUnlocked = card['is_unlocked'] == true || card['unlocked'] == true || card['status'] == 'unlocked' || card['unlocked_at'] != null || i == 0;
      if (isUnlocked) {
        unlockedCardIds.add(cardId);
      }
    }
    _saveUnlockedCardsToLocal();
  }

  Future<void> _fetchInteractionStats() async {
    if (character.id == null) return;
    isLoading.value = true;
    try {
      var data = await _apiRepo.getCharacterInteractionWeifu(character.id!);
      if (data != null) {
        interaction.value = InteractionModel.fromJson(data);
        _mergeUnlockedCardsFromInteraction(data);
      }
    } catch (e) {
      print("Error fetching interaction: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _mergeUnlockedCardsFromInteraction(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);
    final dynamic list = map['unlocked_cards'] ?? map['unlocked_card_ids'] ?? map['cards_unlocked'] ?? map['unlockedCards'];
    if (list is List) {
      for (final item in list) {
        if (item is String && item.isNotEmpty) {
          unlockedCardIds.add(item);
        } else if (item is Map) {
          final cardId = (item['_id'] ?? item['id'] ?? item['card_id'])?.toString();
          if (cardId != null && cardId.isNotEmpty) {
            unlockedCardIds.add(cardId);
          }
        }
      }
      _saveUnlockedCardsToLocal();
      update();
    }
  }

  void _loadUnlockedCardsFromLocal() {
    try {
      final raw = AppUtil.getString(_unlockCacheKey);
      if (raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        for (final item in decoded) {
          final id = item?.toString() ?? '';
          if (id.isNotEmpty) unlockedCardIds.add(id);
        }
      }
    } catch (_) {}
  }

  void _saveUnlockedCardsToLocal() {
    try {
      AppUtil.saveString(_unlockCacheKey, jsonEncode(unlockedCardIds.toList()));
    } catch (_) {}
  }

  String? _cardIdOf(Map<String, dynamic> cardData) {
    final raw = cardData['_id'] ?? cardData['id'] ?? cardData['card_id'];
    return raw?.toString();
  }

  bool isCardUnlocked(Map<String, dynamic> cardData, int index) {
    final cardId = _cardIdOf(cardData);
    if (cardId != null && unlockedCardIds.contains(cardId)) return true;
    return index == 0;
  }

  int getUnlockedCardsCount() {
    final cards = character.cards ?? [];
    int count = 0;
    for (int i = 0; i < cards.length; i++) {
      final item = cards[i];
      if (item is! Map) continue;
      final cardData = Map<String, dynamic>.from(item);
      if (isCardUnlocked(cardData, i)) {
        count++;
      }
    }
    return count;
  }

  Future<int> _getCurrentGems() async {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>().currentUser.value?.gems ?? 0;
    }
    final profileData = await _apiRepo.getProfileWeifu();
    if (profileData is Map<String, dynamic>) {
      return profileData['gems'] is num ? (profileData['gems'] as num).toInt() : 0;
    }
    return 0;
  }

  Future<void> onTapCard(Map<String, dynamic> cardData, int index) async {
    if (isCardUnlocked(cardData, index)) {
      final imageUrl = (cardData['image_url'] ?? '').toString().replaceAll('localhost:8000', '20.198.254.31:7005');
      if (imageUrl.isNotEmpty) {
        Get.toWithController(
          controllerBuilder: () => FullScreenImageController(),
          page: () => const FullScreenImagePage(),
          arguments: imageUrl,
          routeName: AppRoutes.FULL_SCREEN_IMAGE,
        );
      }
      return;
    }
    final cardId = _cardIdOf(cardData);
    if (cardId == null || cardId.isEmpty || character.id == null) {
      AppUtil.showNormalToast('Card data is invalid'.tr);
      return;
    }
    if (_unlockingCardIds.contains(cardId)) return;
    final int priceGems = (cardData['price_gems'] is num) ? (cardData['price_gems'] as num).toInt() : 0;
    final int currentGems = await _getCurrentGems();
    if (currentGems < priceGems) {
      final int shortage = priceGems - currentGems;
      await Get.dialog(
        GetBuilder<PopupNotEnoughGemsController>(
          init: PopupNotEnoughGemsController(
            title: "Not enough gems".tr,
            message: "This card needs".tr + "$priceGems" + " gems, you're short".tr + " $shortage" + " gems.\nWatch a reward ad for bonus gems or top up in Premium.".tr,
            onWatchAdSuccess: () async {
              if (Get.isRegistered<ProfileController>()) {
                await Get.find<ProfileController>().fetchProfile();
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
          builder: (_) => const PopupNotEnoughGemsPage(),
        ),
        barrierDismissible: true,
        useSafeArea: false,
      );
      return;
    }
    _unlockingCardIds.add(cardId);
    update();
    try {
      final res = await _apiRepo.unlockCharacterCardWeifu(
        characterId: character.id!,
        cardId: cardId,
      );

      bool isReviewerEnabled = FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.enable_reviewer_add_gems,
      );

      final isSuccess = res != null || isReviewerEnabled;

      if (isSuccess) {
        unlockedCardIds.add(cardId);
        _saveUnlockedCardsToLocal();
        AppUtil.showNormalToast('Card unlocked successfully'.tr);
        if (Get.isRegistered<ProfileController>()) {
          if (isReviewerEnabled) {
            final profile = Get.find<ProfileController>();
            final currGems = profile.currentUser.value?.gems ?? 0;
            profile.currentUser.value?.gems = (currGems - priceGems).clamp(0, 9999999);
            profile.currentUser.refresh();
          } else {
            await Get.find<ProfileController>().fetchProfile();
          }
        }
      } else {
        AppUtil.showNormalToast('Unlock failed. Please try again.'.tr);
      }
    } finally {
      _unlockingCardIds.remove(cardId);
      update();
    }
  }

  void startChat() {
    String bgUrl = character.avatarUrl ?? '';
    if (character.cards != null && character.cards!.isNotEmpty) {
      bgUrl = character.cards![0]['image_url'] ?? bgUrl;
    }
    bgUrl = bgUrl.replaceAll('localhost:8000', '20.198.254.31:7005');

    Get.delete<ChatDetailController>(force: true);
    Get.to(
      () => ChatDetailPage(),
      arguments: {
        'characterId': character.id,
        'characterName': character.name,
        'avatarUrl': (character.avatarUrl ?? '').replaceAll('localhost:8000', '20.198.254.31:7005'),
        'intro': character.introduce ?? '',
        'bgUrl': bgUrl,
      },
      routeName: AppRoutes.CHAT_DETAIL,
    );
  }
}
