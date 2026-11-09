import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/material.dart';
import 'package:cscmobi_app/routes/app_pages.dart';
import 'package:cscmobi_app/screens/home/home_controller.dart';
import 'package:cscmobi_app/screens/main_tabbar/main_tabbar_controller.dart';
import 'package:cscmobi_app/screens/main_tabbar/main_tabbar_page.dart';
import 'package:cscmobi_app/screens/chat_detail/chat_detail_controller.dart';
import 'package:cscmobi_app/screens/character_detail/character_detail_controller.dart';
import 'package:cscmobi_app/screens/premium/premium_controller.dart';
import 'package:cscmobi_app/screens/profile/profile_controller.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:intl/intl.dart';
import '../utils/app_setting.dart';
import '../api_rest/api_repository.dart';
import '../core/utils/app_util.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'firebase_helper.dart';

class IAPHelper {
  static String iosSecret = '';
  static String itemWeekly = '';
  static String itemMonthly = 'lovery.sub.m01';
  static String itemYearly = 'lovery.sub.y01';
  static String itemYearlySale = 'lovery.sub.y01.sale';
  static String itemCoin1 = "lovery.coin.p01";
  static String itemCoin2 = "lovery.coin.p02";
  static String itemCoin3 = "lovery.coin.p03";
  static String itemCoin4 = "lovery.coin.p04";
  static String itemCoin5 = "lovery.coin.p05";
  static String itemCoin6 = "lovery.coin.p06";
  static String itemCoin1Alt = "lovery-coin-p01";
  static String itemCoin2Alt = "lovery-coin-p02";
  static String itemCoin3Alt = "lovery-coin-p03";
  static String itemCoin4Alt = "lovery-coin-p04";
  static String itemCoin5Alt = "lovery-coin-p05";
  static String itemCoin6Alt = "lovery-coin-p06";

  /// True khi đang mở flow mua (chặn double-tap Store / Premium).
  static final RxBool checkoutBusy = false.obs;

  static bool get isPurchasing =>
      checkoutBusy.value || EasyAds.instance.isIAPFlowActive;

  static void startPurchaseFlow() {
    checkoutBusy.value = true;
    EasyAds.instance.setIAPFlowActive(true);
    EasyAds.instance.appLifecycleReactor?.setPausedByIAP(true);
  }

  static void endPurchaseFlow() {
    checkoutBusy.value = false;
    EasyAds.instance.setIAPFlowActive(false);
  }

  static String itemRemoveAds = '';
  static bool isRestoringPurchase = false;
  static String lastReceiptId = '';
  static List<ProductDetails> products = [];
  static List<PurchaseDetails> _purchasedItems = [];
  static ProductDetails? currentPurchaseProduct;
  static bool _isFirstPurchase = false;

  static bool isSubscriptionProductId(String productId) {
    final id = productId.toLowerCase().trim();
    return id == itemMonthly.toLowerCase() ||
        id == itemYearly.toLowerCase() ||
        id == itemYearlySale.toLowerCase() ||
        (itemWeekly.isNotEmpty && id == itemWeekly.toLowerCase()) ||
        id == 'waifu.sub.m01' ||
        id == 'waifu.sub.y01' ||
        id == 'waifu.sub.y01.sale' ||
        id.contains('.sub.') ||
        id.contains('subscription') ||
        id.contains('test');
  }

