import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class EasyBannerAd extends StatefulWidget {
  final AdNetwork adNetwork;
  final AdSize? adSize;
  final String adId;
  final bool isCollapsible;
  final int? reloadInterval;

  const EasyBannerAd({
    this.adNetwork = AdNetwork.admob,
    this.adSize,
    required this.adId,
    this.isCollapsible = false,
    this.reloadInterval,
    Key? key,
  }) : super(key: key);

  @override
  State<EasyBannerAd> createState() => _EasyBannerAdState();
}

class _EasyBannerAdState extends State<EasyBannerAd> {
  EasyAdBase? _bannerAd;
  StreamSubscription? _streamSubscription;
  Timer? _reloadTimer;

  @override
  Widget build(BuildContext context) {
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _reloadTimer?.cancel();
      _bannerAd?.dispose();
      _bannerAd = null;
      return const SizedBox.shrink();
    }
    return _bannerAd?.show() ?? const SizedBox();
  }

  AdSize? adSize;
  Future<void> _initAd() async {
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _reloadTimer?.cancel();
      _bannerAd?.dispose();
      _bannerAd = null;
      return;
    }
    if (adSize != null) {
      return;
    }
    bool needRebuild = false;
    if (widget.adSize != null) {
      adSize = widget.adSize!;
    } else {
      adSize = EasyAds.instance.adSize;
      if (adSize == null && mounted) {
        final screenWidth = MediaQuery.of(context).size.width.round();
        adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(screenWidth);
        EasyAds.instance.adSize = adSize;
        needRebuild = true;
      }
    }
    _bannerAd = EasyAds.instance.createBanner(
      adNetwork: widget.adNetwork,
      adSize: adSize,
      adId: widget.adId,
      isCollapsible: widget.isCollapsible,
    );
    _bannerAd?.load();
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.banner) {
        if (mounted) {
          setState(() {});
        }
      }
    });

    _startReloadTimer();
    if (needRebuild && mounted) {
      setState(() {});
    }
  }

  void _startReloadTimer() {
    _reloadTimer?.cancel();
    if (widget.reloadInterval != null && widget.reloadInterval! > 0) {
      _reloadTimer = Timer.periodic(Duration(seconds: widget.reloadInterval!), (timer) {
        _reloadAd();
      });
    }
  }

  void _reloadAd() {
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _reloadTimer?.cancel();
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) setState(() {});
      return;
    }
    _bannerAd?.dispose();
    _bannerAd = EasyAds.instance.createBanner(
      adNetwork: widget.adNetwork,
      adSize: adSize,
      adId: widget.adId,
      isCollapsible: widget.isCollapsible,
    );
    _bannerAd?.load();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant EasyBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (EasyAds.instance.isAdSuppressedByCallback) {
      _reloadTimer?.cancel();
      _bannerAd?.dispose();
      _bannerAd = null;
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    _initAd();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    _bannerAd?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
