import 'package:cscmobi_app/screens/home/home_page.dart';
import 'package:cscmobi_app/screens/language/language_binding.dart';
import 'package:cscmobi_app/screens/language/language_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../screens/splash/splash_binding.dart';
import '../screens/splash/splash_page.dart';
import '../screens/onboard/onboard_page.dart';
import '../screens/main_tabbar/main_tabbar_page.dart';
import '../screens/character_detail/character_detail_page.dart';
import '../screens/chat_detail/chat_detail_page.dart';
import '../screens/full_screen_image/full_screen_image_page.dart';
import '../screens/album/album_page.dart';
import '../screens/premium/premium_page.dart';

part 'app_routes.dart';

class RouteEntry<T extends GetxController> {
  final T Function() controllerBuilder;
  final Widget Function() pageBuilder;

  const RouteEntry({
    required this.controllerBuilder,
    required this.pageBuilder,
  });
}

extension GetXNavigationWithControllerExtension on GetInterface {
  Future<T?> toWithController<T, C extends GetxController>({
    required C Function() controllerBuilder,
    required Widget Function() page,
    dynamic arguments,
    String? routeName,
  }) async {
    Get.lazyPut<C>(controllerBuilder);
    return await Get.to<T>(page, arguments: arguments, routeName: routeName);
  }

  Future<T?> offWithController<T, C extends GetxController>({
    required C Function() controllerBuilder,
    required Widget Function() page,
    dynamic arguments,
    String? routeName,
  }) async {
    Get.lazyPut<C>(controllerBuilder);
    return await Get.off<T>(page, arguments: arguments, routeName: routeName);
  }

  Future<T?> offAllWithController<T, C extends GetxController>({
    required C Function() controllerBuilder,
    required Widget Function() page,
    dynamic arguments,
    String? routeName,
  }) async {
    Get.lazyPut<C>(controllerBuilder);
    return await Get.offAll<T>(page, arguments: arguments, routeName: routeName);
  }
}

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static int aniDuration = 400;
  static int aniDurationHome = 600;
  static Transition aniTransision = Transition.cupertino;

  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.INTRODUCE,
      page: () => const OnboardPage(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const MainTabbarPage(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDurationHome),
    ),
    GetPage(
      name: AppRoutes.DETAIL,
      page: () => CharacterDetailPage(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.LANGUAGE,
      page: () => LanguagePage(),
      binding: LanguageBinding(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDurationHome),
    ),
    GetPage(
      name: AppRoutes.CHAT_DETAIL,
      page: () => ChatDetailPage(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.FULL_SCREEN_IMAGE,
      page: () => const FullScreenImagePage(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.ALBUM,
      page: () => const AlbumPage(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
    GetPage(
      name: AppRoutes.PREMIUM,
      page: () => const PremiumPage(),
      transition: aniTransision,
      transitionDuration: Duration(milliseconds: aniDuration),
    ),
  ];
}
