import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
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
    await AdHelper.loadInterstitialAd();
    UnityAdsService.loadInterstitialAd();
  }

  /// Returns a banner ad from AdMob (as per current strategy)
  BannerAd createBannerAd({
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required void Function(Ad) onAdLoaded,
  }) {
    return AdHelper.createBannerAd(
      onAdFailedToLoad: onAdFailedToLoad,
      onAdLoaded: onAdLoaded,
    );
  }

  /// Shows an interstitial ad, rotating between providers and respecting cooldown.
  Future<void> showInterstitialAd() async {
    if (kIsWeb) return;

    // 1. Check Cooldown
    final now = DateTime.now();
    if (_lastAdShownTime != null && now.difference(_lastAdShownTime!) < _adCooldown) {
      debugPrint('AdManager: Skipping ad due to cooldown.');
      return;
    }

    // 2. Attempt to show ad from current provider
    bool success = false;
    if (_currentProvider == AdProvider.admob) {
      success = await _tryAdMobInterstitial();
    } else {
      success = await _tryUnityInterstitial();
    }

    // 3. Fallback to other provider if first failed
    if (!success) {
      debugPrint('AdManager: Primary provider failed, trying fallback...');
      if (_currentProvider == AdProvider.admob) {
        success = await _tryUnityInterstitial();
      } else {
        success = await _tryAdMobInterstitial();
      }
    }

    // 4. If an ad was shown, update cooldown, rotate provider, AND reload for next time
    if (success) {
      _lastAdShownTime = DateTime.now();
      _rotateProvider();
      // Preload the next ad immediately
      preloadAds();
    }
  }

  void _rotateProvider() {
    _currentProvider = (_currentProvider == AdProvider.admob)
        ? AdProvider.unity
        : AdProvider.admob;
    debugPrint('AdManager: Provider rotated to ${_currentProvider.name}');
  }

  Future<bool> _tryAdMobInterstitial() async {
    try {
      // AdMob requires pre-loading
      await AdHelper.loadInterstitialAd();
      // We give it a tiny bit of time to load if it was just called
      await Future.delayed(const Duration(milliseconds: 500));
      return await AdHelper.showInterstitialAd();
    } catch (e) {
      debugPrint('AdManager: AdMob interstitial error: $e');
      return false;
    }
  }

  Future<bool> _tryUnityInterstitial() async {
    try {
      // Wait for the ad to load if it's not ready yet (max 3 seconds)
      bool isLoaded = await UnityAdsService.loadInterstitialAd().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );

      if (isLoaded) {
        UnityAdsService.showInterstitialAd();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('AdManager: Unity interstitial error: $e');
      return false;
    }
  }

  /// Shows a rewarded ad (Unity only, as per current laout)
  void showRewardedAd({required Function onRewarded}) {
    if (kIsWeb) return;
    UnityAdsService.showRewardedAd(onRewarded: onRewarded);
  }
}
