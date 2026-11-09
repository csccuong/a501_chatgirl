import 'package:flutter/material.dart';
import 'easy_ad_loading_popup.dart';

class EasyLoadingSplash extends StatelessWidget {
  final Widget? customSplash;
  final String? message;

  const EasyLoadingSplash({Key? key, this.customSplash, this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EasyAdLoadingPopup();
  }
}
