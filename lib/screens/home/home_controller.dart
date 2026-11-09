import 'dart:async';
import 'package:cscmobi_app/core/base/base_controller.dart';
import 'package:cscmobi_app/helper/firebase_remote_config_service.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import 'package:cscmobi_app/helper/reward_ads_claim_helper.dart';
import 'package:cscmobi_app/screens/character_detail/character_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../utils/app_setting.dart';
import '../../core/utils/app_util.dart';
import '../../api_rest/api_repository.dart';

import '../../helper/firebase_helper.dart';
import '../../models/category_model.dart';
import '../../models/character_model.dart';
import '../ads_full/ads_full_controller.dart';
import '../ads_full/ads_full_page.dart';
import '../profile/profile_controller.dart';
import '../premium/premium_controller.dart';
import '../premium/premium_page.dart';
import '../../routes/app_pages.dart';
import '../popup_daily_checkin/popup_daily_checkin_controller.dart';
import '../popup_daily_checkin/popup_daily_checkin_page.dart';
import '../character_detail/character_detail_page.dart';
import '../popup_yearly_sale/popup_yearly_sale_controller.dart';
import '../popup_yearly_sale/popup_yearly_sale_page.dart';
import 'home_ad_runtime_flags.dart';
import 'home_inline_ad_models.dart';
import 'home_inline_ad_preload_store.dart';
import '../main_tabbar/main_tabbar_controller.dart';
import '../chats/chats_controller.dart';

class HomeController extends BaseController {
  static const String _kYearlySalePopupShownCount =
      'yearly_sale_popup_shown_count';
  static const int _kMaxYearlySalePopupShows = 2;

  final ApiRepository _apiRepo = ApiRepository();
  final searchEditController = TextEditingController();
  final ScrollController inlineGridScrollController = ScrollController();

  var isLoadingCategories = false.obs;
  var isLoadingCharacters = false.obs;

  var categories = <CategoryModel>[].obs;

  var selectedCategory = Rx<CategoryModel?>(null);

  var searchText = "".obs;

  // ─── Dynamic Native Inline Ads ───
  final RxMap<int, HomeInlineAdSlotStatus> inlineSlotStatusByIndex =
      <int, HomeInlineAdSlotStatus>{}.obs;
  final RxMap<int, bool> inlineSlotAttachPermissionByIndex = <int, bool>{}.obs;
  final RxList<HomeGridPlacement> inlinePlacements = <HomeGridPlacement>[].obs;
  final Set<int> _failedInlineSlots = <int>{};
  final Map<int, DateTime> _queuedInlineAttachSlots = <int, DateTime>{};
  bool _hasUserScrolledInlineGrid = false;
  bool _isGrantingInlineSlotAttachment = false;
  int _highestMountedInlineSlot = -1;
  Timer? _inlineAttachQueueTimer;
  static HomeInlineAdConfig _defaultInlineAdConfig =
      HomeInlineAdConfig.homeInline();

  /// Số content items giữa các native inline ad, mặc định 3.
  int get nativeInlineInterval {
    final remote = FirebaseRemoteConfigService.getIntConfigByKey(
      FirebaseRemoteConfigService.native_inline_interval,
    );
    return remote > 0 ? remote : 3;
  }

