import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../easy_ads.dart';

class EasyAdLoadingPopup extends StatelessWidget {
  final Widget? customPopup;
  final String? message;

  const EasyAdLoadingPopup({
    Key? key,
    this.customPopup,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final popup = customPopup ?? EasyAds.configuredLoadingAdPopup;
    if (popup != null) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: popup,
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xE60D1016),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x1FFFFFFF),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Lottie.asset(
                    'assets/json/loading_ads.json',
                    package: 'easy_ads_flutter',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Lottie.asset(
                        'assets/json/loading_ads.json',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF29DBFD),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message ?? 'Loading Ads...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
