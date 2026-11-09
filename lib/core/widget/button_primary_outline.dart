import 'package:flutter/material.dart';

import '../anim/ease_in_widget.dart';
import '../values/app_colors.dart';
import '../values/styles.dart';

class ButtonPrimaryOutline extends StatelessWidget {
  final String btnTitle;
  final Function()? onTap;
  final double? btnWidth;
  final double? btnHeight;
  final double? radius;

  const ButtonPrimaryOutline({
    Key? key,
    required this.btnTitle,
    this.onTap,
    this.btnWidth,
    this.btnHeight,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EaseInWidget(
      onTap: onTap,
      child: Container(
        height: btnHeight ?? 45,
        width: btnWidth ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(radius != null ? radius! : 20),
          border: Border.all(color: AppColors.colorPrimary, width: 1),
        ),
        child: Center(
          child: Text(
            btnTitle,
            style: Styles.styleTextNormalPrimaryColorBold,
          ),
        ),
      ),
    );
  }
}
