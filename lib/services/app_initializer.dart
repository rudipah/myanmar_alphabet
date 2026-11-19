import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'sound_service.dart';
import 'unity_ads_service.dart';
import 'ad_manager.dart';

class AppInitializer {
  /// Completes when the ad SDKs are initialised (immediately on web).
  /// Banner widgets await this before requesting an ad.
  static Future<void> adsReady = Future<void>.value();

  /// Fast startup: only what the first screen needs is awaited. The ad SDKs
  /// initialise in the background so the app is not stuck on a blank screen
  /// while AdMob / Unity start up (can take a couple of seconds).
  static Future<void> init() async {
    if (!kIsWeb) {
      // Child-directed app: these must be set BEFORE any ad request, so they
      // ARE awaited (fast, local settings only).
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

      // Slow part: runs in the background.
      adsReady = _initAdSdks();
    }

    await SoundService.init();
  }

  static Future<void> _initAdSdks() async {
    try {
      // Single, authoritative AdMob initialisation
      await MobileAds.instance.initialize();

      // Unity Ads initialisation (testMode is controlled by kDebugMode inside)
      await UnityAdsService.initialize();

      // Pre-load first interstitial so it is ready when needed
      AdManager.instance.preloadAds();
    } catch (e) {
      debugPrint('Ad SDK init error: $e');
    }
  }
}
