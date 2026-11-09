import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:overlay_support/overlay_support.dart' hide Toast;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../anim/ease_in_widget.dart';
import '../values/app_colors.dart';
import '/core/values/constants.dart';
import '/core/values/styles.dart';

class AppUtil {
  savePurchaseStatus(bool purchaseSuccess) {
    return saveBool(Constants.kIsPurchase, purchaseSuccess);
  }

  saveRemoveAdsStatus(bool isRemoveAdsSuccess) {
    return saveBool(Constants.kIsRemoveAds, isRemoveAdsSuccess);
  }

  bool getPurchaseStatus() {
    bool isPurchaseSuccess = getBool(Constants.kIsPurchase);
    return isPurchaseSuccess;
  }

  bool getRemoveAdsStatus() {
    bool isRemoveAdsSuccess = getBool(Constants.kIsRemoveAds);
    return isRemoveAdsSuccess;
  }

  static Future<String> convertImageToBase64(String imagePath) async {
    final File imageFile = File(imagePath);
    final List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  String getUserConversationID() {
    String strResult = '';
    try {
      strResult = getString(Constants.kConversationId);
    } catch (e) {
      AppUtil.showLog("getUserConversationID Error: " + e.toString());
    }
    AppUtil.showLog("getUserConversationID strResult: " + strResult);
    return strResult;
  }

  saveUserConversationID(String _languageCode) {
    try {
      AppUtil.showLog("saveUserConversationID _languageCode: " + _languageCode);
      saveString(Constants.kConversationId, _languageCode);
    } catch (e) {
      AppUtil.showLog("saveUserConversationID Error: " + e.toString());
    }
  }

  String getUserChoosedLanguage() {
    String strResult = '';
    try {
      strResult = getString(Constants.kUserLanguage);
    } catch (e) {
      AppUtil.showLog("getUserChoosedLanguage Error: " + e.toString());
    }
    AppUtil.showLog("getUserChoosedLanguage strResult: " + strResult);
    return strResult;
  }

  saveUserChoosedLanguage(String _languageCode) {
    try {
      AppUtil.showLog(
          "saveUserChoosedLanguage _languageCode: " + _languageCode);
      saveString(Constants.kUserLanguage, _languageCode);
    } catch (e) {
      AppUtil.showLog("saveUserChoosedLanguage Error: " + e.toString());
    }
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    return version;
  }

  Future<String> getAppPackagename() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.packageName;
    return version;
  }

