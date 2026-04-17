import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // ---------------------------------------------------------------
  // Replace these with your REAL Ad Unit IDs from AdMob
  // These are TEST IDs — safe to use during development
  // ---------------------------------------------------------------
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Google test ID

  static const String _prodBannerAdUnitId =
      'ca-app-pub-4129659429509766/3143061906';

  static const bool _isProduction = true; // <-- change only this

  static String get bannerAdUnitId {
    return _isProduction
        ? _prodBannerAdUnitId
        : _testBannerAdUnitId;
  }

  // ---- Initialize AdMob (call once in main.dart) ----
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ---- Create a banner ad ----
  static BannerAd createBannerAd({
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner, // 320x50 standard banner
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
