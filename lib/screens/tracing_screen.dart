import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/letter.dart';
import '../widgets/tracing_canvas.dart';
import '../services/sound_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

class _TracingScreenState extends State<TracingScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<TracingCanvasState> _canvasKey = GlobalKey();

  bool _hasDrawn = false;
  bool _isSpeaking = false;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  late AnimationController _celebrateController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  ButtonStyle _outlineButtonStyle(Color color) {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: color.withOpacity(0.6), width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      foregroundColor: color,
    );
  }

  void _showSuccessPopup(VoidCallback onContinue) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  color: Colors.deepPurple,
                  size: 60,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Great Job!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(height: 8),
                // Text(
                //   "You traced it correctly 🎉",
                //   style: TextStyle(
                //     color: Colors.grey[600],
                //   ),
                // ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(widget.letter.colorValue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close popup
                    onContinue(); // continue to next letter
                  },
                  child: const Text("Continue"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _celebrateController,
        curve: Curves.elasticOut,
      ),
    );

    _glowAnim = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _celebrateController,
        curve: Curves.easeOut,
      ),
    );

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-4129659429509766/3143061906',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
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

    HapticFeedback.mediumImpact();

    _celebrateController.forward(from: 0);

    _showSuccessPopup(() {
      _canvasKey.currentState?.clear();
      setState(() => _hasDrawn = false);

      widget.onNext();
    });
  }

  Future<void> _speakLetter() async {
    if (_isSpeaking) return;

    setState(() => _isSpeaking = true);

    try {
      await SoundService.playLetter(widget.letter.audioFile);
    } finally {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.letter.colorValue);

    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🏠 Home
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home_rounded, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 🔤 Letter Badge
                  Container(
                    padding:
                        const EdgeInsets.all(12), // 👈 same as sound button
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12), // 👈 same radius
                      border: Border.all(
                        color: color.withOpacity(0.4), // 👈 same style
                        width: 2,
                      ),
                    ),
                    child: Text(
                      widget.letter.character,
                      style: const TextStyle(
                        fontFamily: 'Pyidaungsu',
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 📘 Letter Info (beside badge)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.letter.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.letter.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D4E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Trace the letter',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔊 Sound Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isSpeaking ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: _isSpeaking ? 1.1 : 1.0,
                      child: IconButton(
                        onPressed: _speakLetter,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(
                              color: color.withOpacity(0.4), width: 2),
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(
                          _isSpeaking
                              ? Icons.volume_up
                              : Icons.volume_up_outlined,
                          color: color,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= DRAW AREA =================
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 1, // ✅ makes it square
                    child: AnimatedBuilder(
                      animation: _celebrateController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnim.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6C5CE7)
                                      .withOpacity(_glowAnim.value),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: child,
                          ),
                        );
                      },
                      child: TracingCanvas(
                        key: _canvasKey,
                        letter: widget.letter.character,
                        letterColor: Color(widget.letter.colorValue),
                        onDrawStart: _onDrawStart,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ================= BUTTONS =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onClear,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.grey.withOpacity(0.5), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.refresh, size: 18),
                          SizedBox(width: 6),
                          Text("Clear"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _hasDrawn ? _onDone : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasDrawn
                            ? Color(widget.letter.colorValue)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_hasDrawn ? "Done" : "Draw to continue"),
                          const SizedBox(width: 6),
                          Icon(
                            _hasDrawn ? Icons.arrow_forward : Icons.brush,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isBannerReady && _bannerAd != null)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
