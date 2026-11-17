import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsService {
  // Game IDs from Unity Dashboard
  static const String _androidGameId = '800111456';
  static const String _iosGameId = '800111406';

  static String get _currentGameId => Platform.isIOS ? _iosGameId : _androidGameId;

  // Placement IDs
  static String get _currentInterstitialId {
    if (Platform.isIOS) return 'Interstitial_iOS';
    return 'Interstitial_Android';
  }

  /// Initializes Unity Ads.
  /// testMode automatically follows kDebugMode — no manual toggle needed.
  static Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      await UnityAds.init(
        gameId: _currentGameId,
        testMode: kDebugMode, // ✅ true in debug builds, false in release builds
        onComplete: () => debugPrint(
            'Unity Ads initialised for ${Platform.isIOS ? "iOS" : "Android"}'),
        onFailed: (error, message) =>
            debugPrint('Unity Ads init failed: $error $message'),
      );
    } catch (e) {
      debugPrint('Unity Ads init exception: $e');
    }
  }

  static Completer<bool>? _loadCompleter;
  static bool _isLoaded = false;

  /// True when an interstitial is loaded and ready to show.
  static bool get isInterstitialReady => _isLoaded;

  /// Loads an interstitial. Returns immediately with `true` if one is
  /// already loaded, and shares the in-flight request if one is running.
  static Future<bool> loadInterstitialAd() async {
    if (kIsWeb) return false;
    if (_isLoaded) return true;

    final inFlight = _loadCompleter;
    if (inFlight != null && !inFlight.isCompleted) return inFlight.future;

    final completer = Completer<bool>();
    _loadCompleter = completer;

    UnityAds.load(
      placementId: _currentInterstitialId,
      onComplete: (placementId) {
        debugPrint('Unity interstitial loaded: $placementId');
        _isLoaded = true;
        if (!completer.isCompleted) completer.complete(true);
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity interstitial failed to load: $error $message');
        _isLoaded = false;
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    return completer.future;
  }

  /// Shows the interstitial and reports the REAL outcome:
  /// `true` once the ad has started playing, `false` if it failed to show
  /// (or nothing was loaded / it timed out).
  static Future<bool> showInterstitialAd() async {
    if (kIsWeb || !_isLoaded) return false;

    // A loaded Unity ad can only be shown once.
    _isLoaded = false;

    final completer = Completer<bool>();

    UnityAds.showVideoAd(
      placementId: _currentInterstitialId,
      onStart: (placementId) {
        debugPrint('Unity interstitial started: $placementId');
        if (!completer.isCompleted) completer.complete(true);
      },
      onComplete: (placementId) {
        debugPrint('Unity interstitial completed: $placementId');
        // Safety net in case onStart was not delivered.
        if (!completer.isCompleted) completer.complete(true);
      },
      onFailed: (placementId, error, message) {
        debugPrint('Unity interstitial failed to show: $error $message');
        if (!completer.isCompleted) completer.complete(false);
      },
      onClick: (placementId) =>
          debugPrint('Unity interstitial clicked: $placementId'),
    );

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => false,
    );
  }
}
