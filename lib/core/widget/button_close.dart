import 'package:flutter/material.dart';

import '../anim/ease_in_widget.dart';
import '../values/app_colors.dart';

class ButtonClose extends StatelessWidget {
  final Function()? onTap;

  const ButtonClose({Key? key,this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EaseInWidget(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        color: AppColors.transparent,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius:  BorderRadius.circular(12.0),
              color: AppColors.colorPrimary.withAlpha(15),
            ),
            child: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.colorPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
