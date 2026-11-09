import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Constants {
  static var screenWidth = WidgetsBinding.instance.window.physicalSize.width;
  static var screenHeight = window.physicalSize.height;
  static var privacy = "https://sites.google.com/view/noobgame-studio";
  static var termOfUser = "https://sites.google.com/view/noobgame-studio";
  static int timeReloadNativeAd = 15;

  static String adjustToken = 'm9oa05sircw0';
  static String adjustEventTokenIAP = 'yn2dg1';
  static String GSMAccessToken = "6aeeeaf0c3a0fbea0a8d2aec";



  static const String kCountReminder = 'kCountReminder';

  static const String firstTimeOpen = "firstTimeOpen";

  static const String kShowConsentForm = 'kShowConsentForm';
  static const String KeyAppConfigAndroid = "android_app_config";
  static const String KeyAppConfigIOS = "ios_app_config";
  static const String KeyAppAdsAndroid = "app_ads_android";
  static const String KeyAppAdsIOS = "app_ads_ios";
  static const String kConversationId = 'kConversationId';

  static const String kCountFreeUsage = 'kCountFreeUsage';


  static const String kSendEventWatch5AdFullSuccess =
      'kSendEventWatch5AdFullSuccess'; //Lưu lịch sử đã bắn event user xem 5 add full đến Adjust chưa
  static const String kSendEventWatch10AdFullSuccess =
      'kSendEventWatch10AdFullSuccess';//Lưu lịch sử đã bắn event user xem 10 add full đến Adjust chưa
  static const String kSendEventWatch5AdRewardSuccess =
      'kSendEventWatch5AdRewardSuccess'; //Lưu lịch sử đã bắn event user xem 5 add full đến Adjust chưa
  static const String kSendEventWatch10AdRewardSuccess =
      'kSendEventWatch10AdRewardSuccess';
  static int countWatchAdFull = 0;
  static int countWatchAdReward = 0;
  static const String kCountWatchAdFull = 'kCountWatchAdFull';
  static const String kCountWatchAdReward = 'kCountWatchAdReward';
  static const String kLastCheckinDate = 'kLastCheckinDate';
  static const String kCheckinStreak = 'kCheckinStreak';
  static const String kUserOpenAppFirstTime =
      'kUserOpenAppFirstTime'; //Lưu thông tin ngày đầu tiên user mở app, để tính retention các ngày tiếp theo
  static const String kUserRetentionDay1 =
      'kUserRetentionDay1'; //ưu lịch sử đã bắn event user retention day 1 chưa
  static const String kUserRetentionDay3 =
      'kUserRetentionDay3'; //ưu lịch sử đã bắn event user retention day 3 chưa
  static const String kUserRetentionDay7 =
      'kUserRetentionDay7'; //ưu lịch sử đã bắn event user retention day 7 chưa
  static const String kUserRetentionDay14 =
      'kUserRetentionDay14'; //ưu lịch sử đã bắn event user retention day 14 chưa
  static const String kUserRetentionDay20 =
      'kUserRetentionDay20'; //ưu lịch sử đã bắn event user retention day 20 chưa
  static const String kUserRetentionDay30 =
      'kUserRetentionDay30'; //ưu lịch sử đã bắn event user retention day 30 chưa

  static bool isMobileAdsSDKInit = false;
  static bool kIABTCF_PurposeConsents = false;
  static bool isConsentDialogShowing = false;

  static const String IS_SHOW_INTRODUCE = "IS_SHOW_INTRODUCE";

  static const String kIsPurchase = 'kIsPurchase';
  static const String kIsRemoveAds = 'kIsRemoveAds';
  static const String kUserId = 'userId';
  static const String kUserName = 'userName';
  static const String kUserPhone = 'userPhone';
  static const String kUserAvatar = 'userAvatar';
  static const String kUserInfo = 'userInfo';
  static const String profileId = 'profileId';
  static const String fcmToken = 'fcm_token';
  static const String kAccessToken = 'access_token';
  static const String kRefreshToken = 'refresh_token';
  static const kFirstTimeOpenApp = 'isFirstTimeOpenApp';

  static const String kUserLanguage = 'kUserLanguage';

  static String imagedefault = "assets/image_default.png";
  static String imageLoading = "assets/image_default.png";

  // static const String ARG_TYPE_CREATE = "ARG_TYPE_CREATE";
  // static const String ARG_TYPE_EDIT = "ARG_TYPE_EDIT";
  static const String CommonErrorMessage = "Không thành công. Vui lòng thử lại";

  static const int RESPONSE_STATUS_SUCCESS = 0;
  static const int RESPONSE_STATUS_FAIL = 1;
  static const String RESPONSE_CODE_SUCCESS = "SUCCESS";

  static const String RESULT_SUCCESS = "RESULT_SUCCESS";
  static const String RESULT_FAILURE = "RESULT_FAILURE";

  static const String CONFIRM_OK = "CONFIRM_OK";
  static const String CONFIRM_CANCEL = "CONFIRM_CANCEL";

  static String timeZoneName = 'UTC';
  static String notificationChannelId = 'waifu';
  static String notificationChannelName = 'waifu';
  static String notificationChannelDesc = 'waifu notifications.';
}
