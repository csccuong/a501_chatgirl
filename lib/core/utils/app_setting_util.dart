import '../values/constants.dart';
import 'app_util.dart';

class AppSettingUtil {

  saveShowConsentForm() {
    return AppUtil.saveBool(Constants.kShowConsentForm, true);
  }

  bool getShowConsentForm() {
    bool _value = AppUtil.getBool(Constants.kShowConsentForm);
    return _value;
  }

  saveShowTutorialByType({required String type}) {
    return AppUtil.saveBool(type, true);
  }

  bool getTutorialIsShowedByType({required String type}) {
    try {
      if (AppUtil.getBool(type) == null || AppUtil.getBool(type) == false) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }


  saveCountWatchAdFull() {
    return AppUtil.saveInt(Constants.kCountWatchAdFull, Constants.countWatchAdFull);
  }

  int getCountWatchAdFull() {
    int _count = AppUtil.getInt(Constants.kCountWatchAdFull);
    return _count;
  }

  saveFirstTimeOpenApp() {
    return AppUtil.saveString(Constants.kUserOpenAppFirstTime, DateTime.now().toIso8601String());
    // return AppUtil.saveString(Constants.kUserOpenAppFirstTime, DateFormat(Styles.FORMAT_TIMEONLY).format(DateTime.now()));
  }

  DateTime? getFirstTimeOpenApp() {
    DateTime? result;
    String strTMPFirstTime = AppUtil.getString(Constants.kUserOpenAppFirstTime);
    if (strTMPFirstTime.isNotEmpty) {
      result = DateTime.parse(strTMPFirstTime);
    }
    // AppUtil.showLogFull('getFirstTimeOpenApp ${result}');

    return result;
  }

  saveEventRetentionDay1() {
    AppUtil.saveBool(Constants.kUserRetentionDay1, true);
  }

  saveEventRetentionDay3() {
    AppUtil.saveBool(Constants.kUserRetentionDay3, true);
  }

  saveEventRetentionDay7() {
    AppUtil.saveBool(Constants.kUserRetentionDay7, true);
  }

  saveEventRetentionDay14() {
    AppUtil.saveBool(Constants.kUserRetentionDay14, true);
  }

  saveEventRetentionDay20() {
    AppUtil.saveBool(Constants.kUserRetentionDay20, true);
  }

  saveEventRetentionDay30() {
    AppUtil.saveBool(Constants.kUserRetentionDay30, true);
  }

  bool checkSendEventRetentionDay1() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay1);
    return isSuccess;
  }

  bool checkSendEventRetentionDay3() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay3);
    return isSuccess;
  }

  bool checkSendEventRetentionDay7() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay7);
    return isSuccess;
  }

  bool checkSendEventRetentionDay14() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay14);
    return isSuccess;
  }

  bool checkSendEventRetentionDay20() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay20);
    return isSuccess;
  }

  bool checkSendEventRetentionDay30() {
    bool isSuccess = AppUtil.getBool(Constants.kUserRetentionDay30);
    return isSuccess;
  }
}
