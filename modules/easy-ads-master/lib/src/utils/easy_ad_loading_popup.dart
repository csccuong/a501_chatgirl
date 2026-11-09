import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../easy_ads.dart';

class EasyAdLoadingPopup extends StatelessWidget {
  final Widget? customPopup;
  final String? message;
  final String? subMessage;

  const EasyAdLoadingPopup({
    Key? key,
    this.customPopup,
    this.message,
    this.subMessage,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            constraints: const BoxConstraints(
              minWidth: 160,
              maxWidth: 240,
            ),
            decoration: BoxDecoration(
              color: const Color(0xF20D1016),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x1FFFFFFF),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x73000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
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
                const SizedBox(height: 10),
                Text(
                  message ?? 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subMessage ?? 'This action may contain ads',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
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
