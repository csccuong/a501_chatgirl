import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../Utils/app_setting.dart';
import '../../core/values/app_colors.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../home/home_page.dart';
import '../chats/chats_page.dart';
import '../profile/profile_page.dart';
import 'main_tabbar_controller.dart';

class MainTabbarPage extends GetView<MainTabbarController> {
  const MainTabbarPage({Key? key}) : super(key: key);

  @override
  MainTabbarController get controller =>
      Get.isRegistered<MainTabbarController>()
          ? Get.find<MainTabbarController>()
          : Get.put(MainTabbarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      body: Obx(() {
        return IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomePage(),
            ChatsPage(),
            ProfilePage(),
          ],
        );
      }),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomBottomBar(context),
          // ─── Banner Home Collapsible (ở dưới bottom nav) ───
          _buildBannerHome(),
        ],
      ),
    );
  }

  // ─── Banner Home Widget ───
  Widget _buildBannerHome() {
    return Obx(() {
      if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
        return const SizedBox.shrink();
      }
      if (!FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.banner_home)) {
        return const SizedBox.shrink();
      }
      return Container(
        color: AppColors.backgroundColor,
        width: double.infinity,
        child: SafeArea(
          top: false,
          child: EasyBannerAd(
            adNetwork: AdNetwork.admob,
            adId: MyAdIdName.bannerAll.getId,
            isCollapsible: true,
          ),
        ),
      );
    });
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return Obx(() {
      final index = controller.currentIndex.value;
      final bottomInset = MediaQuery.of(context).padding.bottom;
      final isBannerVisible = !(AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) &&
          FirebaseRemoteConfigService.getBoolConfigByKey(FirebaseRemoteConfigService.banner_home);
      final bottomPadding = isBannerVisible ? 12.0 : (bottomInset > 16.0 ? bottomInset : 16.0);

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          border: Border.all(
            color: const Color(0xFF1E2533),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.only(
          top: 14.0,
          bottom: bottomPadding,
        ),
        child: Row(
          children: [
            _navItem(
              svgPath: 'assets/icons/ic_home.svg',
              label: 'Home'.tr,
              tabIndex: 0,
              isActive: index == 0,
            ),
            _navItem(
              svgPath: 'assets/icons/ic_chat.svg',
              label: 'Chat'.tr,
              tabIndex: 1,
              isActive: index == 1,
            ),
            _navItem(
              svgPath: 'assets/icons/ic_profile.svg',
              label: 'Profile'.tr,
              tabIndex: 2,
              isActive: index == 2,
            ),
          ],
        ),
      );
    });
  }

  Widget _navItem({
    required String svgPath,
    required String label,
    required int tabIndex,
    required bool isActive,
  }) {
    final color = isActive ? AppColors.main : const Color(0xFF7E8B9B);

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(tabIndex),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
