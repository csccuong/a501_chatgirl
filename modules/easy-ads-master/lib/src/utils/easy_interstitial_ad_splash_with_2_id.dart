import 'dart:async';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'easy_ad_loading_popup.dart';

class EasyInterstitialAdSplashWith2Id extends StatefulWidget {
  final AdNetwork adNetwork;
  final String adIdHigh;
  final String adIdAll;
  final String? adIdNameHigh;
  final String? adIdNameAll;
  final void Function()? onShowed;
  final void Function()? onFailed;
  final void Function()? adDismissed;
  final void Function()? onAdImpression;

  const EasyInterstitialAdSplashWith2Id({
    super.key,
    this.adNetwork = AdNetwork.admob,
    required this.adIdHigh,
    required this.adIdAll,
    this.adIdNameHigh,
    this.adIdNameAll,
    this.onShowed,
    this.adDismissed,
    this.onFailed,
    this.onAdImpression,
  });

  @override
  State<EasyInterstitialAdSplashWith2Id> createState() =>
      _EasyInterstitialAdSplashWith2IdState();
}

class _EasyInterstitialAdSplashWith2IdState
    extends State<EasyInterstitialAdSplashWith2Id> with WidgetsBindingObserver {
  EasyAdBase? _currentAd;
  StreamSubscription? _streamSubscription;
  Timer? _timeoutTimer;
  bool _isLoading = true;
  bool _adShown = false;
  bool _isDisposed = false;

  final List<String> _adIds = [];
  bool _currentLoadFailed = false;
  bool _currentLoadSucceeded = false;
  bool _showInitiated = false;

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

  void _dismissAndFail() {
    if (_isDisposed) return;
    _isDisposed = true;
    _isLoading = false;
    _timeoutTimer?.cancel();
    _streamSubscription?.cancel();
    EasyAds.instance.setFullscreenAdShowing(false);
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    widget.onFailed?.call();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    EasyAds.instance.setFullscreenAdShowing(true);

    // Initialize ad IDs in priority order
    _adIds.addAll([widget.adIdHigh, widget.adIdAll]);

    // Safety timeout: max 10 seconds waiting for splash inter ad
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_adShown && mounted) {
        _dismissAndFail();
      }
    });

    // Start loading process
    _loadAdsSequentially();

    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.interstitial) {
        switch (event.type) {
          case AdEventType.adLoaded:
            if (_isLoading && !_adShown) {
              _currentLoadSucceeded = true;
              _onAdLoaded();
            }
            break;
          case AdEventType.adShowed:
            _adShown = true;
            _isLoading = false;
            widget.onShowed?.call();
            break;
          case AdEventType.onAdImpression:
            widget.onAdImpression?.call();
            break;
          case AdEventType.adFailedToLoad:
            _currentLoadFailed = true;
            _onAdFailedToLoad();
            break;
          case AdEventType.adDismissed:
            _dismissAndClose();
            break;
          case AdEventType.adFailedToShow:
            _onAdFailedToShow();
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> _loadAdsSequentially() async {
    for (int i = 0; i < _adIds.length; i++) {
      if (!mounted || _adShown || _isDisposed) break;

      // Dispose previous ad if any
      _currentAd?.dispose();
      // Create only the current ad we are trying to load
      _currentAd = EasyAds.instance.createInterstitial(
        adNetwork: widget.adNetwork,
        adId: _adIds[i],
        immersiveModeEnabled: true,
      );

      // Load the current ad
      _currentLoadFailed = false;
      _currentLoadSucceeded = false;
      _showInitiated = false;
      _adFailedToShow = false;
      _currentAd?.load();

      // Wait for ad to load or fail
      await _waitForAdResult();

      // If ad loaded successfully, try to show it, then wait for result
      if (_currentAd?.isAdLoaded == true || _currentLoadSucceeded) {
        _tryShowOnce();
        await _waitForShowOrFail();
        if (_adShown) {
          break; // stop if showed successfully
        }
      }

      // If this is the last ad and it failed, call onFailed
      if (i == _adIds.length - 1) {
        _onAllAdsFailed();
        break;
      }
    }
  }

  Future<void> _waitForAdResult() async {
    int attempts = 0;
    const int maxAttempts = 160; // 8 seconds max per ad attempt (50ms * 160)

    while (attempts < maxAttempts && mounted && !_adShown && !_isDisposed) {
      await Future.delayed(const Duration(milliseconds: 50));
      attempts++;

      if (_currentAd?.isAdLoaded == true || _currentLoadSucceeded) {
        break;
      }
      if (_currentLoadFailed) {
        break;
      }
    }
  }

  void _onAdLoaded() {
    if (_currentAd?.isAdLoaded == true && !_adShown && !_isDisposed) {
      _tryShowOnce();
    }
  }

  void _onAdFailedToLoad() {
    print(
        '[EasyInterstitialAdSplashWith2Id] Ad  failed to load');
  }

  void _onAdFailedToShow() {
    print(
        '[EasyInterstitialAdSplashWith2Id] Ad  failed to show');
    _currentLoadFailed = true;
    _showInitiated = false;
  }

  void _onAllAdsFailed() {
    _dismissAndFail();
  }

  Future<void> _showAd() => Future.delayed(
        const Duration(milliseconds: 500),
        () {
          if (_isDisposed || !mounted) return;
          if (_appLifecycleState == AppLifecycleState.resumed) {
            if (mounted && _currentAd?.isAdLoaded == true) {
              _currentAd?.show();
            }
          } else {
            _adFailedToShow = true;
          }
        },
      );

  void _tryShowOnce() {
    if (_showInitiated || _adShown || _isDisposed) return;
    _showInitiated = true;
    _showAd();
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

  Future<void> _waitForShowOrFail() async {
    int attempts = 0;
    const int maxAttempts = 120; // 6 seconds max (50ms * 120)

    while (attempts < maxAttempts && mounted && !_isDisposed) {
      await Future.delayed(const Duration(milliseconds: 50));
      attempts++;

      if (_adShown) {
        break; // showed successfully
      }
      if (_currentLoadFailed) {
        break; // failed to show
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timeoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    try {
      _currentAd?.dispose();
    } catch (_) {}
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const EasyAdLoadingPopup();
  }
}
