

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'app_setting.dart';


class Utils {

  static String getTitleDayOnlyFromDay(DateTime date) {
    var today = DateTime.now();
    var yesterday = today.subtract(Duration(days: 1));
    var tomorrow = today.add(Duration(days: 1));
    var dateFormater = DateFormat("EEE dd MMM", AppSetting.selectedLanguageCode);
    if (date.day == today.day) {
      return "Today".tr;
    } else if (date.day == yesterday.day) {
      return "Yesterday".tr;
    } else if (date.day == tomorrow.day) {
      return "Tomorrow".tr;
    } else {
      return dateFormater.format(date);
    }
  }

  String getCurrencySymbol(String currencyCode) {
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }
}