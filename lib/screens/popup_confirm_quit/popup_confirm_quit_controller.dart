import 'dart:async';

import 'package:get/get.dart';

import '../../core/base/base_controller.dart';

class PopupConfirmQuitController extends BaseController {
  RxString title = "".obs;
  var desc = "".obs;
  RxString titleButton1 = "".obs;
  RxString titleButton2 = "".obs;
  RxInt countDownValue = 3.obs;
  Timer? _timer;
  RxBool isEnableButton1 = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    title.value = Get.arguments["title"];
    desc.value = Get.arguments["desc"];
    titleButton1.value = Get.arguments["titleButton1"];
    titleButton2.value = Get.arguments["titleButton2"];
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countDownValue.value > 0) {
        countDownValue.value -= 1;
        update();
      } else {
        if (_timer != null) {
          _timer!.cancel();
        }
        isEnableButton1.value = true;
        update();
      }
    });
  }

  @override
  void onClose() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  onSelectCancel() {
    Get.back();
    _timer!.cancel();
  }

  onSelectConfirm() {
    Get.back(result: {"result": true});
  }
}