import 'package:flutter/material.dart';
import '../../helper/firebase_helper.dart';

/// NavigatorObserver that tracks screen views with standardized Activity/Screen names,
/// mirroring the robust implementation in dxx_shortdrama.
class AppRouteObserver extends NavigatorObserver {
  static const Map<String, String> _screenNameMap = {
    '/': 'SplashScreen',
    '/splash': 'SplashScreen',
    'splash': 'SplashScreen',
    'SplashScreen': 'SplashScreen',
    '/introduce': 'OnboardScreen',
    'OnboardScreen': 'OnboardScreen',
    '/home': 'HomeScreen',
    'HomeScreen': 'HomeScreen',
    '/language': 'LanguageScreen',
    'LanguageScreen': 'LanguageScreen',
    '/premium': 'PremiumScreen',
    'PremiumScreen': 'PremiumScreen',
    '/chat_detail': 'ChatDetailScreen',
    '/detail': 'CharacterDetailScreen',
    '/album': 'AlbumScreen',
  };

  static String? _lastLoggedScreen;

  /// Idempotent logging helper: safe to call from initState, onInit, or build without duplicates.
  static void logScreen(String screenName) {
    if (_lastLoggedScreen == screenName) return;
    _lastLoggedScreen = screenName;
    try {
      FirebaseHelper.setTrackingScreenName(screenName);

      // Safeguard for funnel: when entering Splash, also record event "splash" and "Splash"
      if (screenName == 'SplashScreen') {
        FirebaseHelper.logEventName('splash', param: '');
        FirebaseHelper.logEventName('Splash', param: '');
      }
    } catch (_) {}
  }

  static void resetLastLoggedScreen() {
    _lastLoggedScreen = null;
  }

  void _trackRoute(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      final screenName = _screenNameMap[name] ?? name;
      logScreen(screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }
}