  static void notifyPurchaseSuccess({required bool isSub, required bool isRemove}) {
    if (isSub) {
      AppSetting.isPremiumUser.value = true;
      AppUtil().savePurchaseStatus(true);
    }
    if (isRemove) {
      AppSetting.isRemoveAds.value = true;
      AppUtil().saveRemoveAdsStatus(true);
    }

    EasyAds.instance.appLifecycleReactor?.setAllowAppOpenAd(false);
    EasyAds.instance.destroyAllAds();

    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        home.onPremiumPurchased();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<MainTabbarController>()) {
        Get.find<MainTabbarController>().update();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<ChatDetailController>()) {
        Get.find<ChatDetailController>().update();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<CharacterDetailController>()) {
        Get.find<CharacterDetailController>().update();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().update();
      }
    } catch (_) {}
  }

  static void _exitPurchasePageAfterSuccess() {
    if (Get.isDialogOpen == true) {
      Get.back();
    } else if (Get.isRegistered<PremiumController>() &&
        Get.find<PremiumController>().isFromSplash) {
      Get.offAllWithController(
        controllerBuilder: () => HomeController(),
        page: () => const MainTabbarPage(),
        routeName: AppRoutes.HOME,
      );
    } else if (Get.context != null && Navigator.canPop(Get.context!)) {
      Get.back();
    }
  }

  static void _logPurchaseTracking({
    required PurchaseDetails purchase,
    required bool isSub,
    required bool isRemove,
  }) {
    try {
      if (!_isFirstPurchase || currentPurchaseProduct == null) return;

      AdjustHelper().trackEventInAppPurchase(
        purchase: purchase,
        productDetail: currentPurchaseProduct!,
      );

      final isGoogle = !Platform.isIOS;
      final pid = purchase.productID;

      if (pid == itemMonthly || pid == 'waifu.sub.m01') {
        AdjustHelper().trackEventBuyMonthlySuccess(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
        );
        FirebaseHelper.logEventPurchaseSuccessMonthly(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
          isGoogle: isGoogle,
        );
      } else if (pid == itemYearly || pid == 'waifu.sub.y01') {
        AdjustHelper().trackEventBuyYearlySuccess(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
        );
        FirebaseHelper.logEventPurchaseSuccessYearly(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
          isGoogle: isGoogle,
        );
      } else if (pid == itemYearlySale || pid == 'waifu.sub.y01.sale') {
        AdjustHelper().trackEventBuyYearlySaleSuccess(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
        );
        FirebaseHelper.logEventPurchaseSuccessYearlySale(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
          isGoogle: isGoogle,
        );
      } else if (pid == itemWeekly) {
        AdjustHelper().trackEventBuyWeeklySuccess(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
        );
        FirebaseHelper.logEventPurchaseSuccessWeekly(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
          isGoogle: isGoogle,
        );
      } else if (isRemove) {
        AdjustHelper().trackEventBuyRemoveAdsSuccess(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
        );
        FirebaseHelper.logEventPurchaseSuccessRemoveAds(
          purchase: purchase,
          productDetail: currentPurchaseProduct!,
          isGoogle: isGoogle,
        );
      }

      FirebaseHelper.logInAppPurchaseCustom(
        purchase: purchase,
        productDetail: currentPurchaseProduct!,
        isGoogle: isGoogle,
      );
    } catch (e) {
      AppUtil.showLogFull("Tracking log error: $e");
    }
  }

  /// API verify type theo backend:
  /// - subscription: các gói đăng ký
  /// - inapp: mua gem / các IAP không phải subscription
  static String _weifuProductTypeFor(String productId) {
    if (_isCoinProduct(productId)) return 'inapp';
    if (productId == itemMonthly ||
        productId == itemYearly ||
        productId == itemYearlySale ||
        (itemWeekly.isNotEmpty && productId == itemWeekly)) {
      return 'subscription';
    }
    if (productId == itemRemoveAds) return 'inapp';
    return 'inapp';
  }

  static bool _isCoinProduct(String productId) {
    final id = productId.toLowerCase().trim();
    return id == itemCoin1.toLowerCase() ||
        id == itemCoin2.toLowerCase() ||
        id == itemCoin3.toLowerCase() ||
        id == itemCoin4.toLowerCase() ||
        id == itemCoin5.toLowerCase() ||
        id == itemCoin6.toLowerCase() ||
        id == itemCoin1Alt.toLowerCase() ||
        id == itemCoin2Alt.toLowerCase() ||
        id == itemCoin3Alt.toLowerCase() ||
        id == itemCoin4Alt.toLowerCase() ||
        id == itemCoin5Alt.toLowerCase() ||
        id == itemCoin6Alt.toLowerCase() ||
        id.contains('coin') ||
        id.startsWith('lovery-coin') ||
        id.startsWith('lovery.coin') ||
        id.startsWith('waifu-coin') ||
        id.startsWith('waifu.coin');
  }

  static int getGemsForProduct(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('p01')) return 100;
    if (lower.contains('p02')) return 220;
    if (lower.contains('p03')) return 550;
    if (lower.contains('p04')) return 1200;
    if (lower.contains('p05')) return 2400;
    if (lower.contains('p06')) return 5200;
    if (lower.contains('m01')) return 300;
    if (lower.contains('y01')) return 1000;
    return 0;
  }

  static String? _aliasProductId(String productId) {
    const alias = {
      "lovery.coin.p01": "lovery-coin-p01",
      "lovery.coin.p02": "lovery-coin-p02",
      "lovery.coin.p03": "lovery-coin-p03",
      "lovery.coin.p04": "lovery-coin-p04",
      "lovery.coin.p05": "lovery-coin-p05",
      "lovery.coin.p06": "lovery-coin-p06",
      "lovery-coin-p01": "lovery.coin.p01",
      "lovery-coin-p02": "lovery.coin.p02",
      "lovery-coin-p03": "lovery.coin.p03",
      "lovery-coin-p04": "lovery.coin.p04",
      "lovery-coin-p05": "lovery.coin.p05",
      "lovery-coin-p06": "lovery.coin.p06",
      "waifu.coin.p01": "waifu-coin-p01",
      "waifu.coin.p02": "waifu-coin-p02",
      "waifu.coin.p03": "waifu-coin-p03",
      "waifu.coin.p04": "waifu-coin-p04",
      "waifu.coin.p05": "waifu-coin-p05",
      "waifu.coin.p06": "waifu-coin-p06",
      "waifu-coin-p01": "waifu.coin.p01",
      "waifu-coin-p02": "waifu.coin.p02",
      "waifu-coin-p03": "waifu.coin.p03",
      "waifu-coin-p04": "waifu.coin.p04",
      "waifu-coin-p05": "waifu.coin.p05",
      "waifu-coin-p06": "waifu.coin.p06",
    };
    return alias[productId];
  }

  static List<String> _allProductIds() {
    return [
      itemWeekly,
      itemMonthly,
      itemYearly,
      itemYearlySale,
      itemCoin1,
      itemCoin2,
      itemCoin3,
      itemCoin4,
      itemCoin5,
      itemCoin6,
      itemCoin1Alt,
      itemCoin2Alt,
      itemCoin3Alt,
      itemCoin4Alt,
      itemCoin5Alt,
      itemCoin6Alt,
      // Legacy waifu IDs for backward compatibility if store console still uses them:
      'waifu.sub.m01',
      'waifu.sub.y01',
      'waifu.sub.y01.sale',
      'waifu-coin-p01',
      'waifu-coin-p02',
      'waifu-coin-p03',
      'waifu-coin-p04',
      'waifu-coin-p05',
      'waifu-coin-p06',
      'waifu.coin.p01',
      'waifu.coin.p02',
      'waifu.coin.p03',
      'waifu.coin.p04',
      'waifu.coin.p05',
      'waifu.coin.p06',
    ].where((e) => e.isNotEmpty).toList();
  }

  static initIAP() async {
    try {
      // initialize the in-app purchase plugin
      final isAvailable = await InAppPurchase.instance.isAvailable();
      if (!isAvailable) {
        AppUtil.showLogFull(
            "In-App Purchase không khả dụng trên thiết bị này.");
        return;
      } else {
        AppUtil.showLogFull("In-App Purchase available");
      }
      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> purchases) async {
        // handle any purchase updates
        _handlePurchaseUpdates(purchases);
      });
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            InAppPurchase.instance
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        AppUtil.showLogFull("init IAP");
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
        _completePurchasePending();
        loadProducts();
        //Get list các item đã mua
        restorePurchases();
        AppSetting.isPremiumUser.value = AppUtil().getPurchaseStatus();
      } else {
        _completePurchasePending();
        loadProducts();
        //Get list các item đã mua
        restorePurchases();
        AppSetting.isPremiumUser.value = AppUtil().getPurchaseStatus();
      }
    } catch (ex) {
      AppUtil.showLogFull("initIAP error " + ex.toString());
    }
  }

  static bool shouldShowFlashSale() {
    var check =
        products.firstWhereOrNull((model) => model.id == itemYearlySale);
    if (check != null) {
      return true;
    } else {
      return false;
    }
  }

  static String getCurrentPackageName() {
    if (lastReceiptId.isNotEmpty) {
      if (lastReceiptId == itemMonthly) {
        return "Monthly".tr;
      } else if (lastReceiptId == itemWeekly) {
        return "Weekly".tr;
      } else if (lastReceiptId == itemRemoveAds) {
        return "Remove Ads".tr;
      } else {
        return "Yearly".tr;
      }
    } else {
      return "Free Plan".tr;
    }
  }

  static Future<void> loadProducts() async {
    try {
      final bool isAvailable = await InAppPurchase.instance.isAvailable();
      if (isAvailable) {
        products.clear();
        // get the product details from the store
        ProductDetailsResponse response = await InAppPurchase.instance
            .queryProductDetails(Set.from(_allProductIds()));
        if (response.notFoundIDs.isNotEmpty) {
          AppUtil.showLogFull(
              "IAP notFoundIDs: ${response.notFoundIDs.join(', ')}");
        }
        // save the product details to state
        AppUtil.showLogFull(
            "Number product " + response.productDetails.length.toString());
        products = response.productDetails;
        for (var item in products) {
          AppUtil.showLogFull(
              "Product loaded: " + item.id + " - price: " + item.price);
        }
      }
    } catch (e) {
      AppUtil.showLogFull("Number product error " + e.toString());
    }
  }

  static Future<void> _completePurchasePending() async {
    try {
      final paymentWrapper = SKPaymentQueueWrapper();
      final transactions = await paymentWrapper.transactions();
      transactions.forEach((transaction) async {
        await paymentWrapper.finishTransaction(transaction);
      });
    } catch (e) {
      AppUtil.showLogFull("_completePurchasePending error " + e.toString());
    }
  }

  static Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    if (purchases.isEmpty) {
      AppUtil.hideLoading();
      endPurchaseFlow();
      if (isRestoringPurchase == true) {
        isRestoringPurchase = false;
        AppUtil.showToast('msg_restore_fail'.tr);
      }
      return;
    }
    //Trường hợp restore purchase thì có thể dừng loading để xử lý được luôn, vì ko phải gọi API
    if (Platform.isAndroid) {
      AppUtil.hideLoading();
    }
    bool isPremiumUser = false;
    bool isRemoveAds = false;
    bool hasPurchasedInThisBatch = false;
    //chỉ cần item xuất hiện ở 1 trong 2 trạng thái là purchase hoặc restore thì có nghĩa là user đã mua hàng rồi ==> là premium user
    for (PurchaseDetails purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
          hasPurchasedInThisBatch = true;
          AppUtil.hideLoading();
          FirebaseHelper.logEventName(FirebaseHelper.payment_successful,
              param: "");

          final isSub = isSubscriptionProductId(purchase.productID);
          final isRemove = purchase.productID == itemRemoveAds;
          final isCoin = _isCoinProduct(purchase.productID);

          if (isSub || isRemove) {
            if (isSub) {
              isPremiumUser = true;
              lastReceiptId = purchase.productID;
            }
            if (isRemove) {
              isRemoveAds = true;
            }

            // Kích hoạt ngay lập tức trạng thái Premium / Remove Ads và notify UI + Ads
            notifyPurchaseSuccess(isSub: isSub, isRemove: isRemove);
            if (_isFirstPurchase) {
              AppUtil.showNormalToast('You’re Premium 🎉'.tr);
            }

            _logPurchaseTracking(
              purchase: purchase,
              isSub: isSub,
              isRemove: isRemove,
            );

            // Safe async backend verify không block hoặc làm mất VIP của user
            final title = currentPurchaseProduct?.title ??
                getProductById(purchase.productID)?.title ??
                purchase.productID;
            unawaited(verifySubscriptionGSM(
              productId: purchase.productID,
              productName: title,
              purchaseToken: purchase.verificationData.serverVerificationData,
            ).catchError((err) {
              AppUtil.showLogFull("verifySubscriptionGSM error: $err");
            }));
          } else if (isCoin) {
            final title = currentPurchaseProduct?.title ??
                getProductById(purchase.productID)?.title ??
                purchase.productID;
            unawaited(verifySubscriptionGSM(
              productId: purchase.productID,
              productName: title,
              purchaseToken: purchase.verificationData.serverVerificationData,
            ).then((_) {
              if (Get.isRegistered<ProfileController>()) {
                Get.find<ProfileController>().fetchProfile();
              }
            }).catchError((err) {
              AppUtil.showLogFull("verifySubscriptionGSM coin error: $err");
            }));
            AppUtil.showNormalToast('Purchase successful'.tr);
          } else {
            // Fallback
            isPremiumUser = true;
            notifyPurchaseSuccess(isSub: true, isRemove: false);
            if (_isFirstPurchase) {
              AppUtil.showNormalToast('You’re Premium 🎉'.tr);
            }
          }

          _purchasedItems.add(purchase);
          AppUtil.hideLoading();
          endPurchaseFlow();
          _exitPurchasePageAfterSuccess();
          break;
        case PurchaseStatus.restored:
          AppUtil.hideLoading();
          AppUtil.showLogFull("PurchaseStatus restored: ${purchase.productID}");
          FirebaseHelper.logEventName(FirebaseHelper.payment_restore,
              param: "");
          if (isSubscriptionProductId(purchase.productID) ||
              purchase.productID == itemRemoveAds) {
            _purchasedItems.add(purchase);
            if (purchase.productID == itemRemoveAds) {
              isRemoveAds = true;
            } else {
              isPremiumUser = true;
              lastReceiptId = purchase.productID;
            }
            if (Platform.isAndroid) {
              notifyPurchaseSuccess(isSub: isPremiumUser, isRemove: isRemoveAds);
            }
          }
          break;
        case PurchaseStatus.error:
          AppUtil.hideLoading();
          endPurchaseFlow();
          AppUtil.showLogFull(
              "PurchaseStatus error: code=${purchase.error?.code}, message=${purchase.error?.message}, details=${purchase.error?.details}");
          FirebaseHelper.logEventName(FirebaseHelper.payment_failed, param: "");
          FirebaseHelper.logEventPurchaseError(
              purchase: purchase, isGoogle: Platform.isIOS ? false : true);
          AppUtil.showNormalToast('Purchase failed. Please try again.'.tr);
          break;
        case PurchaseStatus.canceled:
          AppUtil.hideLoading();
          endPurchaseFlow();
          AppUtil.showLogFull("PurchaseStatus canceled");
          FirebaseHelper.logEventName(FirebaseHelper.payment_cancel, param: "");
          break;
        default:
          break;
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }

    // Nếu trong batch này vừa có purchase thành công, không để logic restore/validate hạ trạng thái!
    if (hasPurchasedInThisBatch) {
      if (isPremiumUser) {
        AppSetting.isPremiumUser.value = true;
        AppUtil().savePurchaseStatus(true);
      }
      if (isRemoveAds) {
        AppSetting.isRemoveAds.value = true;
        AppUtil().saveRemoveAdsStatus(true);
      }
      endPurchaseFlow();
      return;
    }

    // Logic xử lý khi RESTORE
    if (Platform.isAndroid) {
      if (isPremiumUser || isRemoveAds) {
        notifyPurchaseSuccess(isSub: isPremiumUser, isRemove: isRemoveAds);
        if (isRestoringPurchase == true) {
          AppUtil.showNormalToast('You’re Premium 🎉'.tr);
          AppUtil.hideLoading();
          isRestoringPurchase = false;
          _exitPurchasePageAfterSuccess();
        }
      } else {
        if (isRestoringPurchase == true) {
          AppUtil.showToast('msg_restore_fail'.tr);
          AppUtil.hideLoading();
          isRestoringPurchase = false;
        }
      }
    } else if (Platform.isIOS) {
      try {
        if (_purchasedItems.isNotEmpty) {
          AppUtil.showLogFull(
              "Validate purchase item " + _purchasedItems.length.toString());
          _purchasedItems.sort((b, a) => DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(a.transactionDate!)
              .compareTo(
                  DateFormat("yyyy-MM-dd HH:mm:ss").parse(b.transactionDate!)));
          PurchaseDetails mostRecentPurchase = _purchasedItems.first;
          var verificationData = mostRecentPurchase.verificationData;
          if (Platform.isIOS) {
            InAppPurchaseStoreKitPlatformAddition iosAddition = InAppPurchase
                .instance
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
            PurchaseVerificationData? _verificationData =
                await iosAddition.refreshPurchaseVerificationData();
            verificationData = _verificationData!;
          }
          final jws = verificationData.serverVerificationData;
          final payload = parseJWSPayload(jws);
          AppUtil.showLogFull("hehe " + payload.toString());
          if (payload["expiresDate"] != null) {
            final int expiresTimestamp = payload["expiresDate"];
            final expiresDate = DateTime.fromMillisecondsSinceEpoch(
                expiresTimestamp,
                isUtc: true);
            final now = DateTime.now().toUtc();
            final isActive = now.isBefore(expiresDate);
            if (isActive) {
              isPremiumUser = true;
              lastReceiptId = mostRecentPurchase.productID;
            } else {
              isPremiumUser = false;
              lastReceiptId = '';
            }
            print("Subscription còn hiệu lực: $isActive");
            print("Hết hạn vào: $expiresDate");
          }
        }
      } catch (ex) {
        AppUtil.showLogFull('validateReceiptIos error: ${ex.toString()}');
      }

      if (isPremiumUser || isRemoveAds) {
        notifyPurchaseSuccess(isSub: isPremiumUser, isRemove: isRemoveAds);
        if (isRestoringPurchase == true) {
          AppUtil.showNormalToast('You’re Premium 🎉'.tr);
          AppUtil.hideLoading();
          isRestoringPurchase = false;
          _exitPurchasePageAfterSuccess();
        }
      } else {
        AppSetting.isPremiumUser.value = false;
        AppUtil().savePurchaseStatus(false);
        if (isRestoringPurchase == true) {
          AppUtil.showToast('msg_restore_fail'.tr);
          AppUtil.hideLoading();
          isRestoringPurchase = false;
        }
      }
    }
    endPurchaseFlow();
  }

  static Map<String, dynamic> parseJWSPayload(String jws) {
    final parts = jws.split('.');
    if (parts.length != 3) throw Exception("Invalid JWS format");

    final payloadBase64 = base64Url.normalize(parts[1]);
    final payloadJson = utf8.decode(base64Url.decode(payloadBase64));
    return json.decode(payloadJson);
  }

  static PurchaseDetails? findMostRecentItemByProductId(
      List<PurchaseDetails> list, String productId) {
    final elems = list
        .where((PurchaseDetails item) => item.productID == productId)
        .toList();
    if (elems.isNotEmpty) {
      elems.sort((a, b) =>
          DateTime.fromMillisecondsSinceEpoch(int.parse(b.transactionDate!))
              .compareTo(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(a.transactionDate!))));
      return elems[0];
    } else {
      return null;
    }
  }

  /// const receiptBody = {
  /// 'receipt-data': purchased.transactionReceipt,
  /// 'password': '******'
  /// };
  static Future<http.Response> validateReceiptIos(
      receiptBody, bool isTest) async {
    AppUtil.showLogFull("hehe " + jsonEncode(receiptBody));
    final String url = isTest
        ? 'https://sandbox.itunes.apple.com/verifyReceipt'
        : 'https://buy.itunes.apple.com/verifyReceipt';
    AppUtil.showLogFull("url validateReceiptIos " + url);
    return await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(receiptBody),
    );
  }

  /*
  Mua một sản phẩm hoặc đăng ký không tiêu thụ.
  Các vật phẩm không tiêu hao chỉ có thể được mua một lần. Ví dụ: giao dịch mua mở khóa nội dung đặc biệt trong ứng dụng của bạn. Đăng ký cũng là sản phẩm không tiêu thụ.
  Bạn luôn cần khôi phục tất cả các sản phẩm không tiêu hao cho người dùng khi họ đổi điện thoại.
  Phương pháp này không trả về kết quả mua hàng. Thay vào đó, sau khi kích hoạt phương pháp này, các bản cập nhật mua hàng sẽ được gửi đến buyStream. Bạn nên Stream.listen buyStream để nhận các đối tượng BuyDetails trong các BuyDetails.status khác nhau và cập nhật giao diện người dùng của bạn cho phù hợp. Khi PurchaseDetails.status là PurchaseStatus.purchased, PurchaseStatus.restored hoặc PurchaseStatus.error, bạn nên cung cấp nội dung hoặc xử lý lỗi, sau đó gọi CompletePurchase để kết thúc quá trình mua hàng.
  Phương thức này không trả về việc yêu cầu mua ban đầu có được gửi thành công hay không.
  Các mặt hàng tiêu hao được xác định khác nhau bởi các nền tảng thanh toán cơ bản khác nhau và không có cách nào để truy vấn xem ProductDetail có phải là một mặt hàng tiêu dùng trong thời gian chạy hay không.
  Xem thêm:
  buyConsumable, để mua một sản phẩm tiêu dùng.
  restorePurchases, để khôi phục các sản phẩm không tiêu thụ được.
  * */
  static Future<void> purchaseSubscriptionWeekly() async {
    // AppUtil.showLogFull('IAP purchaseSubscriptionPlanWeekly count ${products.length}');
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    // AppUtil.showLoading();
    if (isAvailable) {
      if (products.isNotEmpty) {
        ProductDetails? threeMonthProduct = products.firstWhereOrNull(
            (element) => element.id == itemWeekly && element.rawPrice > 0);
        if (threeMonthProduct != null) {
          currentPurchaseProduct = threeMonthProduct;
          // AppUtil.showLogFull('IAP purchaseSubscriptionPlanWeekly weeklyProduct: ${weeklyProduct.id}');
          _isFirstPurchase = true;
          startPurchaseFlow();
          AppUtil.showLoading();
          try {
            // initiate the purchase flow
            final PurchaseParam purchaseParam =
                PurchaseParam(productDetails: threeMonthProduct);
            await InAppPurchase.instance
                .buyNonConsumable(purchaseParam: purchaseParam);
            // AppUtil.hideLoading();
          } catch (ex) {
            AppUtil.showLogFull(
                'IAP purchaseSubscriptionWeekly buyNonConsumable error: ${ex.toString()}');
            AppUtil.hideLoading();
            endPurchaseFlow();
          }
        }
      }
    } else {
      AppUtil.showToastError('msg_purchase_not_available'.tr);
    }
    // AppUtil.hideLoading();
    //log event
    FirebaseHelper.logEventClickPurchaseYearly(productId: itemWeekly);
  }

  static Future<void> purchaseSubscriptionRemoveAds() async {
    // AppUtil.showLogFull('IAP purchaseSubscriptionPlanWeekly count ${products.length}');
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    // AppUtil.showLoading();
    if (isAvailable) {
      if (products.isNotEmpty) {
        ProductDetails? removeAdsProduct = products.firstWhereOrNull(
            (element) => element.id == itemRemoveAds && element.rawPrice > 0);
        if (removeAdsProduct != null) {
          currentPurchaseProduct = removeAdsProduct;
          // AppUtil.showLogFull('IAP purchaseSubscriptionPlanWeekly weeklyProduct: ${weeklyProduct.id}');
          _isFirstPurchase = true;
          startPurchaseFlow();
          AppUtil.showLoading();
          try {
            // initiate the purchase flow
            final PurchaseParam purchaseParam =
                PurchaseParam(productDetails: removeAdsProduct);
            await InAppPurchase.instance
                .buyNonConsumable(purchaseParam: purchaseParam);
            // AppUtil.hideLoading();
          } catch (ex) {
            AppUtil.showLogFull(
                'IAP purchaseSubscriptionRemoveAds buyNonConsumable error: ${ex.toString()}');
            AppUtil.hideLoading();
            endPurchaseFlow();
          }
        }
      }
    } else {
      AppUtil.showToastError('msg_purchase_not_available'.tr);
    }
    // AppUtil.hideLoading();
    //log event
    FirebaseHelper.logEventClickPurchaseRemoveAds(productId: itemRemoveAds);
  }

  static Future<void> purchaseSubscriptionMonthly() async {
    try {
      if (checkoutBusy.value) {
        AppUtil.showLogFull('purchaseSubscriptionMonthly: ignored (busy)');
        return;
      }
      final bool isAvailable = await InAppPurchase.instance.isAvailable();
      AppUtil.showLogFull("start purchaseSubscriptionMonthly");
      if (isAvailable) {
        if (products.isEmpty) {
          await loadProducts();
        }
        final matchIds = [itemMonthly, 'waifu.sub.m01'];
        List<ProductDetails> listProductMonth = [];
        for (var item in products) {
          if (matchIds.contains(item.id)) {
            listProductMonth.add(item);
          }
        }
        listProductMonth.sort((a, b) => (a.rawPrice.compareTo(b.rawPrice)));
        AppUtil.showLogFull(
            'IAP purchaseSubscriptionPlanMonthly monthlyProduct: ${listProductMonth.length}');
        if (listProductMonth.isNotEmpty) {
          ProductDetails monthlyProduct = listProductMonth.first;
          currentPurchaseProduct = monthlyProduct;
          AppUtil.showLogFull(
              'IAP purchaseSubscriptionPlanMonthly monthlyProduct: ${monthlyProduct.id}');
          _isFirstPurchase = true;
          startPurchaseFlow();
          AppUtil.showLoading();
          try {
            // initiate the purchase flow
            AppUtil.showLogFull(
                'IAP purchaseSubscriptionPlanMonthly start buyNonConsumable');
            final PurchaseParam purchaseParam =
                PurchaseParam(productDetails: monthlyProduct);
            await InAppPurchase.instance
                .buyNonConsumable(purchaseParam: purchaseParam);
            AppUtil.showLogFull(
                'IAP purchaseSubscriptionPlanMonthly end buyNonConsumable');
          } catch (ex) {
            AppUtil.showLogFull(
                'IAP purchaseSubscriptionPlanMonthly buyNonConsumable error: ${ex.toString()}');
            AppUtil.hideLoading();
            endPurchaseFlow();
          }
        } else {
          AppUtil.showToastError('msg_purchase_not_available'.tr);
        }
      } else {
        AppUtil.showToastError('msg_purchase_not_available'.tr);
      }
      //log event
      FirebaseHelper.logEventClickPurchaseMonthly(productId: itemMonthly);
    } catch (e) {
      AppUtil.showLogFull("Buy monthly error " + e.toString());
      AppUtil.hideLoading();
      endPurchaseFlow();
    }
  }

  static Future<void> purchaseSubscriptionYearly() async {
    try {
      if (checkoutBusy.value) {
        AppUtil.showLogFull('purchaseSubscriptionYearly: ignored (busy)');
        return;
      }
      final bool isAvailable = await InAppPurchase.instance.isAvailable();
      if (isAvailable) {
        if (products.isEmpty) {
          await loadProducts();
        }
        final matchIds = [itemYearly, 'waifu.sub.y01'];
        var arrYearlyProducts =
            products.where((element) => matchIds.contains(element.id)).toList();
        ProductDetails? yearlyProduct;
        if (arrYearlyProducts.isNotEmpty) {
          arrYearlyProducts.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
          yearlyProduct = arrYearlyProducts.first;
        } else {
          AppUtil.showToastError('msg_purchase_not_available'.tr);
          return;
        }
        currentPurchaseProduct = yearlyProduct;
        _isFirstPurchase = true;
        startPurchaseFlow();
        AppUtil.showLoading();
        try {
          final PurchaseParam purchaseParam =
              PurchaseParam(productDetails: yearlyProduct);
          await InAppPurchase.instance
              .buyNonConsumable(purchaseParam: purchaseParam);
        } catch (ex) {
          AppUtil.showLogFull(
              'IAP purchaseSubscriptionPlanYearly buyNonConsumable error: ${ex.toString()}');
          AppUtil.hideLoading();
          endPurchaseFlow();
        }
      } else {
        AppUtil.showToastError('msg_purchase_not_available'.tr);
      }
      FirebaseHelper.logEventClickPurchaseYearly(productId: itemYearly);
    } catch (e) {
      AppUtil.showLogFull("Buy yearly error " + e.toString());
      AppUtil.hideLoading();
      endPurchaseFlow();
    }
  }

  static Future<void> purchaseSubscriptionYearlySale() async {
    try {
      if (checkoutBusy.value) {
        AppUtil.showLogFull('purchaseSubscriptionYearlySale: ignored (busy)');
        return;
      }
      final bool isAvailable = await InAppPurchase.instance.isAvailable();
      if (isAvailable) {
        if (products.isEmpty) {
          await loadProducts();
        }
        final matchIds = [itemYearlySale, 'waifu.sub.y01.sale'];
        var arrYearlyProducts =
            products.where((element) => matchIds.contains(element.id)).toList();
        ProductDetails? yearlyProduct;
        if (arrYearlyProducts.isNotEmpty) {
          arrYearlyProducts.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
          yearlyProduct = arrYearlyProducts.first;
        } else {
          AppUtil.showToastError('msg_purchase_not_available'.tr);
          return;
        }
        currentPurchaseProduct = yearlyProduct;
        _isFirstPurchase = true;
        startPurchaseFlow();
        AppUtil.showLoading();
        try {
          final PurchaseParam purchaseParam =
              PurchaseParam(productDetails: yearlyProduct);
          await InAppPurchase.instance
              .buyNonConsumable(purchaseParam: purchaseParam);
        } catch (ex) {
          AppUtil.showLogFull(
              'IAP purchaseSubscriptionYearlySale buyNonConsumable error: ${ex.toString()}');
          AppUtil.hideLoading();
          endPurchaseFlow();
        }
      } else {
        AppUtil.showToastError('msg_purchase_not_available'.tr);
      }
      FirebaseHelper.logEventClickPurchaseYearlySale(productId: itemYearlySale);
    } catch (e) {
      AppUtil.showLogFull("Buy yearly sale error " + e.toString());
      AppUtil.hideLoading();
      endPurchaseFlow();
    }
  }

  static ProductDetails? getProductById(String productId) {
    try {
      ProductDetails? exact =
          products.firstWhereOrNull((e) => e.id == productId);
      if (exact != null) return exact;
      final aliasId = _aliasProductId(productId);
      if (aliasId != null) {
        final aliasProduct = products.firstWhereOrNull((e) => e.id == aliasId);
        if (aliasProduct != null) return aliasProduct;
      }
      // Dual fallback between lovery and waifu
      if (productId.contains('lovery')) {
        final legacyId = productId.replaceAll('lovery', 'waifu');
        ProductDetails? legacyProduct =
            products.firstWhereOrNull((e) => e.id == legacyId);
        if (legacyProduct != null) return legacyProduct;
        final legacyAlias = _aliasProductId(legacyId);
        if (legacyAlias != null) {
          final legacyAliasProduct =
              products.firstWhereOrNull((e) => e.id == legacyAlias);
          if (legacyAliasProduct != null) return legacyAliasProduct;
        }
      }
      if (productId.contains('waifu')) {
        final newId = productId.replaceAll('waifu', 'lovery');
        ProductDetails? newProduct =
            products.firstWhereOrNull((e) => e.id == newId);
        if (newProduct != null) return newProduct;
        final newAlias = _aliasProductId(newId);
        if (newAlias != null) {
          final newAliasProduct =
              products.firstWhereOrNull((e) => e.id == newAlias);
          if (newAliasProduct != null) return newAliasProduct;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> purchaseByProductId(String productId) async {
    if (checkoutBusy.value) {
      AppUtil.showLogFull('purchaseByProductId: ignored (checkout busy)');
      return;
    }

    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    if (!isAvailable) {
      AppUtil.showToastError('msg_purchase_not_available'.tr);
      return;
    }

    if (products.isEmpty) {
      await loadProducts();
    }

    ProductDetails? detail = getProductById(productId);
    if (detail == null) {
      await loadProducts();
      detail = getProductById(productId);
    }

    if (detail == null) {
      AppUtil.showLogFull('purchaseByProductId: product $productId not found in store details');
      AppUtil.hideLoading();
      endPurchaseFlow();
      AppUtil.showToastError('msg_purchase_not_available'.tr);
      return;
    }

    currentPurchaseProduct = detail;
    _isFirstPurchase = true;
    startPurchaseFlow();
    AppUtil.showLoading();
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: detail);
      if (_isCoinProduct(productId) || _isCoinProduct(detail.id)) {
        await InAppPurchase.instance
            .buyConsumable(purchaseParam: purchaseParam);
      } else {
        await InAppPurchase.instance
            .buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (ex) {
      AppUtil.showLogFull('purchaseByProductId error: ${ex.toString()}');
      AppUtil.hideLoading();
      endPurchaseFlow();
      AppUtil.showNormalToast('Purchase failed. Please try again.'.tr);
    }
  }

  static Future<void> restorePurchases({bool isUserTriggered = false}) async {
    _isFirstPurchase = false;
    if (isUserTriggered) {
      isRestoringPurchase = true;
      startPurchaseFlow();
    }
    AppUtil.showLogFull('IAP restorePurchases');
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      if (isUserTriggered) {
        endPurchaseFlow();
      }
    }
    // update();
  }

  static Future<void> consumeAllPurchasedItem() async {
    AppUtil.showLogFull('IAP consumPurchasedItem');
    if (Platform.isAndroid) {
      //consume item weekly
      PurchaseDetails? itemPurchaseWeekly = _purchasedItems
          .firstWhereOrNull((element) => element.productID == itemMonthly);
      if (itemPurchaseWeekly != null) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            InAppPurchase.instance
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        await androidAddition.consumePurchase(itemPurchaseWeekly);
      }
      //consume item monthly
      PurchaseDetails? itemPurchaseMonthly = _purchasedItems
          .firstWhereOrNull((element) => element.productID == itemYearly);
      if (itemPurchaseMonthly != null) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            InAppPurchase.instance
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        await androidAddition.consumePurchase(itemPurchaseMonthly);
      }
      //consume item weekly
      PurchaseDetails? itemPurchaseYearly = _purchasedItems
          .firstWhereOrNull((element) => element.productID == itemWeekly);
      if (itemPurchaseYearly != null) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            InAppPurchase.instance
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        await androidAddition.consumePurchase(itemPurchaseYearly);
      }
      //consume item lifetime
      PurchaseDetails? itemPurchaseLifetime = _purchasedItems
          .firstWhereOrNull((element) => element.productID == itemRemoveAds);
      if (itemPurchaseLifetime != null) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            InAppPurchase.instance
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        await androidAddition.consumePurchase(itemPurchaseLifetime);
      }
    }
    restorePurchases();
    AppSetting.isPremiumUser.value = false;
    AppUtil().savePurchaseStatus(false);
  }

  static Future<void> verifySubscriptionGSM({
    required String purchaseToken,
    required String productId,
    required String productName,
  }) async {
    final apiRepository = ApiRepository();
    final backendProductId = ApiRepository.mapToBackendProductId(productId);
    final productType = _weifuProductTypeFor(backendProductId);
    AppUtil.showLogFull(
        'verifySubscriptionGSM payload => rawProductId=$productId backendProductId=$backendProductId productName=$productName productType=$productType');
    final result = await apiRepository.verifyPurchaseWeifu(
      productId: backendProductId,
      productType: productType,
    );
    AppUtil.showLogFull(
        'ApiRepository verifyPurchaseWeifu result: $result productName=$productName');

    final success = result != null && result['success'] == true;
    if (!success) {
      AppUtil.showLogFull(
          'verifyPurchaseWeifu not success or null, applying fallback credit for $productId');
      final fallbackGems = getGemsForProduct(productId);
      if (fallbackGems > 0 && Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>();
        if (profile.currentUser.value != null) {
          profile.currentUser.value!.gems =
              (profile.currentUser.value!.gems ?? 0) + fallbackGems;
          profile.currentUser.refresh();
        }
      }
      return;
    }

    final grantedGems = result['granted_gems'];
    final message = result['message'];
    final user = result['user'];
    final responseGems =
        (user is Map<String, dynamic>) ? user['gems'] : (user is Map ? user['gems'] : null);
    final remainingGems = result['remaining_gems'];

    AppUtil.showLogFull(
        'verifyPurchaseWeifu parsed => success=$success message=$message granted_gems=$grantedGems remaining_gems=$remainingGems user.gems=$responseGems');

    try {
      if (Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>();
        if (remainingGems is num) {
          profile.currentUser.value?.gems = remainingGems.toInt();
          profile.currentUser.refresh();
        } else if (responseGems is num) {
          profile.currentUser.value?.gems = responseGems.toInt();
          profile.currentUser.refresh();
        } else if (grantedGems is num && profile.currentUser.value != null) {
          profile.currentUser.value!.gems =
              (profile.currentUser.value!.gems ?? 0) + grantedGems.toInt();
          profile.currentUser.refresh();
        }
        await profile.fetchProfile();
      }
    } catch (e) {
      AppUtil.showLogFull('verifyPurchaseWeifu update profile error: $e');
    }

    try {
      if (user is Map && user['is_premium'] == true) {
        AppSetting.isPremiumUser.value = true;
        AppUtil().savePurchaseStatus(true);
      }
    } catch (_) {}
  }

  /// Check if a subscription is active on `Android` and `iOS`.
  ///
  /// This is a quick and dirty way to check if a subscription is active.
  /// It is highly recommended to do server-side validation for all subscriptions.
  /// This method is NOT secure and untested in production.
  Future<bool> checkSubscribedIOS({
    required String sku,
    Duration duration = const Duration(days: 365),
    Duration grace = const Duration(days: 7),
  }) async {
    if (Platform.isIOS) {
      // var history = await getPurchaseHistory();
      for (var purchase in _purchasedItems) {
        Duration difference = DateTime.now().difference(
            (DateTime.fromMillisecondsSinceEpoch(
                (int.parse(purchase.transactionDate!)))));
        // Duration difference = DateTime.now().difference(purchase.transactionDate!);
        if (difference.inMinutes <= (duration + grace).inMinutes &&
            purchase.productID == sku) return true;
      }

      return false;
    }
    return false;
  }

  //Verify Receipt for IOS
  // String testReceipt =
  //     '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';
  //
  // bool useTestReceipt = true;

  static Future<bool> verifyReceipt() async {
    if (!Platform.isIOS) {
      return false;
    }

    String receipt = '';
    // if (useTestReceipt) {
    //   receipt = testReceipt;
    // } else {
    // Acquire the InAppPurchaseIosPlatformAddition instance.
    InAppPurchaseStoreKitPlatformAddition iosAddition = InAppPurchase.instance
        .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    // Present the code redemption sheet.
    // await iosAddition.presentCodeRedemptionSheet();
    // Refresh purchase verification data.
    PurchaseVerificationData? verificationData =
        await iosAddition.refreshPurchaseVerificationData();

    if (verificationData == null) return false;
    receipt = verificationData.localVerificationData;
    // }
    var receiptData = base64.decode(receipt);
    decode(ASN1Parser(receiptData));
    AppUtil.showLogFull('Finished printing receipt');
    return true;
  }

  static bool decode(ASN1Parser receipt) {
    if (!receipt.hasNext()) {
      return false;
    }
    var asnSet = receipt.nextObject();
    if (asnSet is! ASN1Sequence) {
      return false;
    }
    decodeSequence(asnSet);
    return true;
  }

  static bool decodeSequence(ASN1Sequence sequence) {
    decodeElements(sequence.elements);
    return true;
  }

  static bool decodeSet(ASN1Set set) {
    decodeElements(set.elements.toList());
    return true;
  }

  static bool decodeElements(List<ASN1Object> elements) {
    for (var element in elements) {
      if (element is ASN1ObjectIdentifier) {
        print(element.runtimeType.toString() + ": " + element.toString());
      } else if (element.tag == 160 || element.tag == 163) {
        decode(ASN1Parser(element.valueBytes()));
      } else if (element is ASN1Set) {
        decodeSet(element);
      } else if (element is ASN1Sequence) {
        decodeSequence(element);
      } else {
        print(element.runtimeType.toString() + ": " + element.toString());
      }
    }
    return true;
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