  Future<String> getDeviceId() async {
    try {
      if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? "";
      } else if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        final androidId = await androidIdPlugin.getId();
        return androidId ?? "";
      }
    } catch (e) {
      AppUtil.showLog("getDeviceId Error: $e");
    }
    return "";
  }

  static bool isTablet() {
    bool isTablet = false;
    if (Get.context != null) {
      isTablet = Get.context!.isTablet;
    }

    return isTablet;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    return diff == 0 && now.day == date.day;
  }

  DateTime? getDateFromStringDateTimeInput(String? _value) {
    DateTime? result;
    if (_value == null || _value.isEmpty) {
      return null;
    }
    final components = _value.split("/");
    if (components.length == 3) {
      final day = int.tryParse(components[0]);
      final month = int.tryParse(components[1]);
      final year = int.tryParse(components[2]);

      if (day == null || day < 1 || day > 31) {
        return null;
      }
      if (month == null || month < 1 || month > 12) {
        return null;
      }
      if (year == null || year < 1900 || year > 2050) {
        return null;
      }

      final date = DateTime(year, month, day);
      if (_value.length == 10 &&
          date.year == year &&
          date.month == month &&
          date.day == day) {
        result = date;
      } else {
        result = null;
      }
      return result;
    }
  }

  //date1 > date 2 ==> result_manager -1
  //date1 = date 2 ==> result_manager 0
  //date1 < date 2 ==> result_manager 1
  static int compare2DateWithoutTime(DateTime date1, DateTime date2) {
    var d1 = DateTime(date1.year, date1.month, date1.day);
    var d2 = DateTime(
        date2.year, date2.month, date2.day); //you can add today's date here
    return d2.compareTo(d1);
  }

  static String doubleFormatMoney(double n) {
    String output = NumberFormat.decimalPattern().format(n);
    return output;
  }

  static bool twoDateIsEqual(DateTime date1, DateTime date2) {
    bool isSelected = DateTime(date1.year, date1.month, date1.day)
            .difference(DateTime(date2.year, date2.month, date2.day))
            .inDays ==
        0;
    return isSelected;
  }

  static String formatPhoneNumberWith0(String phoneNumber) {
    showLog('formatPhoneNumberWith0 phoneNumber input: $phoneNumber');
    if (phoneNumber.isEmpty || phoneNumber.length < 8) {
      phoneNumber = '';
    } else if (!phoneNumber.startsWith('0') &&
        !phoneNumber.startsWith('+') &&
        !phoneNumber.startsWith('84')) {
      phoneNumber = '0$phoneNumber';
    }

    showLog('formatPhoneNumberWith0 phoneNumber output: $phoneNumber');
    return phoneNumber;
  }

  static String formatPhoneNumberForceStartWith0(String phoneNumber) {
    if (phoneNumber.isEmpty || phoneNumber.length < 8) {
      phoneNumber = '';
    } else if (!phoneNumber.startsWith('0') &&
        !phoneNumber.startsWith('+') &&
        !phoneNumber.startsWith('84')) {
      phoneNumber = '0$phoneNumber';
    } else if (phoneNumber.startsWith('84')) {
      phoneNumber = '0${phoneNumber.substring(2)}';
    }

    return phoneNumber;
  }

  static String formatGenderForDisplay(String? strGender) {
    if (strGender == null) return '';
    String genderName = 'Nam';
    switch (strGender.toLowerCase()) {
      case 'male':
        genderName = 'Nam';
        break;
      case 'female':
        genderName = 'Nữ';
        break;
      case 'both':
        genderName = 'Tất cả';
        break;
      case 'other':
        genderName = 'Không xác định';
        break;
      default:
        genderName = 'Nam';
        break;
    }

    return genderName;
  }

  static String formatAppointmentTypeForDisplay(String? pMethodType) {
    if (pMethodType == null) return '';
    String methodType = 'Tại viện';
    switch (pMethodType.toLowerCase()) {
      case 'home':
        methodType = 'Tại nhà';
        break;
      case ' ':
        methodType = 'Tại viện';
        break;
      case 'both':
        methodType = 'Tại nhà, Tại viện';
        break;
      case 'other':
        methodType = 'Tại nhà, Tại viện';
        break;
      default:
        methodType = 'Tại viện';
        break;
    }
    return methodType;
  }

  static double formatDiscountForDisplay(double originPrice, double salePrice) {
    double discountValue = 0;
    discountValue = 100 * ((originPrice - salePrice) / originPrice);
    return discountValue;
  }

  static String formatAgeForDisplay(int? minAge, int? maxAge) {
    String result = '';
    if (minAge == null || maxAge == null) return '';
    if (minAge == 0 && maxAge >= 100) {
      result = 'Tất cả';
    }
    if (minAge == 0 && maxAge < 100) {
      result = 'Dưới $maxAge tuổi';
    }
    if (minAge > 0 && maxAge >= 100) {
      result = 'Trên $minAge tuổi';
    }

    if (minAge > 0 && maxAge < 100) {
      result = 'Từ $minAge tuổi đến $maxAge tuổi';
    }
    // AppUtil.showLog('formatAgeForDisplay minAge: $minAge, maxAge: $maxAge, result_manager: $result_manager');
    return result;
  }

  static void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static bool isNumeric(String s) {
    if (s.trim() == '') {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static bool isPhoneValidWithout0(String? phoneNo) {
    if (phoneNo == null) return false;
    if (phoneNo.startsWith('0') && phoneNo.length != 10) return false;
    if (phoneNo.startsWith('+') && phoneNo.length != 12) return false;
    if (phoneNo.startsWith('84') && phoneNo.length < 9 && phoneNo.length > 11) {
      return false;
    }
    if (phoneNo.length < 9 || phoneNo.length > 12) {
      return false;
    }
    final regExp = RegExp(r'(84[3|5|7|8|9]|0[3|5|7|8|9])+([0-9]{8})');
    bool result = regExp.hasMatch(phoneNo);
    return result;
    // return regExp.hasMatch(phoneNo);
  }

  static bool isEmailValid(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  static bool isIntroShowed() {
    try {
      if (getBool(Constants.kFirstTimeOpenApp) == false) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static void saveFirstTimeOpenApp() {
    saveBool(Constants.kFirstTimeOpenApp, true);
  }

  static String formatImageUrlWithPlaceholder(String url) {
    String placeHolder = 'assets/image_default.png';
    return isValidURL(url) ? url : placeHolder;
  }

  static bool isValidURL(String url) {
    return ((url.startsWith('http') || url.startsWith('https')) &&
        url.length > 10);
  }

  static void fieldFocusChange(
    BuildContext? context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    if (context != null) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  static String getWeekDayNameShort(DateTime date) {
    String result = '';
    switch (date.weekday) {
      case 1: //monday
        result = 'T2';
        break;
      case 2: //tuesday
        result = 'T3';
        break;
      case 3: //wednesday
        result = 'T4';
        break;
      case 4: //thursday
        result = 'T5';
        break;
      case 5: //friday
        result = 'T6';
        break;
      case 6: //saturday
        result = 'T7';
        break;
      case 7: //sunday
        result = 'CN';
        break;
    }

    return result;
  }

  static String getWeekDayNameFull(DateTime date) {
    String result = '';
    switch (date.weekday) {
      case 1: //monday
        result = 'Thứ 2';
        break;
      case 2: //tuesday
        result = 'Thứ 3';
        break;
      case 3: //wednesday
        result = 'Thứ 4';
        break;
      case 4: //thursday
        result = 'Thứ 5';
        break;
      case 5: //friday
        result = 'Thứ 6';
        break;
      case 6: //saturday
        result = 'Thứ 7';
        break;
      case 7: //sunday
        result = 'Chủ nhật';
        break;
    }

    return result;
  }

  static void showLoading({bool dismissOnTap = true}) {
    EasyLoading.show(dismissOnTap: dismissOnTap);
  }

  static void hideLoading() {
    EasyLoading.dismiss();
  }

  // Using Getx
  static String getString(String key) {
    String result = '';
    var storage = Get.find<SharedPreferences>();
    if (storage.containsKey(key) && storage.getString(key) != null) {
      result = storage.getString(key)!;
    }
    return result;
  }

  static void saveString(String key, String value) {
    final prefs = Get.find<SharedPreferences>();
    prefs.setString(key, value);
  }

  static bool getBool(String key) {
    bool result = false;
    var storage = Get.find<SharedPreferences>();
    if (storage.containsKey(key) && storage.getBool(key) != null) {
      result = storage.getBool(key)!;
    }
    return result;
  }

  static void saveBool(String key, bool value) {
    final prefs = Get.find<SharedPreferences>();
    prefs.setBool(key, value);
  }

  static int getInt(String key) {
    int result = 0;
    var storage = Get.find<SharedPreferences>();
    if (storage.containsKey(key) && storage.getInt(key) != null) {
      result = storage.getInt(key)!;
    }
    return result;
  }

  static void saveInt(String key, int value) async {
    final prefs = Get.find<SharedPreferences>();
    prefs.setInt(key, value);
  }

  static void showNormalToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        backgroundColor: AppColors.black,
        textColor: AppColors.white,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5);
  }

  static void showToast(String msg) {
    showSimpleNotification(
        Text(
          msg,
          style: Styles.styleTextNormalMainColor,
          maxLines: 4,
        ),
        duration: const Duration(milliseconds: 2500),
        background: AppColors.white,
        slideDismissDirection: DismissDirection.horizontal);
  }

  static void showToastError(
    String msg, {
    bool isCenter = false,
  }) {
    showSimpleNotification(
        Text(
          msg,
          style: Styles.styleTextNormalWhiteColor,
          textAlign: isCenter ? TextAlign.center : null,
          maxLines: 4,
        ),
        duration: const Duration(milliseconds: 2500),
        background: AppColors.redPrimary,
        slideDismissDirection: DismissDirection.horizontal);
  }

  static void showToastResult(String msg,
      {String? actionTitle, Function? actionOnTap}) {
    showSimpleNotification(
        Row(
          children: [
            Expanded(
              child: Text(
                msg,
                style: Styles.styleTextNormalMainColor,
              ),
            ),
            SizedBox(
              width: actionOnTap != null ? 10 : 0,
            ),
            actionTitle != null
                ? EaseInWidget(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.colorPrimary, width: 1)),
                      child: Text(
                        actionTitle,
                        style: Styles.styleTextSmallPrimaryColorLight,
                        maxLines: 4,
                      ),
                    ),
                    onTap: actionOnTap != null ? actionOnTap : () {},
                  )
                : SizedBox()
          ],
        ),
        duration: const Duration(milliseconds: 5000),
        background: AppColors.white,
        slideDismissDirection: DismissDirection.horizontal);
  }

  static void showLog(String text) {
    // if (BuildConfig.instance.environment == Environment.DEVELOPMENT) {
    debugPrint('====> $text');
    // }
  }

  static DateFormat dateFormat = DateFormat("dd-MM_HH:mm:ss");
  static void showLogFull(String text) {
    // if (BuildConfig.instance.environment == Environment.DEVELOPMENT) {
    log('CSC_${dateFormat.format(DateTime.now())}: $text');
    // }
  }
}
