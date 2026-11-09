
import 'package:cscmobi_app/screens/onboard/onboard_controller.dart';
import 'package:cscmobi_app/screens/onboard/onboard_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/base/base_controller.dart';
import '../../core/utils/app_util.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../models/language_model.dart';
import '../../routes/app_pages.dart';
import '../../utils/app_setting.dart';
import '../home/home_controller.dart';
import '../chats/chats_controller.dart';
import '../chat_detail/chat_detail_controller.dart';

class LanguageController extends BaseController {
  final RxList<LanguageModel> availableLanguages = RxList();
  Rx<LanguageModel>? currentChosenLang;

  final RxBool isFirstLaunchFlow = false.obs;
  final RxInt selectedLangPosition = 100.obs;
  final RxBool isSecondaryAdActive = false.obs;
  final RxBool canShowProceedButton = false.obs;
  final RxBool isLanguageLoading = false.obs;

  // Aliases for compatibility
  RxList<LanguageModel> get itemsList => availableLanguages;
  RxBool get isFirstLaunch => isFirstLaunchFlow;
  RxInt get selectedIndex => selectedLangPosition;
  RxBool get isShowAltAds => isSecondaryAdActive;
  RxBool get isShouldShowNext => canShowProceedButton;
  RxBool get isLoading => isLanguageLoading;

  bool get isPrimaryLangAdEnabled =>
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language) ||
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language_high);

  bool get isSecondaryLangAdEnabled =>
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language_alt) ||
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language_high_alt);

  bool get showNativeLanguage => isPrimaryLangAdEnabled;
  bool get showNativeLanguageAlt => isSecondaryLangAdEnabled;

  @override
  void onInit() {
    super.onInit();
    FirebaseHelper.setTrackingScreenName("LanguageScreen");
    if (Get.arguments != null) {
      AppUtil.showLogFull(
          "LanguageController onInit Get.arguments: ${Get.arguments}");
      isFirstLaunchFlow.value = Get.arguments["isFirstLaunch"] ?? false;
    } else {
      AppUtil.showLogFull("LanguageController onInit NO ARGUMENTS");
    }
    _populateSupportedLanguages();

    if (!isFirstLaunchFlow.value) {
      restoreSavedLanguage();
    }
    isLanguageLoading.value = true;
    Future.delayed(const Duration(seconds: 3), () {
      isLanguageLoading.value = false;
    });
  }

  void _populateSupportedLanguages() {
    availableLanguages.clear();
    availableLanguages.addAll([
      LanguageModel(pngAsset: 'assets/flag/flag_hindi.png', title: 'Hindi', languageCode: 'hi'),
      LanguageModel(pngAsset: 'assets/flag/flag_bengali.png', title: 'Bengali', languageCode: 'bn'),
      LanguageModel(pngAsset: 'assets/flag/flag_indonesia.png', title: 'Indonesian', languageCode: 'id'),
      LanguageModel(pngAsset: 'assets/flag/flag_english.png', title: 'English', languageCode: 'en'),
      LanguageModel(pngAsset: 'assets/flag/flag_philippine.png', title: 'Filipino', languageCode: 'fil'),
      LanguageModel(pngAsset: 'assets/flag/flag_spain.png', title: 'Spanish', languageCode: 'es'),
      LanguageModel(pngAsset: 'assets/flag/flag_turkish.png', title: 'Turkish', languageCode: 'tr'),
      LanguageModel(pngAsset: 'assets/flag/flag_portuguese.png', title: 'Portuguese', languageCode: 'pt'),
      LanguageModel(pngAsset: 'assets/flag/flag_arabic.png', title: 'Arabic', languageCode: 'ar'),
      LanguageModel(pngAsset: 'assets/flag/flag_russia.png', title: 'Russian', languageCode: 'ru'),
      LanguageModel(pngAsset: 'assets/flag/flag_france.png', title: 'French', languageCode: 'fr'),
      LanguageModel(pngAsset: 'assets/flag/flag_vietnam.png', title: 'Vietnamese', languageCode: 'vi'),
    ]);
  }

  void selectLanguageOption(int index) {
    selectedLangPosition.value = index;
    if (!isSecondaryAdActive.value && isFirstLaunchFlow.value) {
      FirebaseHelper.logEventName(FirebaseHelper.language_next_view,
          param: Get.currentRoute);
    }
    isSecondaryAdActive.value = true;
    Future.delayed(const Duration(milliseconds: 4000), () {
      canShowProceedButton.value = true;
    });
  }

  void onSelectItem(int index) => selectLanguageOption(index);

  void restoreSavedLanguage() {
    final String currentSaved = AppUtil().getUserChoosedLanguage();
    final int foundIndex = availableLanguages.indexWhere((l) => l.languageCode == currentSaved);
    selectedLangPosition.value = foundIndex >= 0 ? foundIndex : 0;
    canShowProceedButton.value = true;
  }

  void getPreviousSelectedLanguage() => restoreSavedLanguage();

  void navigateBack() {
    Get.back();
  }

  void onSelectBack() => navigateBack();

  Future<void> applyLanguageAndContinue() async {
    final chosenCode = availableLanguages[selectedLangPosition.value].languageCode;
    AppUtil().saveUserChoosedLanguage(chosenCode);
    final Locale targetLocale = Locale(chosenCode);
    initializeDateFormatting(chosenCode);
    AppSetting.selectedLanguageCode = chosenCode;
    Get.updateLocale(targetLocale);

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchCategories();
    }

    if (Get.isRegistered<ChatsController>()) {
      Get.find<ChatsController>().updateSessionLocalizations();
    }

    if (Get.isRegistered<ChatDetailController>()) {
      Get.find<ChatDetailController>().refreshLocalizedInfo();
    }

    if (!isFirstLaunchFlow.value) {
      Get.back();
      Get.back();
    } else {
      await Get.offAllWithController(
        controllerBuilder: () => OnboardController(),
        page: () => const OnboardPage(),
      );
    }
  }

  Future<void> onClickNext() => applyLanguageAndContinue();
}
