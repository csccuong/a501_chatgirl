import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../core/values/app_colors.dart';
import '../../../utils/app_setting.dart';
import '../home_controller.dart';
import '../home_inline_ad_models.dart';

class InlineAdSlotWidget extends StatefulWidget {
  const InlineAdSlotWidget({
    super.key,
    required this.controller,
    required this.slotIndex,
    required this.adConfig,
  });

  final HomeController controller;
  final int slotIndex;
  final HomeInlineAdConfig adConfig;

  @override
  State<InlineAdSlotWidget> createState() => _InlineAdSlotWidgetState();
}

class _InlineAdSlotWidgetState extends State<InlineAdSlotWidget> {
  NativeAd? _nativeAd;
  bool _hasStartedLoad = false;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.onInlineSlotBecameRelevant(widget.slotIndex);
    _scheduleStartLoad();
  }

  @override
  void didUpdateWidget(covariant InlineAdSlotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slotIndex != widget.slotIndex ||
        oldWidget.adConfig.logicalKey != widget.adConfig.logicalKey ||
        oldWidget.adConfig.rawAdUnitId != widget.adConfig.rawAdUnitId ||
        oldWidget.adConfig.factoryId != widget.adConfig.factoryId) {
      _resetAndLoad();
    }
  }

  @override
  void dispose() {
    _loadVersion++;
    final preservedAd = _nativeAd;
    _nativeAd = null;
    if (preservedAd != null) {
      widget.controller.recycleInlineAd(widget.slotIndex, preservedAd);
    }
    widget.controller.handleInlineSlotWidgetDisposed(
      widget.slotIndex,
      preserveLoadedState: preservedAd != null,
    );
    super.dispose();
  }

  void _resetAndLoad() {
    _loadVersion++;
    _hasStartedLoad = false;
    _disposeNativeAd();
    widget.controller.handleInlineSlotWidgetDisposed(widget.slotIndex);
    _scheduleStartLoad();
  }

  void _disposeNativeAd() {
    final adToDispose = _nativeAd;
    _nativeAd = null;
    if (adToDispose != null) {
      Future.delayed(const Duration(milliseconds: 150), () {
        adToDispose.dispose();
      });
    }
  }

  void _scheduleStartLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startLoadIfNeeded();
    });
  }

  Future<void> _startLoadIfNeeded() async {
    if (_hasStartedLoad || !widget.controller.canLoadInlineAds) {
      return;
    }

    if (widget.controller.getInlineSlotStatus(widget.slotIndex) ==
        HomeInlineAdSlotStatus.failed) {
      return;
    }

    _hasStartedLoad = true;
    widget.controller.onInlineSlotBecameRelevant(widget.slotIndex);
    widget.controller.markInlineSlotLoading(widget.slotIndex);
    final requestVersion = ++_loadVersion;

    try {
      final loadedAd = await widget.controller.claimOrLoadInlineAd(
        widget.slotIndex,
        adConfig: widget.adConfig,
      );
      if (!mounted || requestVersion != _loadVersion) {
        if (loadedAd != null) {
          widget.controller.recycleInlineAd(widget.slotIndex, loadedAd);
        }
        return;
      }
      if (loadedAd == null) {
        widget.controller.markInlineSlotFailed(widget.slotIndex);
        return;
      }

      _disposeNativeAd();
      _nativeAd = loadedAd;
      widget.controller.onInlineSlotAdLoaded(widget.slotIndex);
      setState(() {});
    } catch (_) {
      if (!mounted || requestVersion != _loadVersion) {
        return;
      }
      widget.controller.markInlineSlotFailed(widget.slotIndex);
    }
  }

  Widget _buildLoadingShimmer() {
    final skeletonColor = Colors.white.withValues(alpha: 0.10);
    final skeletonHighlight = Colors.white.withValues(alpha: 0.18);

    return Shimmer(
      duration: const Duration(seconds: 3),
      interval: const Duration(milliseconds: 300),
      color: skeletonHighlight,
      colorOpacity: 0.25,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: widget.adConfig.backgroundColor,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 12,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 140,
              height: 12,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 100,
                height: 36,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyPlaceholder() {
    final skeletonColor = Colors.white.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.adConfig.backgroundColor,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 12,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 140,
            height: 12,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 100,
              height: 36,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (AppSetting.isPremiumUser.value || AppSetting.isRemoveAds.value) {
        _disposeNativeAd();
        return const SizedBox.shrink();
      }
      final slotStatus =
          widget.controller.getInlineSlotStatus(widget.slotIndex);
      final canAttach = widget.controller.canAttachInlineSlot(widget.slotIndex);
      if (slotStatus == HomeInlineAdSlotStatus.failed) {
        return const SizedBox.shrink();
      }

      if (_nativeAd == null && !_hasStartedLoad) {
        _scheduleStartLoad();
      }

      if (slotStatus == HomeInlineAdSlotStatus.ready && !canAttach) {
        return _buildReadyPlaceholder();
      }

      if (_nativeAd == null ||
          slotStatus == HomeInlineAdSlotStatus.loading ||
          slotStatus == HomeInlineAdSlotStatus.idle ||
          (slotStatus == HomeInlineAdSlotStatus.loaded && !canAttach)) {
        return _buildLoadingShimmer();
      }

      return Container(
        width: Get.width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: widget.adConfig.backgroundColor ?? AppColors.backgroundItemColor,
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    });
  }
}
