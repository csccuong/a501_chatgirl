
import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/popup_confirm_quit/popup_confirm_quit_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_setting.dart';
import '../../helper/firebase_remote_config_service.dart';

class PopupConfirmQuitPage extends GetView<PopupConfirmQuitController> {
  @override
  PopupConfirmQuitController get controller => Get.isRegistered<PopupConfirmQuitController>() ? Get.find<PopupConfirmQuitController>() : Get.put(PopupConfirmQuitController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 30, right: 30),
      decoration: BoxDecoration(
          color: Colors.transparent
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),
          padding: EdgeInsets.only(top: 10),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          controller.onSelectCancel();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Obx(() => Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                    child: controller.countDownValue.value > 0
                    ? Text(
                      controller.title.value.tr + "  (" + controller.countDownValue.value.toString() + ")",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF797979)
                      ),
                      textAlign: TextAlign.center,
                    ) : Text(
                      controller.title.value.tr,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF797979)
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
              )),
              SizedBox(
                height: 20,
              ),
              Obx(() => Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  controller.desc.value.tr,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF797979)
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
              SizedBox(height: 40,),
              GestureDetector(
                onTap: () {
                  if (controller.isEnableButton1.value) {
                    controller.onSelectConfirm();
                  }
                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      controller.titleButton1.value.tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: controller.isEnableButton1.value ? Color(0xFF5547AE) : AppColors.textColorGreyLight
                      ),
                    ),
                  ),
                ),
              ),
                // child: Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Flexible(
                //       flex: 1,
                //       child: GestureDetector(
                //         onTap: () {
                //           if (controller.isEnableButton1.value) {
                //             controller.onSelectConfirm();
                //           }
                //         },
                //         child: Obx(() => Container(
                //           height: 50,
                //           child: Container(
                //               width: double.infinity,
                //               height: double.infinity,
                //               decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.circular(20),
                //                   color: controller.isEnableButton1.value ? Color(0xFF2F2189) : Color(0xFFBBBBBB)
                //               ),
                //               child: Stack(
                //                 children: [
                //                   Positioned(
                //                     top: 0,
                //                     left: 0,
                //                     right: 0,
                //                     child: Container(
                //                       height: 46,
                //                       width: double.infinity,
                //                       decoration: BoxDecoration(
                //                           borderRadius: BorderRadius.circular(20),
                //                           color: controller.isEnableButton1.value ? Color(0xFF5547AE) : Color(0xFFBBBBBB)
                //                       ),
                //                       child: Center(
                //                         child: Text(
                //                           controller.titleButton1.value,
                //                           style: TextStyle(
                //                               fontSize: 14,
                //                               fontWeight: FontWeight.w700,
                //                               color: Colors.white
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   )
                //                 ],
                //               )
                //           ),
                //         )),
                //       ),
                //     ),
                //     SizedBox(
                //       width: 20,
                //     ),
                //     Flexible(
                //       flex: 1,
                //       child: GestureDetector(
                //         onTap: () {
                //           controller.onSelectCancel();
                //         },
                //         child: Container(
                //           height: 50,
                //           child: Container(
                //               width: double.infinity,
                //               height: double.infinity,
                //               decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.circular(20),
                //                   color: Color(0xFF17B5C3)
                //               ),
                //               child: Stack(
                //                 children: [
                //                   Positioned(
                //                     top: 0,
                //                     left: 0,
                //                     right: 0,
                //                     child: Container(
                //                       height: 46,
                //                       width: double.infinity,
                //                       decoration: BoxDecoration(
                //                           borderRadius: BorderRadius.circular(20),
                //                           color: Color(0xFF56EEFB)
                //                       ),
                //                       child: Center(
                //                         child: Text(
                //                           controller.titleButton2.value,
                //                           style: TextStyle(
                //                               fontSize: 14,
                //                               fontWeight: FontWeight.w700,
                //                               color: Colors.white
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                   )
                //                 ],
                //               )
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              // ),
              SizedBox(
                height: 10,
              ),
              // Obx(() => (controller.isNativeAdMediumLoaded.value && controller.nativeAdMedium != null
              //     && !AppSetting.isPremiumUser.value && FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.native_popup_confirm_quit))
              //     ? controller.getNativeAdWidgetSmall(ad: controller.nativeAdMedium! )
              //     : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

}