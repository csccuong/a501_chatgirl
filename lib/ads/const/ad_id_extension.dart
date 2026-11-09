import 'dart:io';
import '../../core/utils/app_util.dart';
import '../../flavors/build_config.dart';
import '../../flavors/environment.dart';
import 'ad_id.dart';
import 'ad_id_name.dart';

extension AdIdEx on String {
  String get getId {
    final env = BuildConfig.instance.environment == Environment.PRODUCTION ? 'prod' : 'dev';
    final platform = Platform.isAndroid ? 'android' : 'ios';
    String? id = myAdsId[env]?[platform]?[this];
    return id ?? "null";
  }
}


