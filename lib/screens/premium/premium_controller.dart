import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api_rest/api_repository.dart';
import '../../core/base/base_controller.dart';
import '../../core/utils/app_util.dart';
import '../../core/values/constants.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../helper/iap_helper.dart';
import '../../helper/reward_ads_claim_helper.dart';
import '../../models/premium.dart';
import '../../routes/app_pages.dart';
import '../../utils/Utils.dart';
import '../../utils/app_setting.dart';
import '../home/home_ad_preload_coordinator.dart';
import '../main_tabbar/main_tabbar_controller.dart';
import '../main_tabbar/main_tabbar_page.dart';
import '../popup_checkin_success/popup_checkin_success_controller.dart';
import '../popup_checkin_success/popup_checkin_success_page.dart';
import '../profile/profile_controller.dart';

class PremiumCoinItem {
  final String productId;
  final int displayCoin;
  final int baseCoin;
  final int bonusCoin;
  final double fallbackPrice;
  final String? badgeText;

  const PremiumCoinItem({
    required this.productId,
    required this.displayCoin,
    required this.baseCoin,
    required this.bonusCoin,
    required this.fallbackPrice,
    this.badgeText,
  });
}

class PremiumController extends BaseController {
  ProfileController get profileController =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  /// 0 = VIP (gems), 1 = Shop (sub), 2 = Mission
  final selectedTabIndex = 0.obs;

  final selectedGemIndex = 0.obs;

  // ─── Daily Check-in state ───
  final ApiRepository _checkinApiRepo = ApiRepository();
  final AppSetting _checkinAppSetting = AppSetting();
  var checkinStreak = 0.obs;
  var isCheckinClaiming = false.obs;
  var checkinRewards = <int>[0, 5, 5, 8, 5, 5, 8, 10].obs; // Index 1-7
  var canCheckinToday = true.obs;
  var adsWatchedToday = 0.obs;
  var maxAdsPerDay = 5.obs;
  var adsRewardGems = 8.obs;

  final _coinProductOrder = <String>[
    IAPHelper.itemCoin1,
    IAPHelper.itemCoin2,
    IAPHelper.itemCoin3,
    IAPHelper.itemCoin4,
    IAPHelper.itemCoin5,
    IAPHelper.itemCoin6,
  ];

  static final _coinTemplateByProductId = <String, PremiumCoinItem>{
    IAPHelper.itemCoin1: const PremiumCoinItem(
      productId: "lovery.coin.p01",
      displayCoin: 100,
      baseCoin: 100,
      bonusCoin: 0,
      fallbackPrice: 1.99,
    ),
    IAPHelper.itemCoin2: const PremiumCoinItem(
      productId: "lovery.coin.p02",
      displayCoin: 220,
      baseCoin: 200,
      bonusCoin: 20,
      fallbackPrice: 3.99,
      badgeText: '+10%',
    ),
    IAPHelper.itemCoin3: const PremiumCoinItem(
      productId: "lovery.coin.p03",
      displayCoin: 550,
      baseCoin: 500,
      bonusCoin: 50,
      fallbackPrice: 6.99,
      badgeText: '+10%',
    ),
    IAPHelper.itemCoin4: const PremiumCoinItem(
      productId: "lovery.coin.p04",
      displayCoin: 1200,
      baseCoin: 1000,
      bonusCoin: 200,
      fallbackPrice: 9.99,
      badgeText: '+20% Elite Choice',
    ),
    IAPHelper.itemCoin5: const PremiumCoinItem(
      productId: "lovery.coin.p05",
      displayCoin: 2400,
      baseCoin: 2000,
      bonusCoin: 400,
      fallbackPrice: 19.99,
      badgeText: '+20%',
    ),
    IAPHelper.itemCoin6: const PremiumCoinItem(
      productId: "lovery.coin.p06",
      displayCoin: 5200,
      baseCoin: 4000,
      bonusCoin: 1200,
      fallbackPrice: 29.99,
      badgeText: "+30% Best Offer",
    ),
    // Hyphen aliases
    "lovery-coin-p01": const PremiumCoinItem(
      productId: "lovery.coin.p01",
      displayCoin: 100,
      baseCoin: 100,
      bonusCoin: 0,
      fallbackPrice: 1.99,
    ),
    "lovery-coin-p02": const PremiumCoinItem(
      productId: "lovery.coin.p02",
      displayCoin: 220,
      baseCoin: 200,
      bonusCoin: 20,
      fallbackPrice: 3.99,
      badgeText: '+10%',
    ),
    "lovery-coin-p03": const PremiumCoinItem(
      productId: "lovery.coin.p03",
      displayCoin: 550,
      baseCoin: 500,
      bonusCoin: 50,
      fallbackPrice: 6.99,
      badgeText: '+10%',
    ),
    "lovery-coin-p04": const PremiumCoinItem(
      productId: "lovery.coin.p04",
      displayCoin: 1200,
      baseCoin: 1000,
      bonusCoin: 200,
      fallbackPrice: 9.99,
      badgeText: '+20% Elite Choice',
    ),
    "lovery-coin-p05": const PremiumCoinItem(
      productId: "lovery.coin.p05",
      displayCoin: 2400,
      baseCoin: 2000,
      bonusCoin: 400,
      fallbackPrice: 19.99,
      badgeText: '+20%',
    ),
    "lovery-coin-p06": const PremiumCoinItem(
      productId: "lovery.coin.p06",
      displayCoin: 5200,
      baseCoin: 4000,
      bonusCoin: 1200,
      fallbackPrice: 29.99,
      badgeText: "+30% Best Offer",
    ),
  };

