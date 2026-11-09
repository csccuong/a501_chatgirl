import 'package:cscmobi_app/screens/popup_rating/popup_rating_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../core/values/app_colors.dart';

class PopupRatingPage extends GetView<PopupRatingController> {
  @override
  PopupRatingController get controller => Get.isRegistered<PopupRatingController>() ? Get.find<PopupRatingController>() : Get.put(PopupRatingController());

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Wrap(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => Image.asset(
                      'assets/png/rate' +  controller.currentStar.value.toInt().toString() + '.png',
                      width: 120,
                      height: 120,
                    ),),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'We like you too!'.tr,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                          fontSize: 20
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Your opinion matters to us'.tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RatingBar(
                      initialRating: controller.currentStar.value,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      minRating: 1,
                      maxRating: 5,
                      ratingWidget: RatingWidget(
                        full: Image.asset('assets/png/rated.png'),
                        half: Image.asset('assets/png/rated.png'),
                        empty: Image.asset('assets/png/unrate.png'),
                      ),
                      itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                      onRatingUpdate: (rating) {
                        controller.updateRating(rating);
                      },
                      updateOnDrag: true,
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'The best we can get'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: AppColors.main
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Image.asset(
                            'assets/png/arrow_rate.png',
                            width: 26,
                            height: 21,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                controller.onSelectBack();
                              },
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                    color: AppColors.black,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Center(
                                  child: Text(
                                    'Not now'.tr,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Flexible(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                controller.onSelectSubmit();
                              },
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                  child: Text(
                                    'Submit'.tr,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}