import 'package:get/get.dart';

import 'core/utils/storage_util.dart';

class DenpendencyInjection {
  static Future<void> init() async {
    await Get.putAsync(() => StorageUtil().init());
    // await Get.putAsync(VideoCallService().init());
    // await Get.putAsync(() => VideoCallService().init());
  }
}
