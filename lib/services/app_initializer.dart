import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'sound_service.dart';
import 'unity_ads_service.dart';
import 'ad_manager.dart';

class AppInitializer {
  static Future<void> init() async {
    if (!kIsWeb) {
      // Child-directed app: these must be set BEFORE any ad request.
      // - Child-directed treatment (COPPA): no personalised ads / tracking
      // - Under age of consent (GDPR): same treatment for EEA/UK users
      // - Max content rating G: only family-safe ads
      // (Note: these two tag fields are marked deprecated in newer
      //  google_mobile_ads releases in favour of ageRestrictedTreatment,
      //  but they still work and exist in the ^5.1.0 you use.)
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // ignore: deprecated_member_use
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
          // ignore: deprecated_member_use
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );

      // Single, authoritative AdMob initialisation (not duplicated in main.dart)
      await MobileAds.instance.initialize();

      // Unity Ads initialisation (testMode is controlled by kDebugMode inside)
      await UnityAdsService.initialize();

      // Pre-load first interstitial so it is ready when needed
      AdManager.instance.preloadAds();
    }

    await SoundService.init();
  }
}
