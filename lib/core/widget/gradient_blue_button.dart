import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../anim/ease_in_widget.dart';
import '../values/app_colors.dart';
import '../values/styles.dart';

class GradientBlueButton extends StatelessWidget {
  const GradientBlueButton(
    this.btnTitle, {
    Key? key,
    required this.onTap,
    this.leftIcon,
    this.rightIcon,
    this.borderRadius,
    this.noShadow = false,
  }) : super(key: key);

  final String btnTitle;
  final Function onTap;
  final Icon? leftIcon;
  final Icon? rightIcon;
  final double? borderRadius;
  final bool? noShadow;

  @override
  Widget build(BuildContext context) {
    return EaseInWidget(
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(borderRadius != null ? borderRadius! : 20),
          gradient:  const LinearGradient(
            colors: [AppColors.colorPrimary, AppColors.colorGradientButtonEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: noShadow == true
              ? []
              : [
            BoxShadow(
              color: AppColors.colorPrimary.withAlpha(70),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leftIcon != null ? leftIcon!.marginOnly(right: 8) : const SizedBox(),
              Text(
                btnTitle,
                style: Styles.styleTextNormalWhiteColorBold,
              ),
              rightIcon != null ? rightIcon!.marginOnly(left: 8) : const SizedBox(),
            ],
          ),
        ),
      ),
      onTap: () => onTap(),
    );
  }
}
