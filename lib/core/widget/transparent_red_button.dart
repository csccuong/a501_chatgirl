import 'package:flutter/material.dart';

import '../anim/ease_in_widget.dart';
import '../values/app_colors.dart';
import '../values/styles.dart';

class TransparentRedButton extends StatelessWidget {
  const TransparentRedButton(
    this.btnTitle, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final String btnTitle;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return EaseInWidget(
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            btnTitle,
            style: Styles.styleTextNormalRedColorBold,
          ),
        ),
      ),
      onTap: () => onTap(),
      // onTap: () => onTap,
    );
  }
}
