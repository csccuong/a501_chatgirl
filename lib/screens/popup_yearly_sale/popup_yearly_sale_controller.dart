import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/base/base_controller.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../helper/iap_helper.dart';
import '../../utils/Utils.dart';
import '../../utils/app_setting.dart';

class PopupYearlySaleController extends BaseController {
  RxString yearlySalePrice = '...'.obs;
  RxString yearlySalePerDay = '.../day'.obs;
  RxList<String> listTitlePremium = <String>[].obs;
  var percentSave = 30;
  Worker? _premiumWorker;

  @override
  void onInit() {
    super.onInit();
    if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
      Future.microtask(() {
        if (Get.isDialogOpen == true) Get.back();
      });
      return;
    }
    _premiumWorker = ever(AppSetting.isPremiumUser, (bool isPremium) {
      if (isPremium && Get.isDialogOpen == true) {
        Get.back();
      }
    });

    _syncYearlySalePrice();
    listTitlePremium = [
      "Unlock ad-free chats".tr,
      "Unlock outfit picks".tr,
      "Character creation".tr,
      "Get 1000 bonus gems".tr,
      "Faster AI replies".tr,
      "More image choices".tr,
    ].obs;
    if (FirebaseRemoteConfigService.getIntConfigByKey(FirebaseRemoteConfigService.percent_discount_yearly) > 0) {
      percentSave = FirebaseRemoteConfigService.getIntConfigByKey(FirebaseRemoteConfigService.percent_discount_yearly);
    }
  }

  Future<void> _syncYearlySalePrice() async {
    if (IAPHelper.products.isEmpty) {
      await IAPHelper.loadProducts();
    }
    final p = IAPHelper.getProductById(IAPHelper.itemYearlySale);
    if (p == null) {
      yearlySalePrice.value = '\$34.99';
      yearlySalePerDay.value = '\$0.10/day';
      update();
      return;
    }

    final oCcy = NumberFormat("#,##0.00", "en_US");
    final oCcy2 = NumberFormat("#,##0", "en_US");
    var symbol = p.currencySymbol;
    if (symbol.isEmpty) {
      String currencyCode = p.currencyCode;
      String currencySymbol = Utils().getCurrencySymbol(currencyCode);
      symbol = currencySymbol;
      if (symbol.isEmpty) {
        symbol = p.price.replaceAll(RegExp(r'[0-9.,!?;:(){}[\]]'), '');
      }
    }
    if ((p.rawPrice % 1) != 0) {
      yearlySalePrice.value = '${oCcy.format(p.rawPrice)}$symbol';
      yearlySalePerDay.value = '$symbol${oCcy.format(p.rawPrice / 365)}/day';
    } else {
      yearlySalePrice.value = '${oCcy2.format(p.rawPrice)}$symbol';
      yearlySalePerDay.value = '$symbol${oCcy.format(p.rawPrice / 365)}/day';
    }
    update();
  }

  void onClosePopup() {
    Get.back();
  }

  Future<void> onContinue() async {
    if (IAPHelper.checkoutBusy.value) return;
    await IAPHelper.purchaseSubscriptionYearlySale();
  }

  @override
  void onClose() {
    _premiumWorker?.dispose();
    super.onClose();
  }
}
