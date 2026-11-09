import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../anim/ease_in_widget.dart';
import '../values/styles.dart';
import '/core/values/app_colors.dart';

//Default appbar customized with the design of our app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarTitleText;
  final List<Widget>? actions;
  final bool isBackButtonEnabled;
  final Widget? rightButton;
  final Function()? onBackClick;
  bool? isNoDecoration = false;

  CustomAppBar({
    Key? key,
    required this.appBarTitleText,
    this.actions,
    this.isBackButtonEnabled = true,
    this.rightButton,
    this.onBackClick,
    this.isNoDecoration,
  }) : super(key: key);

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120), // Set this height
      child: Container(
        width: double.infinity,
        decoration: isNoDecoration == true
            ? BoxDecoration(
                color: AppColors.white,
              )
            : BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorPrimary.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Row(
              children: [
                isBackButtonEnabled
                    ? EaseInWidget(
                        onTap: () {
                          if (onBackClick != null) {
                            onBackClick!();
                          } else {
                            Get.back();
                          }
                        },
                        child: Container(
                          height: 44,
                          width: 44,
                          color: AppColors.transparent,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: AppColors.colorPrimary.withAlpha(15),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_outlined,
                                size: 18,
                                color: AppColors.colorPrimary,
                              ),
                            ),
                          ),
                        ),
                      ).marginOnly(left: 16, right: 16)
                    : const SizedBox(
                        height: 44,
                        width: 44,
                      ).marginOnly(left: 16, right: 16),
                Expanded(
                  child: Center(
                    child: Text(
                      appBarTitleText,
                      style: appBarTitleText.length < 22 ? Styles.styleTextTitleMainColorBold : Styles.styleTextButtonMainColorBold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                rightButton != null
                    ? rightButton!
                    : const SizedBox(
                        width: 44,
                        height: 44,
                      ).marginOnly(left: 16, right: 16),
              ],
            ),
          ],
        ),
      ).marginOnly(top: 4),
    );
  }
}
