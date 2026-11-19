import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';
import '../services/app_initializer.dart';

/// A self-contained, adaptive anchored banner ad widget.
/// Drop it into any Scaffold's bottomNavigationBar:
///
///   bottomNavigationBar: const BannerAdWidget(),
///
/// It sizes itself to the screen width, stays clear of the system
/// navigation bar (SafeArea), and handles its own load and disposal.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isLoaded = false;
  bool _loadStarted = false;
  bool _failed = false;

  // Gap between the screen content and the banner (reduces accidental taps).
  static const double _topGap = 8;

  // Space kept free while the ad loads, so the screen doesn't jump when it
  // appears (children tapping a shifting layout = accidental ad taps).
  static const double _reservedHeight = 60;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is not available in initState, so load here (once).
    if (_loadStarted || kIsWeb) return;
    _loadStarted = true;
    _loadAdaptiveBanner();
  }

  Future<void> _loadAdaptiveBanner() async {
    await AppInitializer.adsReady; // ad SDKs initialise in the background
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (!mounted) return;
    if (size == null) {
      debugPrint('Banner ad: adaptive size unavailable for width $width');
      setState(() => _failed = true);
      return;
    }

    final ad = AdManager.instance.createBannerAd(
      size: size,
      onAdLoaded: (ad) {
        debugPrint('Banner ad loaded (${size.width}x${size.height})');
        if (mounted) setState(() => _isLoaded = true);
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        _bannerAd = null; // already disposed; avoid a double dispose
        debugPrint('Banner ad failed to load: $error');
        if (mounted) {
          setState(() {
            _isLoaded = false;
            _failed = true; // collapse the reserved space
          });
        }
      },
    );

    _bannerAd = ad;
    _adSize = size;
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    final size = _adSize;
    if (_failed || kIsWeb) return const SizedBox.shrink();
    if (!_isLoaded || ad == null || size == null) {
      // Still loading: keep the space free (see _reservedHeight).
      return const SafeArea(
        top: false,
        child: SizedBox(height: _topGap + _reservedHeight),
      );
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: _topGap),
        child: SizedBox(
          height: size.height.toDouble(),
          width: size.width.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
