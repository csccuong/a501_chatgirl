import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

/// A wrapper native ad widget that loads high-floor and normal-floor native ads sequentially.
/// It prioritizes loading and showing the high-floor ad (dIdHigh).
/// The normal-floor fallback ad (dId) is requested if the high-floor ad fails or times out,
/// preventing waste and maintaining a high show rate for the fallback ad unit.
class EasyNativeAdSequential extends StatefulWidget {
  final AdNetwork adNetwork;
  final String factoryId;
  final String adId;
  final String cacheKey;
  final String adIdHigh;
  final String cacheKeyHigh;
  final double height;
  final Widget? loadingWidget;
  final Widget? fallbackWidget;

  const EasyNativeAdSequential({
    this.adNetwork = AdNetwork.admob,
    required this.factoryId,
    required this.adId,
    required this.cacheKey,
    required this.adIdHigh,
    required this.cacheKeyHigh,
    required this.height,
    this.loadingWidget,
    this.fallbackWidget,
    super.key,
  });

  @override
  State<EasyNativeAdSequential> createState() => _EasyNativeAdSequentialState();
}

class _EasyNativeAdSequentialState extends State<EasyNativeAdSequential> {
  EasyAdBase? _nativeAdHigh;
  EasyAdBase? _nativeAdFallback;
  StreamSubscription? _streamSubscription;
  Timer? _fallbackTimeoutTimer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (EasyAds.instance.isAdSuppressedByCallback) {
      return;
    }
    _updateAdInstances();

    // 1. If High is not in cache/loading, start preloading it
    if (_nativeAdHigh == null) {
      EasyAds.instance.preloadNativeAd(
        adId: widget.adIdHigh,
        factoryId: widget.factoryId,
        cacheKey: widget.cacheKeyHigh,
        height: widget.height,
        adNetwork: widget.adNetwork,
      );
      _updateAdInstances();
    }

    // 2. If High has already failed, load Fallback immediately
    if (_nativeAdHigh != null && _nativeAdHigh!.isAdLoadedFailed) {
      _loadFallbackIfNeeded();
    }

    // 3. Fallback timeout safeguard: if High hasn't loaded within 3.5s, load Fallback
    _fallbackTimeoutTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && (_nativeAdHigh == null || !_nativeAdHigh!.isAdLoaded)) {
        _loadFallbackIfNeeded();
      }
    });

    // 4. Poll timer every 300ms to detect loaded/failed state changes reliably
    _pollTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final prevHighLoaded = _nativeAdHigh?.isAdLoaded ?? false;
      final prevFallbackLoaded = _nativeAdFallback?.isAdLoaded ?? false;
      final prevHighFailed = _nativeAdHigh?.isAdLoadedFailed ?? false;
      final prevFallbackFailed = _nativeAdFallback?.isAdLoadedFailed ?? false;

      _updateAdInstances();

      final currHighLoaded = _nativeAdHigh?.isAdLoaded ?? false;
      final currFallbackLoaded = _nativeAdFallback?.isAdLoaded ?? false;
      final currHighFailed = _nativeAdHigh?.isAdLoadedFailed ?? false;
      final currFallbackFailed = _nativeAdFallback?.isAdLoadedFailed ?? false;

      if (currHighFailed && _nativeAdFallback == null) {
        _loadFallbackIfNeeded();
      }

      if (prevHighLoaded != currHighLoaded ||
          prevFallbackLoaded != currFallbackLoaded ||
          prevHighFailed != currHighFailed ||
          prevFallbackFailed != currFallbackFailed) {
        setState(() {});
      }

      // If either ad is loaded, or both failed, we can stop the periodic poll
      if (currHighLoaded || currFallbackLoaded || (currHighFailed && currFallbackFailed)) {
        timer.cancel();
        _pollTimer = null;
      }
    });

    // 5. Listen to ad events to dynamically load Fallback when High fails
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitId == widget.adIdHigh && event.type == AdEventType.adFailedToLoad) {
        _loadFallbackIfNeeded();
      }

      if ((event.adUnitId == widget.adIdHigh || event.adUnitId == widget.adId) &&
          (event.type == AdEventType.adLoaded || event.type == AdEventType.adFailedToLoad)) {
        if (mounted) {
          setState(() {
            _updateAdInstances();
          });
        }
      }
    });
  }

  void _loadFallbackIfNeeded() {
    if (_nativeAdFallback == null) {
      EasyAds.instance.preloadNativeAd(
        adId: widget.adId,
        factoryId: widget.factoryId,
        cacheKey: widget.cacheKey,
        height: widget.height,
        adNetwork: widget.adNetwork,
      );
      _updateAdInstances();
      if (mounted) setState(() {});
    }
  }

  void _updateAdInstances() {
    _nativeAdHigh = EasyAds.instance.getCachedNativeAd(widget.cacheKeyHigh);
    _nativeAdFallback = EasyAds.instance.getCachedNativeAd(widget.cacheKey);
  }

  @override
  void didUpdateWidget(covariant EasyNativeAdSequential oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _streamSubscription?.cancel();
      _fallbackTimeoutTimer?.cancel();
      _pollTimer?.cancel();
      _nativeAdHigh = null;
      _nativeAdFallback = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (EasyAds.instance.isAdSuppressedByCallback) {
      return const SizedBox.shrink();
    }
    // 1. If High is loaded, show it
    if (_nativeAdHigh != null && _nativeAdHigh!.isAdLoaded) {
      return _nativeAdHigh!.show() ?? const SizedBox();
    }

    // 2. If Fallback is loaded, show it
    if (_nativeAdFallback != null && _nativeAdFallback!.isAdLoaded) {
      return _nativeAdFallback!.show() ?? const SizedBox();
    }

    // 3. If High is loading, show loading
    if (_nativeAdHigh != null && _nativeAdHigh!.isAdLoading) {
      return widget.loadingWidget ?? EasyLoadingAd(height: widget.height);
    }

    // 4. If Fallback is loading, show loading
    if (_nativeAdFallback != null && _nativeAdFallback!.isAdLoading) {
      return widget.loadingWidget ?? EasyLoadingAd(height: widget.height);
    }

    // 5. Both failed to load
    if ((_nativeAdHigh == null || _nativeAdHigh!.isAdLoadedFailed) &&
        (_nativeAdFallback == null || _nativeAdFallback!.isAdLoadedFailed)) {
      return widget.fallbackWidget ?? const SizedBox();
    }

    return widget.loadingWidget ?? EasyLoadingAd(height: widget.height);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _fallbackTimeoutTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }
}
