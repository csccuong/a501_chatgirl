import 'package:flutter/material.dart';

import '../anim/ease_in_widget.dart';
import '../values/app_colors.dart';
import '../values/styles.dart';

class ButtonPrimary extends StatelessWidget {
  final String btnTitle;
  final double? btnWidth;
  final double? radius;
  final Function()? onTap;

  const ButtonPrimary({
    Key? key,
    required this.btnTitle,
    this.onTap,
    this.btnWidth,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EaseInWidget(
      onTap: onTap,
      child: Container(
        height: 45,
        width: btnWidth ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(radius != null ? radius! : 20),
          gradient: const LinearGradient(
            colors: [AppColors.colorPrimary, AppColors.colorGradientButtonEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorPrimary.withAlpha(70),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            btnTitle,
            style: Styles.styleTextNormalWhiteColor,
          ),
        ),
      ),
      // onTap: () => onTap,
    );
  }
}
