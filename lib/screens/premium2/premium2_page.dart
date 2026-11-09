import 'package:cscmobi_app/core/values/app_colors.dart';
import 'package:cscmobi_app/screens/premium/premium_controller.dart';
import 'package:cscmobi_app/screens/premium2/premium2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class Premium2Page extends GetView<Premium2Controller> {
  final controller = Get.find<Premium2Controller>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 500 / 525,
                      child: Image.asset(
                        "assets/png/premium_thumb.png",
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x880D1016),
                      Color(0xEA0D1016),
                      Color(0xFF0D1016),
                      Color(0xFF0D1016),
                    ],
                    stops: [0.0, 0.22, 0.38, 0.50, 0.62, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: GetBuilder<Premium2Controller>(
                        builder: (_) {
                          return buildContent();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => controller.isShowShowClose.value
                ? Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        controller.onSelectBack();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.transparent),
                        child: Icon(
                          Icons.close_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ))
                : const SizedBox())
          ],
        ),
      ),
    );
  }

  buildContent() {
    final oCcy = new NumberFormat("#,##0.00", "en_US");
    final oCcy2 = new NumberFormat("#,##0", "en_US");
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(top: 0, left: 16, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unlock'.tr,
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF29DBFD), Color(0xFF0382C7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Text(
                      'Premium'.tr,
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(
                    () {
                      final lines = controller.listTitlePremium;
                      final half = (lines.length + 1) ~/ 2;
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < half; i++) ...[
                                  _bullet(lines[i].tr),
                                  if (i + 1 < half) const SizedBox(height: 8),
                                ],
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = half; i < lines.length; i++) ...[
                                  _bullet(lines[i].tr),
                                  if (i + 1 < lines.length)
                                    const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Container(
                height: 114,
                width: double.infinity,
                child: Row(
                  children: [
                    controller.listPremium.length >= 2
                        ? Flexible(
                            flex: 1,
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 12,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.onSelectItem(1);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        decoration: controller.itemSelected.value == 1
                                            ? BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: AppColors.backgroundItemColor,
                                                border: Border.all(
                                                  color: AppColors.main,
                                                  width: 3,
                                                ),
                                              )
                                            : BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: AppColors.backgroundItemColor,
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.1),
                                                  width: 1,
                                                ),
                                              ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              controller.listPremium[1].title.tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              controller.listPremium[1].price % 1 != 0
                                                  ? (oCcy.format(controller.listPremium[1].price)).toString() + controller.listPremium[1].currencySymbol
                                                  : (oCcy2.format(controller.listPremium[1].price)).toString() + controller.listPremium[1].currencySymbol,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: AppColors.main,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              (controller.listPremium[1].price) % 1 != 0
                                                  ? (oCcy.format((controller.listPremium[1].price / 30))).toString() + controller.listPremium[1].currencySymbol + "/day".tr
                                                  : (oCcy2.format((controller.listPremium[1].price / 30).toInt())).toString() +
                                                      controller.listPremium[1].currencySymbol +
                                                      "/day".tr,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      flex: 1,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                controller.onSelectItem(0);
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: controller.itemSelected.value == 0
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: AppColors.backgroundItemColor,
                                        border: Border.all(
                                          color: AppColors.main,
                                          width: 3,
                                        ),
                                      )
                                    : BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: AppColors.backgroundItemColor,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      controller.listPremium[0].title.tr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      controller.listPremium[0].price % 1 != 0
                                          ? (oCcy.format(controller.listPremium[0].price)).toString() + controller.listPremium[0].currencySymbol
                                          : (oCcy2.format(controller.listPremium[0].price)).toString() + controller.listPremium[0].currencySymbol,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: controller.itemSelected.value == 0 ? AppColors.main : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      (controller.listPremium[0].price) % 1 != 0
                                          ? (oCcy.format((controller.listPremium[0].price / 365))).toString() + controller.listPremium[0].currencySymbol + "/day".tr
                                          : (oCcy2.format((controller.listPremium[0].price / 365).toInt())).toString() + controller.listPremium[0].currencySymbol + "/day".tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                    height: 24,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: [Color(0xFFFB0004), Color(0xFFFF2B2E)])),
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Save ".tr + controller.percentSave.toString() + "%",
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textColor),
                                        ),
                                      ],
                                    )),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          controller.listPremium[controller.itemSelected.value].desc.tr,
                          style: TextStyle(fontSize: 14, color: AppColors.textColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        )),
                    Text(
                      controller.listPremium[controller.itemSelected.value].note.tr,
                      style: TextStyle(fontSize: 12, color: Color(0xFFC4C4C4), fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          )),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            child: Shimmer(
              duration: const Duration(seconds: 5),
              interval: const Duration(seconds: 0),
              color: Colors.white,
              // This is the default value
              colorOpacity: 1,
              // This is the default value
              enabled: true,
              // This is the default value
              direction: const ShimmerDirection.fromLTRB(),
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30)),
                child: TextButton(
                    onPressed: () {
                      controller.onSelectBuy();
                    },
                    child: Center(
                      child: Obx(() => Text(
                            controller.titleButton.value.tr,
                            style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w700, fontSize: 16),
                          )),
                    )),
              ),
            ),
          ),
          SafeArea(
            bottom: true,
            child: Container(
              height: 50,
              width: double.infinity,
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          controller.onSelectTermOfUse();
                        },
                        child: Center(
                          child: Text(
                            'Term of use'.tr,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFC4C4C4)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          controller.onSelectRestore();
                        },
                        child: Center(
                          child: Text(
                            'Restore'.tr,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFC4C4C4)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          controller.onSelectPrivacy();
                        },
                        child: Center(
                          child: Text(
                            'Privacy'.tr,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFC4C4C4)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  buildNavigation() {
    return Container(
        height: 64,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() => controller.isShowShowClose.value
                ? GestureDetector(
                    onTap: () {
                      controller.onSelectBack();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  )
                : const SizedBox())
          ],
        ));
  }

  Widget _bullet(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            height: 1.25,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
