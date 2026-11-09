import 'package:flutter/material.dart';

import '../values/app_colors.dart';

BoxDecoration decorationWhiteShadow({double? borderRadius}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius ?? 30),
    boxShadow: [
      BoxShadow(
        color: AppColors.colorPrimary.withAlpha(50),
        blurRadius: 5,
        offset: const Offset(0, 3),
      ),
    ],
  );
}