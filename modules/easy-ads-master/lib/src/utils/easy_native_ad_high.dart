import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_ads_flutter/src/utils/easy_logger.dart';
import 'package:flutter/material.dart';

import 'easy_loading_ad.dart';

class EasyNativeAdHigh extends StatefulWidget {
  final AdNetwork adNetwork;
  final String factoryId;
  final String adId;
  final String adIdHigh;
  final double height;
  final VoidCallback? onLoaded;
  final VoidCallback? onFailedToLoad;
  final VoidCallback? onImpression;
  const EasyNativeAdHigh({
    this.adNetwork = AdNetwork.admob,
    required this.factoryId,
    required this.adId,
    required this.adIdHigh,
    required this.height,
    this.onLoaded,
    this.onFailedToLoad,
    this.onImpression,
    super.key,
  });

  @override
  State<EasyNativeAdHigh> createState() => _EasyNativeAdHighState();
}

class _EasyNativeAdHighState extends State<EasyNativeAdHigh> {
  EasyAdBase? _ad;
  EasyAdBase? _nativeAd; // fallback (all)
  EasyAdBase? _nativeAdHigh; // high priority
  Timer? _timer;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  StreamSubscription? _adEventSubscription;
  bool _finalized = false; // selection between high/fallback is done
  bool _impressionSent = false;

  @override
  void initState() {
    super.initState();
    if (EasyAds.instance.isAdSuppressedByCallback) {
      return;
    }
    _isAdLoading = true;
    // Step 1: create and load HIGH only
    _nativeAdHigh = EasyAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      adId: widget.adIdHigh,
      height: widget.height,
    );
    _nativeAdHigh?.load();

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      // If HIGH loaded -> use it and stop
      if (_nativeAdHigh?.isAdLoaded == true) {
        _timer?.cancel();
        _timer = null;
        _ad = _nativeAdHigh;
        _isAdLoaded = true;
        _finalized = true;
        // Fire loaded callback only once when selection is finalized
        widget.onLoaded?.call();
        EasyLogger().logInfo('Load native high success');
      }

      // If HIGH failed -> create and load FALLBACK (ALL) once
      if (_nativeAdHigh?.isAdLoadedFailed == true && _nativeAd == null) {
        _nativeAd = EasyAds.instance.createNative(
          adNetwork: widget.adNetwork,
          factoryId: widget.factoryId,
          adId: widget.adId,
          height: widget.height,
        );
        _nativeAd?.load();
      }

      // If FALLBACK loaded after HIGH failed -> use it and stop
      if (_nativeAdHigh?.isAdLoadedFailed == true &&
          _nativeAd?.isAdLoaded == true) {
        _timer?.cancel();
        _timer = null;
        _ad = _nativeAd;
        _isAdLoaded = true;
        _finalized = true;
        widget.onLoaded?.call();
        EasyLogger().logInfo('Load native fallback success');
      }

      // Both failed
      if (_nativeAdHigh?.isAdLoadedFailed == true &&
          _nativeAd?.isAdLoadedFailed == true) {
        _timer?.cancel();
        _timer = null;
        _isAdLoaded = false;
        _finalized = true;
        widget.onFailedToLoad?.call();
        EasyLogger().logInfo('Load native ad failed');
      }

      if (_timer == null) {
        _isAdLoading = false;
        if (mounted) setState(() {});
      }
    });

    // Listen to native ad events:
    // - Defer impression callback until after selection is finalized
    _adEventSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.native) {
        if (_finalized &&
            !_impressionSent &&
            event.type == AdEventType.onAdImpression) {
          _impressionSent = true;
          widget.onImpression?.call();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAdHigh?.dispose();
    _timer?.cancel();
    _timer = null;
    _adEventSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EasyNativeAdHigh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _timer?.cancel();
      _timer = null;
      _nativeAd?.dispose();
      _nativeAdHigh?.dispose();
      _nativeAd = null;
      _nativeAdHigh = null;
      _ad = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _timer?.cancel();
      _timer = null;
      _nativeAd?.dispose();
      _nativeAdHigh?.dispose();
      _nativeAd = null;
      _nativeAdHigh = null;
      _ad = null;
      return const SizedBox.shrink();
    }
    if (_isAdLoading) {
      return EasyLoadingAd(height: widget.height);
    }
    if (_ad == null || !_isAdLoaded) {
      return const SizedBox();
    }
    return _ad?.show() ?? const SizedBox();
  }
}
