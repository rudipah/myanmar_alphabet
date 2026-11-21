import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AdHelper {
  // ---------------------------------------------------------------
  // Production/test mode — automatically follows the build mode.
  // No manual toggling needed.
  // ---------------------------------------------------------------
  static bool get _isProduction => kReleaseMode;

  // ---------------------------------------------------------------
  // Ad Unit IDs
  // ---------------------------------------------------------------
  static String get bannerAdUnitId {
    if (_isProduction) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-4129659429509766/3143061906';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-4129659429509766/7699563630';
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    }
    // Google universal test banner ID
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String get interstitialAdUnitId {
    if (_isProduction) {
      if (Platform.isAndroid) {
        // TODO: Replace with your real Android Interstitial ad unit ID from AdMob dashboard
        // AdMob → Apps → myanmar_alphabet (Android) → Ad units → Create interstitial
        return 'ca-app-pub-4129659429509766/REPLACE_ANDROID_INTERSTITIAL';
      } else if (Platform.isIOS) {
        // TODO: Replace with your real iOS Interstitial ad unit ID from AdMob dashboard
        // AdMob → Apps → myanmar_alphabet (iOS) → Ad units → Create interstitial
        return 'ca-app-pub-4129659429509766/7699563630';
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    }
    // Google universal test interstitial ID
    return 'ca-app-pub-3940256099942544/1033776116';
  }

  // ---- Create Banner Ad ----
  static BannerAd createBannerAd({
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
    AdSize size = AdSize.banner,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(
        nonPersonalizedAds: true, // Required for child-directed / COPPA apps
      ),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  // ---- Interstitial Ad Logic ----
  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;

  /// True when a loaded interstitial is ready to show.
  static bool get isInterstitialReady => _interstitialAd != null;

  /// Loads one interstitial. Does nothing if one is already loaded or a
  /// load is already in progress, so the same ad is reused until shown.
  static Future<bool> loadInterstitialAd() async {
    if (kIsWeb) return false;
    if (_interstitialAd != null) return true;
    if (_isLoadingInterstitial) return false;

    _isLoadingInterstitial = true;
    final completer = Completer<bool>();

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd?.dispose(); // never leak a previous ad
          _interstitialAd = ad;
          debugPrint('AdMob interstitial loaded');
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
          debugPrint('AdMob interstitial failed to load: $error');
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  /// Shows the loaded interstitial. Returns `true` once it is on screen,
  /// `false` if nothing was ready or it failed to show.
  static Future<bool> showInterstitialAd() async {
    final ad = _interstitialAd;
    if (kIsWeb || ad == null) return false;

    // An AdMob interstitial can only be shown once.
    _interstitialAd = null;

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdMob interstitial showed');
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdMob interstitial failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdMob interstitial dismissed');
        ad.dispose();
      },
    );

    try {
      await ad.show();
    } catch (e) {
      debugPrint('AdMob interstitial show error: $e');
      ad.dispose();
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => false,
    );
  }
}
