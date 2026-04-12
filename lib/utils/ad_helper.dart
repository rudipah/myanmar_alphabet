import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // ---------------------------------------------------------------
  // Replace these with your REAL Ad Unit IDs from AdMob
  // These are TEST IDs — safe to use during development
  // ---------------------------------------------------------------
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Google test ID

  // Use test ID during development, real ID in production
  static String get bannerAdUnitId {
    // TODO: Replace with your real Ad Unit ID before publishing
    // return 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
    return _testBannerAdUnitId;
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
