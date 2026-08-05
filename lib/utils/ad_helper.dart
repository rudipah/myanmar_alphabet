import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AdHelper {
  // ---------------------------------------------------------------
  // Test Ad Unit ID (safe for development)
  // ---------------------------------------------------------------
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033776116';

  // ---------------------------------------------------------------
  // Toggle production vs test ads
  // ---------------------------------------------------------------
  static const bool _isProduction = false; // Set to true for production, false for testing

  // ---------------------------------------------------------------
  // Platform-specific Ad Unit ID
  // ---------------------------------------------------------------
  static String get bannerAdUnitId {
    if (_isProduction) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-4129659429509766/3143061906'; // Android
      } else if (Platform.isIOS) {
        return 'ca-app-pub-4129659429509766/7699563630'; // iOS
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    } else {
      // Using universal Google Test Banner ID
      return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  static String get interstitialAdUnitId {
    if (_isProduction) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-4129659429509766/1234567890'; // Replace with actual Android ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-4129659429509766/0987654321'; // Replace with actual iOS ID
      } else {
        throw UnsupportedError('Unsupported platform');
      }
    } else {
      // Using universal Google Test Interstitial ID
      return 'ca-app-pub-3940256099942544/1033776116';
    }
  }

  // ---- Create Banner Ad ----
  static BannerAd createBannerAd({
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(
        nonPersonalizedAds: true,
      ),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  // ---- Interstitial Ad Logic ----
  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    if (kIsWeb) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('AdMob Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          debugPrint('AdMob Interstitial failed to load: $error');
        },
      ),
    );
  }

  static Future<bool> showInterstitialAd() async {
    if (kIsWeb || _interstitialAd == null) return false;

    final completer = Completer<bool>();
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdMob Interstitial showed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdMob Interstitial failed to show: $error');
        _interstitialAd = null;
        completer.complete(false);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdMob Interstitial dismissed');
        _interstitialAd = null;
        loadInterstitialAd(); // Preload next
        completer.complete(true);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }
}