  Worker? _checkoutUiWorker;

  // —— Shop (subscription), ported from Premium2Controller ——
  final itemSelected = 1.obs;
  final titleButton = 'Continue'.obs;
  List<Premium> listPremium = [];
  List<ProductDetails> listProduct = [];
  bool isFromSplash = false;

  RxList<String> listTitlePremium = <String>[].obs;

  List<PremiumCoinItem> get coinItems {
    final items = <PremiumCoinItem>[];
    for (final productId in _coinProductOrder) {
      final item = _coinTemplateByProductId[productId];
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  var percentSave = 58;

  @override
  void onInit() {
    super.onInit();
    FirebaseHelper.setTrackingScreenName('PremiumScreen');
    _checkoutUiWorker = ever(IAPHelper.checkoutBusy, (_) => update());

    final profileCtrl = profileController;
    ever(profileCtrl.checkinStatusData, (data) {
      if (data != null) {
        if (data['ads_claimed_today'] != null) {
          adsWatchedToday.value = (data['ads_claimed_today'] as num).toInt();
        }
        if (data['ads_max_per_day'] != null) {
          maxAdsPerDay.value = (data['ads_max_per_day'] as num).toInt();
        }
        update();
      }
    });

    if (Get.arguments != null && Get.arguments['isFromSplash'] == true) {
      isFromSplash = true;
    }
    _ensureProductsLoaded();
    _loadCheckinData();
    if (FirebaseRemoteConfigService.getIntConfigByKey(FirebaseRemoteConfigService.percentSaveVIP) > 0) {
      percentSave = FirebaseRemoteConfigService.getIntConfigByKey(FirebaseRemoteConfigService.percentSaveVIP);
    }
    listTitlePremium.assignAll([
      "Enjoy Unlimited Chats".tr,
      "Unlock Outfit Selections".tr,
      "Get 1000 Gems Bonus".tr,
      "Faster AI Replies".tr,
      "More Image Choices".tr,
      "Character creation".tr,
    ]);
  }

  @override
  void onClose() {
    _checkoutUiWorker?.dispose();
    super.onClose();
  }

  Future<void> _ensureProductsLoaded() async {
    await IAPHelper.loadProducts();
    initSubPremiumData();
    final gems = coinItems;
    if (gems.isNotEmpty) {
      selectedGemIndex.value = selectedGemIndex.value.clamp(0, gems.length - 1);
    }
    update();
  }

  void selectTab(int index) {
    if (index < 0 || index > 2) return;
    selectedTabIndex.value = index;
  }

  void selectGemPack(int index) {
    if (index < 0 || index >= coinItems.length) return;
    selectedGemIndex.value = index;
  }

  /// Thứ tự: [0] = monthly (trái), [1] = yearly (phải).
  void initSubPremiumData() {
    final oCcy = NumberFormat('#,##0.00', 'en_US');
    final oCcy2 = NumberFormat('#,##0', 'en_US');
    listProduct = IAPHelper.products;
    listPremium.clear();

    var packageMonthly = Premium(
      title: '1 Month VIP'.tr,
      price: 9.99,
      saleOff: 50,
      desc: 'Trial 3-day'.tr,
      packageId: IAPHelper.itemMonthly,
    );
    packageMonthly.note = '';
    final monthlyProduct = listProduct.firstWhereOrNull(
        (model) => model.id == IAPHelper.itemMonthly && model.rawPrice > 0);
    if (monthlyProduct != null) {
      packageMonthly.price = monthlyProduct.rawPrice;
      packageMonthly.currencySymbol = monthlyProduct.currencySymbol;
      if (packageMonthly.currencySymbol.isEmpty) {
        final currencyCode = monthlyProduct.currencyCode;
        packageMonthly.currencySymbol = Utils().getCurrencySymbol(currencyCode);
        if (packageMonthly.currencySymbol.isEmpty) {
          packageMonthly.currencySymbol = monthlyProduct.price
              .replaceAll(RegExp(r'[0-9.,!?;:(){}[\]]'), '');
        }
      }
      if (monthlyProduct.rawPrice % 1 != 0) {
        packageMonthly.desc =
            '${oCcy.format(monthlyProduct.rawPrice)}${packageMonthly.currencySymbol}'+ '/month'.tr +
                '. ' +
                'Cancel any time'.tr;
      } else {
        packageMonthly.desc =
            '${oCcy2.format(monthlyProduct.rawPrice)}${packageMonthly.currencySymbol}' +
                '/month'.tr +
                '. ' +
                'Cancel any time'.tr;
      }
    }
    listPremium.add(packageMonthly);

    var packageYearly = Premium(
      title: '1 Year SVIP'.tr,
      price: 49.99,
      saleOff: 50,
      desc: 'Auto renew'.tr,
      packageId: IAPHelper.itemYearly,
    );
    packageYearly.note = ''.tr;
    final yearlyProduct = listProduct.firstWhereOrNull(
        (model) => model.id == IAPHelper.itemYearly && model.rawPrice > 0);
    if (yearlyProduct != null) {
      packageYearly.price = yearlyProduct.rawPrice;
      packageYearly.desc = 'Get 3 Days free trial'.tr;
      packageYearly.currencySymbol = yearlyProduct.currencySymbol;
      if (packageYearly.currencySymbol.isEmpty) {
        final currencyCode = yearlyProduct.currencyCode;
        packageYearly.currencySymbol = Utils().getCurrencySymbol(currencyCode);
        if (packageYearly.currencySymbol.isEmpty) {
          packageYearly.currencySymbol =
              yearlyProduct.price.replaceAll(RegExp(r'[0-9.,!?;:(){}[\]]'), '');
        }
      }
      if (yearlyProduct.rawPrice % 1 != 0) {
        packageYearly.desc =
            '${oCcy.format(yearlyProduct.rawPrice)}${packageYearly.currencySymbol}'+ '/year. Cancel any time'.tr;
        packageYearly.note = '';
      } else {
        packageYearly.desc =
            '${oCcy2.format(yearlyProduct.rawPrice)}${packageYearly.currencySymbol}'+ '/year. Cancel any time'.tr;
        packageYearly.note = '';
      }
    }
    listPremium.add(packageYearly);

    _syncSubTitlesToSelection();
  }

  void _syncSubTitlesToSelection() {
    if (listPremium.isEmpty) return;
    final idx = itemSelected.value.clamp(0, listPremium.length - 1);
    if (listPremium[idx].packageId == IAPHelper.itemMonthly) {
      titleButton.value = "Continue".tr;
      listTitlePremium.assignAll([
        "Enjoy Unlimited Chats".tr,
        "Ad-free Experience".tr,
        "Get 300 Gems Bonus".tr,
        "Faster AI Replies".tr,
      ]);
    } else {
      titleButton.value = "Continue".tr;
      listTitlePremium.assignAll([
        "Enjoy Unlimited Chats".tr,
        "Unlock Outfit Selections".tr,
        "Get 1000 Gems Bonus".tr,
        "Faster AI Replies".tr,
        "More Image Choices".tr,
        "Character creation".tr,
      ]);
    }
  }

  void onSelectSubItem(int index) {
    if (index < 0 || index >= listPremium.length) return;
    itemSelected.value = index;
    _syncSubTitlesToSelection();
    update();
  }

  void onSelectSubBuy() {
    if (AppSetting.isPremiumUser.value) {
      AppUtil.showNormalToast('You are already a premium user'.tr);
      return;
    }
    if (listPremium.isEmpty) return;
    try {
      FirebaseHelper.logEventName(FirebaseHelper.paywall_view, param: '');
      final id = listPremium[itemSelected.value].packageId;
      if (id == IAPHelper.itemYearly) {
        IAPHelper.purchaseSubscriptionYearly();
      } else if (id == IAPHelper.itemMonthly) {
        IAPHelper.purchaseSubscriptionMonthly();
      }
    } catch (_) {}
  }

  void onSelectRestore() async {
    if (AppSetting.isPremiumUser.value) {
      AppUtil.showNormalToast('You are already a premium user'.tr);
      return;
    }
    AppUtil.showLoading();
    await IAPHelper.restorePurchases(isUserTriggered: true);
    AppUtil.hideLoading();
  }

  void onSelectTermOfUse() {
    launchUrl(Uri.parse(Constants.termOfUser),
        mode: LaunchMode.externalApplication);
  }

  void onSelectPrivacy() {
    launchUrl(Uri.parse(Constants.privacy),
        mode: LaunchMode.externalApplication);
  }

  void onSelectBack() {
    if (isFromSplash) {
      HomeAdPreloadCoordinator.preloadBeforeHome(source: 'premium_back');
      Get.offAllWithController(
        controllerBuilder: () => MainTabbarController(),
        page: () => MainTabbarPage(),
        routeName: AppRoutes.HOME,
      );
    } else {
      Get.back();
    }
  }

  ProductDetails? getProduct(String productId) {
    return IAPHelper.getProductById(productId);
  }

  String getProductPrice(String productId) {
    final p = getProduct(productId);
    if (p != null && p.price.isNotEmpty) return p.price;
    final item = _coinTemplateByProductId[productId];
    if (item != null) {
      return '\$${item.fallbackPrice.toStringAsFixed(2)}';
    }
    return '...';
  }

  String getSubDisplayPrice(Premium package) {
    final product = getProduct(package.packageId);
    if (product != null) return product.price;

    final symbol =
        package.currencySymbol.isNotEmpty ? package.currencySymbol : '\$';
    final precision = package.price % 1 == 0 ? 0 : 2;
    return '$symbol${package.price.toStringAsFixed(precision)}';
  }

  String getSubPerDayText(Premium package, {required int perDayDivisor}) {
    final product = getProduct(package.packageId);
    final raw = product?.rawPrice ?? package.price;
    final symbol = (product?.currencySymbol.isNotEmpty ?? false)
        ? product!.currencySymbol
        : (package.currencySymbol.isNotEmpty ? package.currencySymbol : '\$');
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${formatter.format(raw / perDayDivisor)}' + '/day'.tr;
  }

  /// Nút chính: VIP = mua gói gem đang chọn; Shop = mua sub đang chọn.
  Future<void> onContinuePrimary() async {
    if (selectedTabIndex.value == 0) {
      final items = coinItems;
      if (items.isEmpty) return;
      final i = selectedGemIndex.value.clamp(0, items.length - 1);
      await onTapCoinPack(items[i]);
    } else if (selectedTabIndex.value == 1) {
      onSelectSubBuy();
    }
  }

  Future<void> onTapCoinPack(PremiumCoinItem item) async {
    await _purchase(item.productId);
  }

  Future<void> _purchase(String productId) async {
    final _ = profileController; // Ensure ProfileController is initialized
    if (IAPHelper.checkoutBusy.value) return;

    try {
      await IAPHelper.purchaseByProductId(productId);
    } catch (e) {
      AppUtil.showNormalToast('Purchase failed. Please try again.'.tr);
    }
    update();
  }

  void onTapClaimMission() {
    RewardAdsClaimHelper.runClaimFlow(onWatchAdSuccess: () {
      profileController.fetchProfile();
      adsWatchedToday.value = _checkinAppSetting.getCountWatchAdReward() ?? 0;
      update();
    });
  }

  // ─── Daily Check-in Logic ───

  Future<void> _loadCheckinData() async {
    // Load ads watched count from local as initial fallback
    adsWatchedToday.value = _checkinAppSetting.getCountWatchAdReward() ?? 0;

    // Local fallback
    final lastCheckin = _checkinAppSetting.getLastCheckinDate();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

    int savedStreak = _checkinAppSetting.getCheckinStreak();
    if (lastCheckin.isNotEmpty && lastCheckin != today && lastCheckin != yesterday) {
      savedStreak = 0;
      _checkinAppSetting.saveCheckinStreak(0);
    }
    if (savedStreak >= 7 && lastCheckin != today) {
      savedStreak = 0;
      _checkinAppSetting.saveCheckinStreak(0);
    }
    checkinStreak.value = savedStreak;

    // Check if ProfileController already has cached data
    Map<String, dynamic>? res;
    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      if (profileCtrl.checkinStatusData.value != null) {
        res = profileCtrl.checkinStatusData.value;
      }
    }
    if (res == null) {
      res = await _checkinApiRepo.dailyCheckinStatusWeifu();
    }

    if (res != null) {
      checkinStreak.value = res['current_streak'] ?? 0;
      canCheckinToday.value = res['can_claim_today'] ?? false;
      
      // Sync ads data from server
      if (res['ads_claimed_today'] != null) {
        adsWatchedToday.value = res['ads_claimed_today'];
      }
      if (res['ads_max_per_day'] != null) {
        maxAdsPerDay.value = (res['ads_max_per_day'] as num).toInt();
      }
      if (res['ads_reward_gems'] != null) {
        adsRewardGems.value = (res['ads_reward_gems'] as num).toInt();
      }

      if (res['rewards'] != null && res['rewards'] is List) {
        for (var item in res['rewards']) {
          int d = item['day'];
          int g = item['gems'];
          if (d >= 1 && d <= 7) {
            checkinRewards[d] = g;
          }
        }
      }
    }
    update();
  }

  Future<void> onCheckin() async {
    if (isCheckinClaiming.value) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (!canCheckinToday.value || _checkinAppSetting.getLastCheckinDate() == today) {
      AppUtil.showNormalToast("You have already checked in today.".tr);
      return;
    }

    isCheckinClaiming.value = true;
    final targetDayIndex = checkinStreak.value + 1;

    try {
      final res = await _checkinApiRepo.dailyCheckinWeifu(dayIndex: targetDayIndex);
      if (res != null && res['success'] == true) {
        final rewardGems = res['reward_gems'] ?? 0;

        _checkinAppSetting.saveCheckinStreak(targetDayIndex);
        _checkinAppSetting.saveLastCheckinDate(today);
        checkinStreak.value = targetDayIndex;
        canCheckinToday.value = false;

        if (Get.isRegistered<ProfileController>()) {
          final profileCtrl = Get.find<ProfileController>();
          if (profileCtrl.currentUser.value != null) {
            profileCtrl.currentUser.value!.gems = res['remaining_gems'] ?? ((profileCtrl.currentUser.value!.gems ?? 0) + (rewardGems as num).toInt());
            profileCtrl.update();
          }
          await profileCtrl.fetchProfile();
        }

        AppUtil.showNormalToast("${'Checked in successfully!'.tr} +$rewardGems ${'Gems'.tr}\n${'Watch ads to earn more gems!'.tr}");

        Future.delayed(const Duration(milliseconds: 300), () {
          Get.put(PopupCheckinSuccessController(rewardGems: (rewardGems as num).toInt()));
          Get.dialog(
            const PopupCheckinSuccessPage(),
            barrierDismissible: true,
            useSafeArea: false,
          ).then((_) {
            Get.delete<PopupCheckinSuccessController>();
          });
        });
      } else {
        AppUtil.showToastError("Check in failed. Please try again later.".tr);
      }
    } catch (e) {
      AppUtil.showToastError("Check in failed. Please try again later.".tr);
    } finally {
      isCheckinClaiming.value = false;
      update();
    }
  }

  int getCheckinRewardForDay(int day) {
    if (day >= 1 && day <= 7) {
      return checkinRewards[day];
    }
    return 5;
  }
}
