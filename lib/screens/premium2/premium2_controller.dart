import 'package:cscmobi_app/screens/main_tabbar/main_tabbar_controller.dart';
import 'package:cscmobi_app/screens/main_tabbar/main_tabbar_page.dart';
import 'package:cscmobi_app/utils/app_setting.dart';
import 'package:cscmobi_app/helper/firebase_remote_config_service.dart';
import 'package:cscmobi_app/screens/home/home_ad_preload_coordinator.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/base/base_controller.dart';
import '../../core/utils/app_util.dart';
import '../../core/values/constants.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/iap_helper.dart';
import '../../models/premium.dart';
import '../../routes/app_pages.dart';
import '../../utils/Utils.dart';

class Premium2Controller extends BaseController {
  var itemSelected = 0.obs;
  var titleButton = "Continue".obs;
  List<Premium> listPremium = [];
  List<ProductDetails> listProduct = [];
  bool isFromSplash = false;
  RxInt percentDiscountYearly = 30.obs;
  RxBool isShowShowClose = false.obs;
  var timeDelayClosePremium = 2;

  RxList<String> listTitlePremium = <String>[].obs;
  var percentSave = 58;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initData();
    FirebaseHelper.setTrackingScreenName("PremiumScreen2");
    if (Get.arguments != null) {
      isFromSplash = Get.arguments["isFromSplash"];
      AppUtil.showLogFull(
          "PremiumScreen2 arguments isFromSplash: $isFromSplash");
    }
    if (FirebaseRemoteConfigService.getIntConfigByKey(
            FirebaseRemoteConfigService.time_delay_close_premium) >
        0) {
      timeDelayClosePremium = FirebaseRemoteConfigService.getIntConfigByKey(
          FirebaseRemoteConfigService.time_delay_close_premium);
    }
    if (FirebaseRemoteConfigService.getIntConfigByKey(
            FirebaseRemoteConfigService.percentSaveVIP) >
        0) {
      percentSave = FirebaseRemoteConfigService.getIntConfigByKey(
          FirebaseRemoteConfigService.percentSaveVIP);
    }
    listTitlePremium = [
      "Enjoy Unlimited Chats".tr,
      "Unlock Outfit Selections".tr,
      "Get 1000 Gems Bonus".tr,
      "Faster AI Replies".tr,
      "More Image Choices".tr,
      "Character creation".tr,
    ].obs;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Future.delayed(Duration(seconds: timeDelayClosePremium), () {
      isShowShowClose.value = true;
      update();
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  onSelectItem(var index) {
    itemSelected.value = index;
    if (listPremium[itemSelected.value].packageId == IAPHelper.itemMonthly) {
      titleButton.value = "Continue".tr;
      listTitlePremium = [
        "Enjoy Unlimited Chats".tr,
        "Ad-free Experience".tr,
        "Get 300 Gems Bonus".tr,
        "Faster AI Replies".tr,
      ].obs;
    } else {
      titleButton.value = "Continue".tr;
      listTitlePremium = [
        "Enjoy Unlimited Chats".tr,
        "Unlock Outfit Selections".tr,
        "Get 1000 Gems Bonus".tr,
        "Faster AI Replies".tr,
        "More Image Choices".tr,
        "Character creation".tr,
      ].obs;
    }
    update();
  }

  onSelectBuy() {
    if (IAPHelper.checkoutBusy.value) return;
    if (AppSetting.isPremiumUser.value) {
      AppUtil.showNormalToast("You are already a premium user".tr);
      return;
    }
    try {
      print("hix purchase: " + listPremium[itemSelected.value].packageId);
      FirebaseHelper.logEventName(FirebaseHelper.paywall_view, param: "");
      if (listPremium[itemSelected.value].packageId == IAPHelper.itemYearly) {
        IAPHelper.purchaseSubscriptionYearly();
      } else if (listPremium[itemSelected.value].packageId ==
          IAPHelper.itemMonthly) {
        IAPHelper.purchaseSubscriptionMonthly();
      }
    } catch (e) {}
  }

  initData() {
    final oCcy = new NumberFormat("#,##0.00", "en_US");
    final oCcy2 = new NumberFormat("#,##0", "en_US");
    listProduct = IAPHelper.products;

    var package = Premium(
        title: "1 Year SVIP".tr,
        price: 49.99,
        saleOff: 50,
        desc: "Auto renew".tr,
        packageId: IAPHelper.itemYearly);
    package.note = "49.99\$/year. Cancel any time".tr;
    var yearlyProduct = listProduct.firstWhereOrNull(
        (model) => model.id == IAPHelper.itemYearly && model.rawPrice > 0);
    if (yearlyProduct != null) {
      package.price = yearlyProduct.rawPrice;
      package.desc = "Get 3 Days free trial".tr;
      package.currencySymbol = yearlyProduct.currencySymbol;
      if (package.currencySymbol.isEmpty) {
        String currencyCode =
            yearlyProduct.currencyCode; // Change to your desired currency code
        String currencySymbol = Utils().getCurrencySymbol(currencyCode);
        package.currencySymbol = currencySymbol;
        if (package.currencySymbol.isEmpty) {
          String sympbol =
              yearlyProduct.price.replaceAll(RegExp(r'[0-9.,!?;:(){}[\]]'), '');
          package.currencySymbol = sympbol;
        }
      }
      if (yearlyProduct.rawPrice % 1 != 0) {
        package.desc = (oCcy.format(yearlyProduct.rawPrice)).toString() +
            package.currencySymbol +
            "/year. Cancel any time".tr;
        package.note = "";
      } else {
        package.desc = (oCcy2.format(yearlyProduct.rawPrice)).toString() +
            package.currencySymbol +
            "/year. Cancel any time".tr;
        package.note = "";
      }
    }
    listPremium.add(package);

    var package2 = Premium(
        title: "1 Month VIP".tr,
        price: 9.99,
        saleOff: 50,
        desc: "Trial 3-day".tr,
        packageId: IAPHelper.itemMonthly);
    package2.note = "";
    var monthlyProduct = listProduct.firstWhereOrNull(
        (model) => model.id == IAPHelper.itemMonthly && model.rawPrice > 0);
    if (monthlyProduct != null) {
      package2.price = monthlyProduct.rawPrice;
      package2.currencySymbol = monthlyProduct.currencySymbol;
      // package2.note = "No commitment. Cancel Anytime".tr;
      if (package2.currencySymbol.isEmpty) {
        String currencyCode =
            monthlyProduct.currencyCode; // Change to your desired currency code
        String currencySymbol = Utils().getCurrencySymbol(currencyCode);
        package2.currencySymbol = currencySymbol;
        if (package2.currencySymbol.isEmpty) {
          String sympbol = monthlyProduct.price
              .replaceAll(RegExp(r'[0-9.,!?;:(){}[\]]'), '');
          package2.currencySymbol = sympbol;
        }
      }
      if (monthlyProduct.rawPrice % 1 != 0) {
        package2.desc = (oCcy.format(monthlyProduct.rawPrice)).toString() +
            package2.currencySymbol +
            "/month".tr +
            ". " +
            "Cancel any time".tr;
      } else {
        package2.desc = (oCcy2.format(monthlyProduct.rawPrice)).toString() +
            package2.currencySymbol +
            "/month".tr +
            ". " +
            "Cancel any time".tr;
      }
    }
    listPremium.add(package2);
  }

  onSelectBack() {
    AppUtil.showLogFull('onSelectBack isFromSplash: $isFromSplash');
    if (isFromSplash) {
      HomeAdPreloadCoordinator.preloadBeforeHome(source: 'premium2_back');
      Get.offAllWithController(
        controllerBuilder: () => MainTabbarController(),
        page: () => MainTabbarPage(),
        routeName: AppRoutes.HOME,
      );
    } else {
      AppUtil.showLogFull('onSelectBack ==> BACK');
      Get.back();
    }
  }

  onSelectTermOfUse() {
    final Uri url = Uri.parse(Constants.termOfUser);
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  onSelectRestore() async {
    if (AppSetting.isPremiumUser.value) {
      AppUtil.showNormalToast("You are already a premium user".tr);
      return;
    }
    AppUtil.showLoading();
    await IAPHelper.restorePurchases(isUserTriggered: true);
    AppUtil.hideLoading();
  }

  onSelectPrivacy() {
    final Uri url = Uri.parse(Constants.privacy);
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
