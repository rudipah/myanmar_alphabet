import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import '../models/letter.dart';
import '../widgets/tracing_canvas.dart';

// Only import AdMob on mobile platforms
import 'package:google_mobile_ads/google_mobile_ads.dart'
    if (dart.library.html) '../utils/ads_stub.dart';

// Replace with your real Ad Unit ID before publishing
const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

class TracingScreen extends StatefulWidget {
  final MyanmarLetter letter;
  final VoidCallback onNext;

  const TracingScreen({
    super.key,
    required this.letter,
    required this.onNext,
  });

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  final GlobalKey<TracingCanvasState> _canvasKey = GlobalKey();
  bool _hasDrawn = false;
  late ConfettiController _confettiController;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    // Only load ads on mobile
    if (!kIsWeb) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onDrawStart() {
    setState(() => _hasDrawn = true);
  }

  void _onClear() {
    _canvasKey.currentState?.clear();
    setState(() => _hasDrawn = false);
  }

  void _onDone() {
    if (!_hasDrawn) return;
    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 1800), () {
      _canvasKey.currentState?.clear();
      setState(() => _hasDrawn = false);
      widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.letter.colorValue);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // ---- Header row ----
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home_rounded),
                        iconSize: 30,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2D2D4E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.letter.character,
                          style: const TextStyle(
                            fontFamily: 'Pyidaungsu',
                            fontSize: 52,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.letter.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          Text(
                            widget.letter.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D2D4E),
                            ),
                          ),
                          Text(
                            'Trace the letter below!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ---- Tracing Canvas ----
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: color, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: TracingCanvas(
                            key: _canvasKey,
                            letter: widget.letter.character,
                            letterColor: color,
                            onDrawStart: _onDrawStart,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ---- Buttons ----
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _onClear,
                          icon: const Text('🗑️'),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _hasDrawn ? _onDone : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: color.withOpacity(0.5),
                          ),
                          child: const Text(
                            '✅  Great job! Next →',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ---- Banner Ad (mobile only) ----
                  if (!kIsWeb && _isBannerAdReady && _bannerAd != null)
                    SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),

                ],
              ),
            ),

            // ---- Confetti ----
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                colors: [color, Colors.yellow, Colors.green, Colors.pink],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
