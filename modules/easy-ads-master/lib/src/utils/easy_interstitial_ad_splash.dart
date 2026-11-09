import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'easy_ad_loading_popup.dart';

class EasyInterstitialAdSplash extends StatefulWidget {
  final AdNetwork adNetwork;
  final String adId;
  final String? adIdName;
  final void Function()? onShowed;
  final void Function()? onFailed;
  final void Function()? adDismissed;
  final void Function()? onAdImpression;

  const EasyInterstitialAdSplash({
    super.key,
    this.adNetwork = AdNetwork.admob,
    required this.adId,
    this.adIdName,
    this.onShowed,
    this.adDismissed,
    this.onFailed,
    this.onAdImpression,
  });

  @override
  State<EasyInterstitialAdSplash> createState() =>
      _EasyInterstitialAdSplashState();
}

class _EasyInterstitialAdSplashState extends State<EasyInterstitialAdSplash>
    with WidgetsBindingObserver {
  late final EasyAdBase? _interstitialAd = EasyAds.instance.createInterstitial(
    adNetwork: widget.adNetwork,
    adId: widget.adId,
    adIdName: widget.adIdName,
    immersiveModeEnabled: true,
  );

  StreamSubscription? _streamSubscription;
  Timer? _timeoutTimer;
  bool _isDisposed = false;
  bool _adShowTriggered = false;

  void _dismissAndFail() {
    if (_isDisposed) return;
    _isDisposed = true;
    _timeoutTimer?.cancel();
    _streamSubscription?.cancel();
    EasyAds.instance.setFullscreenAdShowing(false);
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    widget.onFailed?.call();
  }

  void _dismissAndClose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _timeoutTimer?.cancel();
    _streamSubscription?.cancel();
    EasyAds.instance.setFullscreenAdShowing(false);
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    widget.adDismissed?.call();
  }

  Future<void> _showAd() => Future.delayed(
        const Duration(seconds: 1),
        () {
          _timeoutTimer?.cancel();
          if (_isDisposed || !mounted) return;
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (!_adShowTriggered) {
              _adShowTriggered = true;
              _interstitialAd?.show();
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    if (widget.adId.isEmpty || widget.adId == 'null' || _interstitialAd == null) {
      EasyAds.instance.setFullscreenAdShowing(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        widget.onFailed?.call();
      });
      super.initState();
      return;
    }

    EasyAds.instance.setFullscreenAdShowing(true);

    // Timeout after 5 seconds if ad fails or hangs
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      _dismissAndFail();
    });

    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.interstitial &&
          (event.adUnitId == widget.adId || event.adUnitId == null || event.adUnitId == '')) {
        switch (event.type) {
          case AdEventType.adLoaded:
            if (_appLifecycleState == AppLifecycleState.resumed) {
              _showAd();
            } else {
              _adFailedToShow = true;
            }
            break;
          case AdEventType.adShowed:
            _timeoutTimer?.cancel();
            widget.onShowed?.call();
            break;
          case AdEventType.onAdImpression:
            widget.onAdImpression?.call();
            break;
          case AdEventType.adFailedToLoad:
            _dismissAndFail();
            break;
          case AdEventType.adDismissed:
            _dismissAndClose();
            break;
          case AdEventType.adFailedToShow:
            if (_appLifecycleState != AppLifecycleState.resumed) {
              _adFailedToShow = true;
            } else {
              _dismissAndFail();
            }
            break;
          default:
            break;
        }
      }
    });

    if (_interstitialAd?.isAdLoaded == true) {
      if (_appLifecycleState == AppLifecycleState.resumed) {
        _showAd();
      } else {
        _adFailedToShow = true;
      }
    } else {
      _interstitialAd?.load();
    }

    super.initState();
  }

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  bool _adFailedToShow = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed && _adFailedToShow) {
      _showAd();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timeoutTimer?.cancel();
    _streamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const EasyAdLoadingPopup();
  }
}
