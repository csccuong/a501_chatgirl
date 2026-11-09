import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '/flavors/build_config.dart';
import '/flavors/env_config.dart';
import '/flavors/environment.dart';
import 'ads/const/ad_id_extension.dart';
import 'ads/const/ad_id_name.dart';
import 'ads/loading/ad_loading_page.dart';
import 'ads/manager/my_ad_id_manager.dart';
import 'api_rest/my_http_overrides.dart';
import 'core/values/constants.dart';
import 'di.dart';
import 'helper/firebase_helper.dart';
import 'helper/firebase_remote_config_service.dart';
import 'helper/iap_helper.dart';
import 'helper/notification_helper.dart';
import 'my_app.dart';
import 'utils/app_setting.dart';

final navigatorKey = Get.key;

const bool isProduction = false;

String separateDataString = "o_____o";

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = AndroidNotificationChannel(
    Constants.notificationChannelId, // id
    Constants.notificationChannelName, // title
    description: Constants.notificationChannelDesc, // description
    importance: Importance.high,
  );

  await NotificationHelper.flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    NotificationHelper.flutterLocalNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  try {
    await FirebaseRemoteConfigService.initFirebaseRemoteConfig();
    AppSetting.isInitRemoteConfig.value = true;
  } catch (e) {
    debugPrint('Firebase remote config init skipped/error: $e');
  }

  EnvConfig config = EnvConfig(
    appName: "Lover AI: AI Character Chat",
    baseUrlAuthen: "",
    baseUrlUtility: "",
    baseUrlGraphQLCore: "",
    shouldCollectCrashLog: true,
  );

  BuildConfig.instantiate(
    envType: isProduction ? Environment.PRODUCTION : Environment.DEVELOPMENT,
    envConfig: config,
  );


  HttpOverrides.global = MyHttpOverrides();

  // Run essential initializations in parallel to minimize cold-start time before runApp
  await Future.wait([
    DenpendencyInjection.init(),
    _initCrashlytics(),
    _initFirebaseAnalytics(),
  ]);


  runApp(const MyApp());

  // Non-blocking initialization of ads and platform-specific plugins
  unawaited(initPlugin());
  unawaited(_initializeAds());
}

bool _isNonFatalAppError(String errorString, [String? library]) {
  return errorString.contains('ClientException') ||
      errorString.contains('Connection closed while receiving data') ||
      library == 'image resource service' ||
      library == 'platform_views' ||
      errorString.contains('AdShowError') ||
      errorString.contains('googlemobileads') ||
      errorString.contains('google_mobile_ads') ||
      errorString.contains('setImmersiveMode') ||
      errorString.contains('Ad failed to show') ||
      errorString.contains('showAdWithoutView') ||
      errorString.contains('LayoutParams') ||
      errorString.contains('ViewGroup') ||
      errorString.contains('io.flutter.plugin.platform') ||
      errorString.contains('_sizePlatformView') ||
      errorString.contains('TextureAndroidViewController') ||
      errorString.contains('RenderAndroidView') ||
      errorString.contains('PlatformViewsController');
}

Future<void> _initCrashlytics() async {
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    final exceptionString = errorDetails.exception.toString();

    if (_isNonFatalAppError(exceptionString, errorDetails.library)) {
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails, fatal: false);
    } else {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    }
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString();

    if (_isNonFatalAppError(errorString)) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    } else {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };
}

Future<void> _initFirebaseAnalytics() async {
  await EasyAds.instance.initFirebaseAnalytics(FirebaseHelper.analytics);
}

Future<void> _initializeAds() async {
  try {
    print('🚀 Starting ads initialization...');

    // 1. Request consent (only use debugGeography in debug mode)
    final params = ConsentRequestParameters(
      consentDebugSettings: kDebugMode
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
            )
          : null,
    );

    final consentCompleter = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await _loadConsentForm();
          }
          print('✅ Consent completed');
        } catch (e) {
          print('⚠️ Consent form error: $e');
        }
        if (!consentCompleter.isCompleted) {
          consentCompleter.complete();
        }
      },
      (error) {
        print('⚠️ Consent error: ${error.message}');
        if (!consentCompleter.isCompleted) {
          consentCompleter.complete();
        }
      },
    );

    // Timeout safety for consent: max 5 seconds
    await consentCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ Consent request timed out');
      },
    );

    final IAdIdManager adIdManager = MyAdIdManager();

    await EasyAds.instance.initialize(
      adIdManager,
      unityTestMode: !isProduction,
      adMobAdRequest: const AdRequest(httpTimeoutMillis: 30000),
      admobConfiguration: RequestConfiguration(testDeviceIds: ['']),
      navigatorKey: navigatorKey,
      loadingSplash: const AdLoadingPage(),
    );

    print('✅ EasyAds initialized');

    await EasyAds.instance.initAdmob(
      appOpenAdUnitId: MyAdIdName.appOpenResume.getId,
    );

    EasyAds.instance.setAdSuppressedCallback(() {
      return AppSetting.isPremiumUser.value ||
          AppSetting.isRemoveAds.value ||
          IAPHelper.isPurchasing;
    });

    print('✅ AdMob initialized with App Open Ad');
    print('✅ All ads initialization completed successfully');
  } catch (e) {
    print('❌ Ads initialization error: $e');
  }
}

Future<void> _loadConsentForm() async {
  final completer = Completer<void>();

  ConsentForm.loadConsentForm(
    (consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();

      if (status == ConsentStatus.required) {
        consentForm.show((formError) async {
          if (formError != null) {
            print('⚠️ Consent form show error: ${formError.message}');
            if (!completer.isCompleted) completer.complete();
            return;
          }
          await _loadConsentForm();
          if (!completer.isCompleted) completer.complete();
        });
      } else {
        if (!completer.isCompleted) completer.complete();
      }
    },
    (formError) {
      print('⚠️ Consent form load error: ${formError.message}');
      if (!completer.isCompleted) completer.complete();
    },
  );

  await completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      print('⚠️ Load consent form timed out');
    },
  );
}

Future<void> initPlugin() async {
  if (Platform.isIOS) {
    try {
      final TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 200));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      print('⚠️ AppTrackingTransparency error: $e');
    }
  }
}
