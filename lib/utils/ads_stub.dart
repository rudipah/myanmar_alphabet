// Stub file for web platform
// Replaces google_mobile_ads classes with empty Flutter-compatible versions

import 'package:flutter/material.dart';

class BannerAd {
  final String adUnitId;
  final dynamic size;
  final dynamic request;
  final dynamic listener;
  BannerAd({
    required this.adUnitId,
    required this.size,
    required this.request,
    required this.listener,
  });
  AdSize get size2 => AdSize.banner;
  void load() {}
  void dispose() {}
}

class AdSize {
  static const AdSize banner = AdSize._();
  const AdSize._();
  double get width => 320;
  double get height => 50;
}

class AdRequest {
  const AdRequest();
}

class BannerAdListener {
  final Function(dynamic)? onAdLoaded;
  final Function(dynamic, dynamic)? onAdFailedToLoad;
  const BannerAdListener({this.onAdLoaded, this.onAdFailedToLoad});
}

// Must extend Widget so it compiles on web
class AdWidget extends StatelessWidget {
  final dynamic ad;
  const AdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Empty on web
  }
}
