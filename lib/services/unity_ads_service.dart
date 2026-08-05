import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsService {
  // Game IDs from Unity Dashboard
  static const String _androidGameId = '800111456';
  static const String _iosGameId = '800111406';

  static String get _currentGameId => Platform.isIOS ? _iosGameId : _androidGameId;

  // Placement IDs - Use official Unity Test IDs when in test mode
  static String get _currentInterstitialId {
    if (Platform.isIOS) return 'Interstitial_iOS';
    return 'Interstitial_Android';
  }

  static String get _currentRewardedId {
    if (Platform.isIOS) return 'Rewarded_iOS';
    return 'Rewarded_Android';
  }

  // Cooldown logic is now handled by AdManager

  /// Initializes Unity Ads. Guarded by kIsWeb to prevent crashes on web.
  static Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      await UnityAds.init(
        gameId: _currentGameId,
        testMode: true, // set to false before release
        onComplete: () => print('Unity Ads initialized successfully for ${Platform.isIOS ? "iOS" : "Android"}'),
        onFailed: (error, message) => print('Unity Ads initialization failed: $error $message'),
      );
    } catch (e) {
      print('Unity Ads initialization exception: $e');
    }
  }

  static Completer<bool>? _loadCompleter;

  static Future<bool> loadInterstitialAd() async {
    if (kIsWeb) return false;

    _loadCompleter = Completer<bool>();

    UnityAds.load(
      placementId: _currentInterstitialId,
      onComplete: (placementId) {
        debugPrint('Interstitial loaded: $placementId');
        if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
          _loadCompleter!.complete(true);
        }
      },
      onFailed: (placementId, error, message) {
        debugPrint('Interstitial failed to load: $error $message');
        if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
          _loadCompleter!.complete(false);
        }
      },
    );

    return _loadCompleter!.future;
  }

  static Future<bool> showInterstitialAd() async {
    if (kIsWeb) return false;
    UnityAds.showVideoAd(
      placementId: _currentInterstitialId,
      onComplete: (placementId) => print('Interstitial completed: $placementId'),
      onFailed: (placementId, error, message) =>
          print('Interstitial failed to show: $error $message'),
      onStart: (placementId) => print('Interstitial started: $placementId'),
      onClick: (placementId) => print('Interstitial clicked: $placementId'),
    );
    return true;
  }

  static void loadRewardedAd() {
    if (kIsWeb) return;
    UnityAds.load(
      placementId: _currentRewardedId,
      onComplete: (placementId) => print('Rewarded ad loaded: $placementId'),
      onFailed: (placementId, error, message) =>
          print('Rewarded ad failed to load: $error $message'),
    );
  }

  static void showRewardedAd({required Function onRewarded}) {
    if (kIsWeb) return;
    UnityAds.showVideoAd(
      placementId: _currentRewardedId,
      onComplete: (placementId) {
        print('Rewarded ad completed: $placementId');
        onRewarded();
      },
      onFailed: (placementId, error, message) =>
          print('Rewarded ad failed to show: $error $message'),
      onSkipped: (placementId) => print('Rewarded ad skipped: $placementId'),
    );
  }
}
