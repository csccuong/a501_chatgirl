import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'popup_yearly_sale_controller.dart';

class _BenefitItemData {
  final String icon;
  final String title;

  const _BenefitItemData({
    required this.icon,
    required this.title,
  });
}

class PopupYearlySalePage extends GetView<PopupYearlySaleController> {
  const PopupYearlySalePage({super.key});

  @override
  PopupYearlySaleController get controller =>
      Get.isRegistered<PopupYearlySaleController>()
          ? Get.find<PopupYearlySaleController>()
          : Get.put(PopupYearlySaleController());

  static const List<_BenefitItemData> _benefits = [
    _BenefitItemData(
      icon: 'assets/icons/ic_enjoy_unlimited.png',
      title: 'Enjoy Unlimited\nChats',
    ),
    _BenefitItemData(
      icon: 'assets/icons/ic_ad_free.png',
      title: 'Ad-free\nExperience',
    ),
    _BenefitItemData(
      icon: 'assets/icons/ic_get1000gems.png',
      title: 'Get 1000 Gems\nBonus',
    ),
    _BenefitItemData(
      icon: 'assets/icons/ic_fastestai.png',
      title: 'Fastest AI\nReplies',
    ),
    _BenefitItemData(
      icon: 'assets/icons/ic_unlockoutfit.png',
      title: 'Unlock\nOutfit Selections',
    ),
    _BenefitItemData(
      icon: 'assets/icons/ic_moreimage.png',
      title: 'More\nImage Choices',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF1E2838),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF29DBFD).withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/png/popup_yearly_sale_background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.70),
                              Colors.black.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.40, 0.72, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.50),
                              Colors.black.withValues(alpha: 0.20),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 0.85],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(controller),
                          const SizedBox(height: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _benefits.map(_buildBenefitCard).toList(),
                          ),
                          const SizedBox(height: 14),
                          GetBuilder<PopupYearlySaleController>(
                            builder: (c) => _buildPricingBox(c),
                          ),
                          const SizedBox(height: 12),
                          _buildContinueButton(controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PopupYearlySaleController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'The Best'.tr} ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF29DBFD), Color(0xFF0382C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Offer!'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: controller.onClosePopup,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCard(_BenefitItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: BoxDecoration(
        color: const Color(0xFF131722).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            item.icon,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(
            item.title.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingBox(PopupYearlySaleController c) {
    String perDayText = c.yearlySalePerDay.value;
    if (perDayText.endsWith('/day')) {
      perDayText = perDayText.replaceAll('/day', '/day'.tr);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xEB0D091B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF29DBFD),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29DBFD).withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: c.yearlySalePrice.value,
                          style: const TextStyle(
                            color: const Color(0xFF29DBFD),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: '/1 Year'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$perDayText. ${'Cancel anytime'.tr}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF253B),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Text(
                '${c.percentSave}% ${'Sale Off'.tr}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(PopupYearlySaleController controller) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF29DBFD), Color(0xFF0382C7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29DBFD).withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: controller.onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          'Continue'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
