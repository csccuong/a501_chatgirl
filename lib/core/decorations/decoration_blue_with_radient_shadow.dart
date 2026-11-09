import 'package:flutter/material.dart';

import '../values/app_colors.dart';

BoxDecoration decorationBlueWithRadientShadow({double? borderRadius}) {
  return BoxDecoration(
    color: AppColors.colorPrimary,
    borderRadius: BorderRadius.circular(borderRadius ?? 30),
    gradient: const LinearGradient(
      colors: [AppColors.colorPrimary, AppColors.colorGradientButtonEnd],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.colorPrimary.withAlpha(70),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
}