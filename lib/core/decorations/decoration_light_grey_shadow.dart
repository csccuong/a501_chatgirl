import 'package:flutter/material.dart';

import '../values/app_colors.dart';

BoxDecoration decoratioLightGreyShadow({double? borderRadius}) {
  return BoxDecoration(
    color: AppColors.bgInput,
    borderRadius: BorderRadius.circular(borderRadius ?? 30),
    boxShadow: [
      BoxShadow(
        color: AppColors.bgInput.withAlpha(50),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
