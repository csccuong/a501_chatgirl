import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class EasyNativeAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final String factoryId;
  final String adId;
  final double height;
  final VoidCallback? onLoaded;
  final VoidCallback? onFailedToLoad;
  final VoidCallback? onImpression;
  const EasyNativeAd({
    this.adNetwork = AdNetwork.admob,
    required this.factoryId,
    required this.adId,
    required this.height,
    this.onLoaded,
    this.onFailedToLoad,
    this.onImpression,
    Key? key,
  }) : super(key: key);

  @override
  State<EasyNativeAd> createState() => _EasyNativeAdState();
}

class _EasyNativeAdState extends State<EasyNativeAd> {
  EasyAdBase? _nativeAd;
  StreamSubscription? _streamSubscription;

  @override
  Widget build(BuildContext context) {
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _nativeAd?.dispose();
      _nativeAd = null;
      return const SizedBox.shrink();
    }
    return _nativeAd?.show() ?? const SizedBox();
  }

  @override
  void initState() {
    super.initState();
    if (EasyAds.instance.isAdSuppressedByCallback) {
      return;
    }
    _nativeAd = EasyAds.instance.createNative(
      adNetwork: widget.adNetwork,
      factoryId: widget.factoryId,
      adId: widget.adId,
      height: widget.height,
    );
    _nativeAd?.load();
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.native) {
        // Fire callbacks for native ad lifecycle
        switch (event.type) {
          case AdEventType.adLoaded:
            widget.onLoaded?.call();
            break;
          case AdEventType.adFailedToLoad:
            widget.onFailedToLoad?.call();
            break;
          case AdEventType.onAdImpression:
            widget.onImpression?.call();
            break;
          default:
            break;
        }
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant EasyNativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _nativeAd?.dispose();
      _nativeAd = null;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
