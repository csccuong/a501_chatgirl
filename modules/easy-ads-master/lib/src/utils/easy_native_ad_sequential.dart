import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

/// A wrapper native ad widget that loads high-floor and normal-floor native ads sequentially.
/// It prioritizes loading and showing the high-floor ad (`adIdHigh`).
/// The normal-floor fallback ad (`adId`) is ONLY requested if the high-floor ad fails to load,
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
    }

    // 2. If High has already failed, load Fallback immediately
    if (_nativeAdHigh != null && _nativeAdHigh!.isAdLoadedFailed) {
      if (_nativeAdFallback == null) {
        EasyAds.instance.preloadNativeAd(
          adId: widget.adId,
          factoryId: widget.factoryId,
          cacheKey: widget.cacheKey,
          height: widget.height,
          adNetwork: widget.adNetwork,
        );
      }
    }

    // 3. Listen to ad events to dynamically load Fallback when High fails
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      // Check if the high floor ad failed to load
      if (event.adUnitId == widget.adIdHigh && event.type == AdEventType.adFailedToLoad) {
        if (_nativeAdFallback == null) {
          EasyAds.instance.preloadNativeAd(
            adId: widget.adId,
            factoryId: widget.factoryId,
            cacheKey: widget.cacheKey,
            height: widget.height,
            adNetwork: widget.adNetwork,
          );
        }
      }

      // Rebuild widget when any of the ads load or fail
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

  void _updateAdInstances() {
    _nativeAdHigh = EasyAds.instance.getCachedNativeAd(widget.cacheKeyHigh);
    _nativeAdFallback = EasyAds.instance.getCachedNativeAd(widget.cacheKey);
  }

  @override
  void didUpdateWidget(covariant EasyNativeAdSequential oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _streamSubscription?.cancel();
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
    super.dispose();
  }
}
