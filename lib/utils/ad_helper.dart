import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdHelper {
  // ---------------------------------------------------------------
  // Test Ad Unit ID (safe for development)
  // ---------------------------------------------------------------
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // ---------------------------------------------------------------
  // Toggle production vs test ads
  // ---------------------------------------------------------------
  static const bool _isProduction =
      false; // Set to true for production, false for testing

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
      return _testBannerAdUnitId;
    }
  }

  // ---- Initialize AdMob ----
  /*
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
  */

  // ---- Create Banner Ad ----
  /*
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
  */
}
