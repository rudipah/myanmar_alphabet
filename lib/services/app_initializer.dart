import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'sound_service.dart';
import 'unity_ads_service.dart';
import 'ad_manager.dart';
import 'package:advertising_id/advertising_id.dart';

class AppInitializer {
  static Future<void> init() async {
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
      await UnityAdsService.initialize();
      AdManager.instance.preloadAds();

      // Temporarily print advertising ID for debugging
      try {
        String? adId = await AdvertisingId.id(true);
        debugPrint('--- AD DEBUGGING ---');
        debugPrint('Device Advertising ID: $adId');
        debugPrint('-------------------');
      } catch (e) {
        debugPrint('Could not fetch Advertising ID: $e');
      }
    }
    await SoundService.init();
  }
}
