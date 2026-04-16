import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'sound_service.dart';

class AppInitializer {
  static Future<void> init() async {
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
      await SoundService.init();
    }
  }
}
