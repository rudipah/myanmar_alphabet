import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_helper.dart';
import '../services/unity_ads_service.dart';

enum AdProvider { admob, unity }

class AdManager {
  // Singleton pattern
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  // Rotation and Cooldown State
  AdProvider _currentProvider = AdProvider.admob;
  DateTime? _lastAdShownTime;
  static const Duration _adCooldown = Duration(minutes: 2);

  /// Pre-loads ads from all providers to ensure they are ready when needed.
  Future<void> preloadAds() async {
    if (kIsWeb) return;
    debugPrint('AdManager: Preloading ads from all providers...');
    // Both are no-ops if an ad is already loaded / loading.
    AdHelper.loadInterstitialAd();
    UnityAdsService.loadInterstitialAd();
  }

  /// Returns a banner ad from AdMob (as per current strategy)
  BannerAd createBannerAd({
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
    AdSize size = AdSize.banner,
  }) {
    return AdHelper.createBannerAd(
      onAdFailedToLoad: onAdFailedToLoad,
      onAdLoaded: onAdLoaded,
      size: size,
    );
  }

  /// Shows an interstitial ad, rotating between providers and respecting cooldown.
  /// Never blocks the child waiting for a load: if a provider has nothing
  /// ready it fails fast, the other provider is tried, and a load is started
  /// in the background for next time.
  Future<void> showInterstitialAd() async {
    if (kIsWeb) return;

    // 1. Check Cooldown
    final now = DateTime.now();
    if (_lastAdShownTime != null && now.difference(_lastAdShownTime!) < _adCooldown) {
      debugPrint('AdManager: Skipping ad due to cooldown.');
      return;
    }

    // 2. Attempt current provider, then fall back to the other one
    final first = _currentProvider;
    final second =
        first == AdProvider.admob ? AdProvider.unity : AdProvider.admob;

    bool success = await _tryProvider(first);
    if (!success) {
      debugPrint('AdManager: ${first.name} did not show, trying ${second.name}...');
      success = await _tryProvider(second);
    }

    // 3. Only a REAL show starts the cooldown and rotates the provider
    if (success) {
      _lastAdShownTime = DateTime.now();
      _rotateProvider();
    }

    // 4. Make sure the next ad is loading (no-ops if already loaded/loading)
    preloadAds();
  }

  void _rotateProvider() {
    _currentProvider = (_currentProvider == AdProvider.admob)
        ? AdProvider.unity
        : AdProvider.admob;
    debugPrint('AdManager: Provider rotated to ${_currentProvider.name}');
  }

  Future<bool> _tryProvider(AdProvider provider) async {
    try {
      if (provider == AdProvider.admob) {
        return await AdHelper.showInterstitialAd();
      }
      return await UnityAdsService.showInterstitialAd();
    } catch (e) {
      debugPrint('AdManager: ${provider.name} interstitial error: $e');
      return false;
    }
  }
}
