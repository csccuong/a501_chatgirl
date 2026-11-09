import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/values/app_colors.dart';
import '../const/ad_id_name.dart';
import 'dart:async';

class NativeFullScreen extends StatefulWidget {
  final String nativeFullId;
  final String? nativeFullHighId;
  final VoidCallback handleNavigate;

  const NativeFullScreen({
    super.key,
    required this.nativeFullId,
    required this.handleNavigate,
    this.nativeFullHighId,
  });

  @override
  State<NativeFullScreen> createState() => _NativeFullScreenState();
}

class _NativeFullScreenState extends State<NativeFullScreen>
    with WidgetsBindingObserver {
  bool _closeLocked = true;
  int _secondsLeft = 2;
  Timer? _timer;
  Timer? _autoNavigateTimer;
  bool _navigated = false;
  bool _showCloseButton = false;
  bool _shouldNavigateOnResume = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 NativeFull initState - _navigated: $_navigated');
    if (AdsService.isOrganic.value) {
      debugPrint('🎬 NativeFull: organic user detected -> skipping ad');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNavigate();
      });
      return;
    }
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
    WidgetsBinding.instance.addObserver(this);

    // Fallback: nếu sau 10s chưa navigate thì tự động navigate
    Future.delayed(const Duration(seconds: 10), () {
      if (!_navigated && mounted) {
        debugPrint('⚠️ NativeFull timeout → auto navigate');
        _handleNavigate();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _autoNavigateTimer?.cancel();
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 App lifecycle changed: $state, _navigated: $_navigated');
    if (_navigated) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _shouldNavigateOnResume = true;
      debugPrint('⏸️ App paused/inactive - will navigate on resume');
    } else if (state == AppLifecycleState.resumed &&
        _shouldNavigateOnResume) {
      _shouldNavigateOnResume = false;
      debugPrint('▶️ App resumed - navigating after delay');
      Future.delayed(const Duration(milliseconds: 300), _handleNavigate);
    }
  }

  void _startCountdown() {
    if (_timer != null) return;

    debugPrint('⏱️ Starting countdown from $_secondsLeft seconds');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
        debugPrint('⏱️ Countdown: $_secondsLeft seconds left');
      } else {
        setState(() {
          _closeLocked = false;
          _secondsLeft = 0;
        });
        _timer?.cancel();
        debugPrint('✅ Close button unlocked');
      }
    });
  }

  void _handleNavigate() {
    if (_navigated) {
      debugPrint('⚠️ Already navigated, ignoring...');
      return;
    }

    if (!mounted) {
      debugPrint('⚠️ Widget not mounted, cannot navigate');
      return;
    }

    debugPrint('🚀 Navigating from NativeFull');
    _navigated = true;

    _timer?.cancel();
    _autoNavigateTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.handleNavigate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Native Ad
            widget.nativeFullHighId != null
                ? EasyNativeAdHigh(
                    factoryId: MyAdIdName.nativeFull,
                    adId: widget.nativeFullId,
                    adIdHigh: widget.nativeFullHighId!,
                    height: Get.height,
                    onImpression: () {
                      debugPrint('✅ NativeFull ad impression - _navigated: $_navigated');
                      if (!mounted) return;

                      setState(() {
                        _showCloseButton = true;
                      });

                      _startCountdown();

                      _autoNavigateTimer?.cancel();
                      _autoNavigateTimer = Timer(
                        const Duration(seconds: 8),
                        () {
                          if (!_navigated && mounted) {
                            debugPrint('⏰ Auto navigate after 8s');
                            _handleNavigate();
                          }
                        },
                      );
                    },
                    onFailedToLoad: () {
                      debugPrint('❌ NativeFull failed to load');
                      _handleNavigate();
                    },
                  )
                : EasyNativeAd(
                    factoryId: MyAdIdName.nativeFull,
                    adId: widget.nativeFullId,
                    height: Get.height,
                    onImpression: () {
                      debugPrint('✅ NativeFull ad impression');
                      if (!mounted) return;

                      setState(() {
                        _showCloseButton = true;
                      });

                      _startCountdown();

                      _autoNavigateTimer?.cancel();
                      _autoNavigateTimer = Timer(
                        const Duration(seconds: 8),
                        () {
                          if (!_navigated && mounted) {
                            debugPrint('⏰ Auto navigate after 8s');
                            _handleNavigate();
                          }
                        },
                      );
                    },
                    onFailedToLoad: () {
                      debugPrint('❌ NativeFull failed to load');
                      _handleNavigate();
                    },
                  ),

            if (_showCloseButton)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _closeLocked
                        ? null
                        : () {
                            debugPrint('👆 Close button tapped');
                            _handleNavigate();
                          },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: _closeLocked
                              ? AppColors.textColorWhite.withValues(alpha: 0.5)
                              : AppColors.textColorWhite,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