  void scrollToTop({bool animate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (inlineGridScrollController.hasClients) {
        if (animate) {
          inlineGridScrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        } else {
          inlineGridScrollController.jumpTo(0.0);
        }
      }
    });
  }

  void updateSearchText(String val) {
    searchText.value = val;
    _rebuildInlinePlacements();
    scrollToTop();
  }

  void onGemsCapsuleTap() {
    Get.toWithController(
      controllerBuilder: () => PremiumController(),
      page: () => const PremiumPage(),
      routeName: AppRoutes.PREMIUM,
    );
  }

  @override
  void onInit() {
    super.onInit();
    inlineGridScrollController.addListener(_handleInlineGridScroll);
    fetchCategories();
    _rebuildInlinePlacements();
    FirebaseHelper.setTrackingScreenName("HomeScreen");

    ever(AppSetting.isPremiumUser, (bool isPremium) {
      if (isPremium) {
        onPremiumPurchased();
      }
    });
    ever(AppSetting.isRemoveAds, (bool removeAds) {
      if (removeAds) {
        onPremiumPurchased();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    _showYearlySalePopup();
  }

  void _requestPushNotificationPermission() {
    if (Get.isRegistered<MainTabbarController>()) {
      Get.find<MainTabbarController>().requestPermisstion();
    }
  }

  void _checkAndShowDailyCheckin() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastCheckin = AppSetting().getLastCheckinDate();
    if (lastCheckin != today) {
      // Delay slightly to ensure UI is ready after previous popup closes
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!Get.isRegistered<HomeController>()) return;
        if (Get.isDialogOpen == true) {
          _requestPushNotificationPermission();
          return;
        }
        Get.dialog(
          GetBuilder<PopupDailyCheckinController>(
            init: PopupDailyCheckinController(),
            builder: (_) => const PopupDailyCheckinPage(),
          ),
          barrierDismissible: true,
          useSafeArea: false,
        ).then((_) {
          _requestPushNotificationPermission();
        });
      });
    } else {
      _requestPushNotificationPermission();
    }
  }

  @override
  void onClose() {
    inlineGridScrollController.removeListener(_handleInlineGridScroll);
    inlineSlotAttachPermissionByIndex.clear();
    inlineSlotStatusByIndex.clear();
    _failedInlineSlots.clear();
    HomeInlineAdPreloadStore.clearAll();

    searchEditController.dispose();
    inlineGridScrollController.dispose();
    _inlineAttachQueueTimer?.cancel();
    _isGrantingInlineSlotAttachment = false;
    _queuedInlineAttachSlots.clear();
    inlinePlacements.clear();



    super.onClose();
  }



  // ─── Dynamic Native Inline Ads ───

  /// Tính toán số ad tối đa cần load dựa trên charCount và interval.
  int _calcMaxAdsNeeded(int charCount) {
    if (charCount <= 0) return 0;
    final interval = nativeInlineInterval;
    // Ad đầu tiên sau content 0, rồi cách interval item
    // Slot 0: sau content index 0 (tổng content cần >= 1)
    // Slot 1: sau content index 0 + interval (tổng cần >= 1 + interval)
    // ...
    // Slot n: tổng cần >= 1 + n * interval
    int maxSlots = 0;
    while (1 + maxSlots * interval <= charCount) {
      maxSlots++;
    }
    return maxSlots;
  }

  bool get canLoadInlineAds {
    if (!HomeAdRuntimeFlags.enableInlineAds) {
      return false;
    }
    if (!FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_card)) {
      return false;
    }
    if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
      return false;
    }
    return true;
  }

  int calcInlineAdSlotsNeeded(int charCount) => _calcMaxAdsNeeded(charCount);

  List<HomeGridPlacement> buildContentOnlyPlacements(int charCount) {
    return List<HomeGridPlacement>.generate(
      charCount,
      (index) => HomeGridPlacement.content(index),
      growable: false,
    );
  }

  HomeInlineAdSlotStatus getInlineSlotStatus(int slotIndex) {
    if (_failedInlineSlots.contains(slotIndex) ||
        HomeInlineAdPreloadStore.hasFailedSlot(slotIndex)) {
      return HomeInlineAdSlotStatus.failed;
    }
    return inlineSlotStatusByIndex[slotIndex] ?? HomeInlineAdSlotStatus.idle;
  }

  HomeInlineAdConfig getInlineAdConfig(int slotIndex) {
    return _defaultInlineAdConfig;
  }

  bool canAttachInlineSlot(int slotIndex) {
    return inlineSlotAttachPermissionByIndex[slotIndex] ?? false;
  }

  void recycleInlineAd(int slotIndex, NativeAd ad) {
    if (_failedInlineSlots.contains(slotIndex)) {
      ad.dispose();
      return;
    }
    HomeInlineAdPreloadStore.recycleSlotAd(slotIndex, ad);
  }

  void markInlineSlotLoading(int slotIndex) {
    if (_failedInlineSlots.contains(slotIndex)) return;
    inlineSlotStatusByIndex[slotIndex] = HomeInlineAdSlotStatus.loading;
  }

  void onInlineSlotAdLoaded(int slotIndex) {
    if (_failedInlineSlots.contains(slotIndex)) return;
    inlineSlotStatusByIndex[slotIndex] = canAttachInlineSlot(slotIndex)
        ? HomeInlineAdSlotStatus.loaded
        : HomeInlineAdSlotStatus.ready;
    _queueInlineSlotAttachment(slotIndex);
  }

  void markInlineSlotAttached(int slotIndex) {
    if (_failedInlineSlots.contains(slotIndex)) return;
    inlineSlotStatusByIndex[slotIndex] = HomeInlineAdSlotStatus.loaded;
  }

  void markInlineSlotFailed(int slotIndex) {
    _failedInlineSlots.add(slotIndex);
    HomeInlineAdPreloadStore.markSlotFailed(slotIndex);
    _queuedInlineAttachSlots.remove(slotIndex);
    inlineSlotAttachPermissionByIndex.remove(slotIndex);
    inlineSlotStatusByIndex[slotIndex] = HomeInlineAdSlotStatus.failed;
    _rebuildInlinePlacements();
  }

  void handleInlineSlotWidgetDisposed(
    int slotIndex, {
    bool preserveLoadedState = false,
  }) {
    if (_failedInlineSlots.contains(slotIndex)) return;
    if (preserveLoadedState &&
        (getInlineSlotStatus(slotIndex) == HomeInlineAdSlotStatus.loaded ||
            getInlineSlotStatus(slotIndex) == HomeInlineAdSlotStatus.ready)) {
      return;
    }
    _queuedInlineAttachSlots.remove(slotIndex);
    inlineSlotAttachPermissionByIndex.remove(slotIndex);
    if (!inlineSlotStatusByIndex.containsKey(slotIndex)) return;
    inlineSlotStatusByIndex[slotIndex] = HomeInlineAdSlotStatus.idle;
  }

  Future<NativeAd?> claimOrLoadInlineAd(
    int slotIndex, {
    required HomeInlineAdConfig adConfig,
  }) {
    return HomeInlineAdPreloadStore.claimOrLoadSlot(
      slotIndex,
      config: adConfig,
      source: 'home_widget',
    );
  }

  void onInlineSlotBecameRelevant(int slotIndex) {
    if (slotIndex > _highestMountedInlineSlot) {
      _highestMountedInlineSlot = slotIndex;
    }
    if (_hasUserScrolledInlineGrid) {
      _prefetchNextInlineSlotIfNeeded();
    }
  }

  DateTime _lastScrollCheckTime = DateTime.fromMillisecondsSinceEpoch(0);

  void _handleInlineGridScroll() {
    if (!inlineGridScrollController.hasClients) return;
    if (inlineGridScrollController.offset <= 24) return;

    _hasUserScrolledInlineGrid = true;
    final now = DateTime.now();
    if (now.difference(_lastScrollCheckTime).inMilliseconds < 150) return;
    _lastScrollCheckTime = now;

    _expediteLoadedInlineSlotAttachments();
    _prefetchNextInlineSlotIfNeeded();
  }

  void _prefetchNextInlineSlotIfNeeded() {
    if (!canLoadInlineAds || !_hasUserScrolledInlineGrid) return;

    final maxSlots = _calcMaxAdsNeeded(filteredCharacters.length);
    if (maxSlots <= 1) return;

    final nextSlotIndex =
        (_highestMountedInlineSlot >= 1 ? _highestMountedInlineSlot : 1) + 1;
    if (nextSlotIndex >= maxSlots) return;

    final slotStatus = getInlineSlotStatus(nextSlotIndex);
    if (slotStatus == HomeInlineAdSlotStatus.failed ||
        slotStatus == HomeInlineAdSlotStatus.loading ||
        slotStatus == HomeInlineAdSlotStatus.ready ||
        slotStatus == HomeInlineAdSlotStatus.loaded) {
      return;
    }
    if (HomeInlineAdPreloadStore.hasReadySlot(nextSlotIndex) ||
        HomeInlineAdPreloadStore.isLoadingSlot(nextSlotIndex)) {
      return;
    }

    FirebaseHelper.logEventName(
      'home_inline_prefetch_next_slot',
      param: 'slot_$nextSlotIndex',
    );
    HomeInlineAdPreloadStore.warmSlot(
      nextSlotIndex,
      config: getInlineAdConfig(nextSlotIndex),
      source: 'home_scroll',
    ).then((loadedAd) {
      if (isClosed || loadedAd != null) return;
      markInlineSlotFailed(nextSlotIndex);
    });
  }

  void _queueInlineSlotAttachment(int slotIndex) {
    if (_failedInlineSlots.contains(slotIndex)) return;
    if (canAttachInlineSlot(slotIndex)) return;

    final delayMs = _inlineAttachDelayMs(slotIndex);
    _queuedInlineAttachSlots[slotIndex] =
        DateTime.now().add(Duration(milliseconds: delayMs));
    _drainInlineAttachQueue();
  }

  int _inlineAttachDelayMs(int slotIndex) {
    if (slotIndex == 0) {
      return 0;
    }
    if (slotIndex == 1 && !_hasUserScrolledInlineGrid) {
      return 1200;
    }
    return 350;
  }

  void _expediteLoadedInlineSlotAttachments() {
    final now = DateTime.now();
    for (final entry in inlineSlotStatusByIndex.entries) {
      if (entry.value != HomeInlineAdSlotStatus.loaded &&
          entry.value != HomeInlineAdSlotStatus.ready) {
        continue;
      }
      if (canAttachInlineSlot(entry.key)) continue;
      _queuedInlineAttachSlots[entry.key] = now;
    }
    _drainInlineAttachQueue();
  }

  void _drainInlineAttachQueue() {
    if (_isGrantingInlineSlotAttachment || _queuedInlineAttachSlots.isEmpty) {
      return;
    }
    _inlineAttachQueueTimer?.cancel();

    final now = DateTime.now();
    final readySlots = _queuedInlineAttachSlots.entries
        .where((entry) => !entry.value.isAfter(now))
        .map((entry) => entry.key)
        .toList()
      ..sort();

    if (readySlots.isEmpty) {
      final earliest = _queuedInlineAttachSlots.values.reduce(
        (current, next) => current.isBefore(next) ? current : next,
      );
      final wait = earliest.difference(now);
      _inlineAttachQueueTimer = Timer(wait, _drainInlineAttachQueue);
      return;
    }

    final slotIndex = readySlots.first;
    _queuedInlineAttachSlots.remove(slotIndex);
    _grantInlineSlotAttachment(slotIndex);
  }

  void _grantInlineSlotAttachment(int slotIndex) {
    if (_failedInlineSlots.contains(slotIndex)) {
      _drainInlineAttachQueue();
      return;
    }

    _isGrantingInlineSlotAttachment = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || _failedInlineSlots.contains(slotIndex)) {
        _isGrantingInlineSlotAttachment = false;
        _drainInlineAttachQueue();
        return;
      }

      inlineSlotAttachPermissionByIndex[slotIndex] = true;
      markInlineSlotAttached(slotIndex);
      FirebaseHelper.logEventName(
        'home_inline_attach_granted',
        param: 'slot_$slotIndex',
      );

      final settleDelay = slotIndex == 0 ? 250 : 500;
      _inlineAttachQueueTimer = Timer(Duration(milliseconds: settleDelay), () {
        _isGrantingInlineSlotAttachment = false;
        _drainInlineAttachQueue();
      });
    });
  }

  void _syncInlineSlotStates(int charCount) {
    final maxSlots = _calcMaxAdsNeeded(charCount);
    final nextStateMap = <int, HomeInlineAdSlotStatus>{};

    for (int slotIndex = 0; slotIndex < maxSlots; slotIndex++) {
      if (_failedInlineSlots.contains(slotIndex)) {
        nextStateMap[slotIndex] = HomeInlineAdSlotStatus.failed;
        continue;
      }

      nextStateMap[slotIndex] =
          inlineSlotStatusByIndex[slotIndex] ?? HomeInlineAdSlotStatus.idle;
    }

    inlineSlotStatusByIndex
      ..clear()
      ..addAll(nextStateMap);
  }

  void _rebuildInlinePlacements() {
    final chars = filteredCharacters;
    if (chars.isEmpty) {
      _inlineAttachQueueTimer?.cancel();
      _isGrantingInlineSlotAttachment = false;
      _queuedInlineAttachSlots.clear();
      inlinePlacements.clear();
      inlineSlotAttachPermissionByIndex.clear();
      inlineSlotStatusByIndex.clear();
      _highestMountedInlineSlot = -1;
      HomeInlineAdPreloadStore.clearAll();
      return;
    }

    if (!canLoadInlineAds) {
      _inlineAttachQueueTimer?.cancel();
      _isGrantingInlineSlotAttachment = false;
      _queuedInlineAttachSlots.clear();
      inlinePlacements.assignAll(buildContentOnlyPlacements(chars.length));
      inlineSlotAttachPermissionByIndex.clear();
      inlineSlotStatusByIndex.clear();
      _highestMountedInlineSlot = -1;
      HomeInlineAdPreloadStore.clearAll();
      return;
    }

    final maxSlots = _calcMaxAdsNeeded(chars.length);
    _syncInlineSlotStates(chars.length);
    _queuedInlineAttachSlots
        .removeWhere((slotIndex, _) => slotIndex >= maxSlots);
    inlineSlotAttachPermissionByIndex.removeWhere(
      (slotIndex, _) => slotIndex >= maxSlots,
    );
    HomeInlineAdPreloadStore.disposeUnusedSlots(
      List<int>.generate(maxSlots, (index) => index),
    );
    if (_highestMountedInlineSlot >= maxSlots) {
      _highestMountedInlineSlot = maxSlots - 1;
    }

    final placements = <HomeGridPlacement>[];
    int nextSlotIndex = 0;

    for (int charIndex = 0; charIndex < chars.length; charIndex++) {
      placements.add(HomeGridPlacement.content(charIndex));

      final charsConsumed = charIndex + 1;
      if (nextSlotIndex < maxSlots &&
          charsConsumed == 1 + nextSlotIndex * nativeInlineInterval) {
        final slotStatus = getInlineSlotStatus(nextSlotIndex);
        if (slotStatus != HomeInlineAdSlotStatus.failed) {
          placements.add(HomeGridPlacement.inlineAd(nextSlotIndex));
        }
        nextSlotIndex++;
      }
    }

    inlinePlacements.assignAll(placements);
  }

  /// Giữ API cũ để không làm vỡ call-site khác.
  void loadInlineNativeAds() {
    _rebuildInlinePlacements();
  }

  // ─── Categories & Characters ───

  CharacterModel? getCharacterById(String charId) {
    if (charId.isEmpty) return null;
    for (final cat in categories) {
      final chars = cat.characters ?? [];
      for (final c in chars) {
        if (c.id == charId) {
          return c;
        }
      }
    }
    return null;
  }

  void fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      var data = await _apiRepo.getCategoriesWeifu();
      var cats = data.map((e) => CategoryModel.fromJson(e)).toList();
      categories.assignAll(cats);
      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
      }
      _rebuildInlinePlacements();
      if (Get.isRegistered<ChatsController>()) {
        Get.find<ChatsController>().updateSessionLocalizations();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void selectCategory(CategoryModel? category) {
    selectedCategory.value = category;
    _rebuildInlinePlacements();
    scrollToTop();
  }

  List<CharacterModel> get filteredCharacters {
    if (selectedCategory.value == null) {
      return [];
    }
    var list = selectedCategory.value!.characters ?? [];
    if (searchText.value.isNotEmpty) {
      list = list
          .where((c) => (c.name ?? "")
              .toLowerCase()
              .contains(searchText.value.toLowerCase()))
          .toList();
    }
    return list;
  }

  onSelectBonusGem() {
    RewardAdsClaimHelper.runClaimFlow(apiRepository: _apiRepo);

    //test
    // Get.dialog(
    //   GetBuilder<PopupCheckinSuccessController>(
    //     init: PopupCheckinSuccessController(),
    //     builder: (_) => const PopupCheckinSuccessPage(),
    //   ),
    //   barrierDismissible: true,
    //   useSafeArea: false,
    // );

    // //test
    // Get.dialog(
    //   GetBuilder<PopupOutOfGemsController>(
    //     init: PopupOutOfGemsController(onWatchAdSuccess: () {
    //       // addExtraFreeUsage(featureId);
    //       // onProceed();
    //     }),
    //     builder: (controller) => const PopupOutOfGemsPage(),
    //   ),
    //   barrierDismissible: true,
    //   useSafeArea: false,
    // );
  }

  String formatLikes(int likes) {
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    }
    return likes.toString();
  }

  void goToCharacterDetail(CharacterModel char) {
    final nextScreen = () async {
      Get.toWithController(
          controllerBuilder: () => CharacterDetailController(),
          page: () => CharacterDetailPage(),
          arguments: char,
          routeName: AppRoutes.DETAIL);
    };

    AppSetting.showInterstitialAd(
      Get.context!,
      adId: MyAdIdName.interAllAd.getId,
      adDismissed: () async {
        final bool isOrganic = await AdsService.isOrganicAsync();
        if (!isOrganic &&
            FirebaseRemoteConfigService.getBoolConfigByKey(
                FirebaseRemoteConfigService.native_full_click) &&
            !AppSetting.isPremiumUser.value) {
          await Get.toWithController(
              controllerBuilder: () => AdsFullController(),
              page: () => AdsFullPage());
          nextScreen();
        } else {
          nextScreen();
        }
      },
      onFailed: nextScreen,
    );
  }

  String getFormattedAvatar(CharacterModel char) {
    return (char.avatarUrl ?? '')
        .replaceAll('localhost:8000', '20.198.254.31:7005');
  }

  ProfileController get profileController =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  void onPremiumPurchased() {
    _inlineAttachQueueTimer?.cancel();
    _isGrantingInlineSlotAttachment = false;
    _queuedInlineAttachSlots.clear();
    inlinePlacements.clear();
    inlineSlotAttachPermissionByIndex.clear();
    inlineSlotStatusByIndex.clear();
    _highestMountedInlineSlot = -1;
    HomeInlineAdPreloadStore.clearAll();
    _rebuildInlinePlacements();
    update();
  }

  void _showYearlySalePopup() {
    if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
      _checkAndShowDailyCheckin();
      return;
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!Get.isRegistered<HomeController>()) return;
      if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
        _checkAndShowDailyCheckin();
        return;
      }
      if (Get.isDialogOpen == true) {
        _checkAndShowDailyCheckin();
        return;
      }
      final shownCount = AppUtil.getInt(_kYearlySalePopupShownCount);
      if (shownCount >= _kMaxYearlySalePopupShows) {
        _checkAndShowDailyCheckin();
        return;
      }
      AppUtil.saveInt(_kYearlySalePopupShownCount, shownCount + 1);
      Get.dialog(
        GetBuilder<PopupYearlySaleController>(
          init: PopupYearlySaleController(),
          builder: (_) => const PopupYearlySalePage(),
        ),
        barrierDismissible: true,
        useSafeArea: false,
      ).then((_) {
        _checkAndShowDailyCheckin();
      });
    });
  }
}
