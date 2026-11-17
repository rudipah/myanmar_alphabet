import 'package:flutter/material.dart';
import '../data/data_loader.dart';
import '../services/sound_service.dart';
import '../models/flashcard.dart';
import '../utils/app_colors.dart';
import '../services/ad_manager.dart';
import '../widgets/nav_icon_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_progress_bar.dart';
import '../widgets/mesh_background.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool isFlipped = false;
  List<Flashcard> _flashcards = [];

  Flashcard get currentCard =>
      _flashcards.isNotEmpty ? _flashcards[currentIndex] : Flashcard.empty();

  Future<void> _loadFlashcards() async {
    try {
      final data = await DataLoader.loadFlashcards();
      if (mounted) {
        setState(() => _flashcards = data);
        debugPrint('Loaded ${_flashcards.length} flashcards from JSON');
      }
    } catch (e) {
      debugPrint('Failed to load flashcards (using fallback): $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  void _nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % _flashcards.length;
      isFlipped = false;
    });
  }

  void _prevCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + _flashcards.length) % _flashcards.length;
      isFlipped = false;
    });
  }

  void _flipCard() => setState(() => isFlipped = !isFlipped);

  @override
  Widget build(BuildContext context) {
    final total = _flashcards.length;
    final progress = total == 0 ? 0.0 : (currentIndex + 1) / total;

    return GlassScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header ----
              const SizedBox(height: 8),
              Row(
                children: [
                  NavIconButton(
                    icon: Icons.arrow_back_ios_rounded,
                    onPressed: () {
                      AdManager.instance.showInterstitialAd();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Flashcards',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onGlass,
                    ),
                  ),
                  const Spacer(),
                  // Card counter
                  if (total > 0)
                    GlassContainer(
                      borderRadius: 14,
                      blur: 10,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text(
                        '${currentIndex + 1} / $total',
                        style: TextStyle(
                            color: AppColors.white(0.75),
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // ---- Progress bar ----
              if (total > 0) GlassProgressBar(value: progress, height: 6),

              const SizedBox(height: 16),

              // ---- Card ----
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (detail) {
                      if ((detail.primaryVelocity ?? 0) < 0) {
                        _nextCard();
                      } else if ((detail.primaryVelocity ?? 0) > 0) {
                        _prevCard();
                      }
                    },
                    onTap: _flipCard,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0)
                                .animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: isFlipped
                          ? _buildBack(currentCard)
                          : _buildFront(currentCard),
                    ),
                  ),
                ),
              ),

              // ---- Swipe / tap hint ----
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, size: 14, color: AppColors.white(0.45)),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to flip  •  Swipe to navigate',
                      style: TextStyle(fontSize: 12, color: AppColors.white(0.45)),
                    ),
                  ],
                ),
              ),

              // ---- Navigation arrows ----
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NavIconButton(icon: Icons.arrow_back, onPressed: _prevCard),
                    const SizedBox(width: 40),
                    NavIconButton(
                        icon: Icons.arrow_forward, onPressed: _nextCard),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFront(Flashcard card) {
    return GlassContainer(
      key: const ValueKey('front'),
      width: 340,
      height: 320,
      borderRadius: 24,
      blur: 16,
      fillOpacity: 0.09,
      specularOpacity: 0.14,
      alignment: Alignment.center,
      child: Text(
        card.letter,
        style: TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.bold,
          fontFamily: 'Pyidaungsu',
          color: AppColors.onGlass,
          shadows: [
            Shadow(color: AppColors.white(0.25), blurRadius: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(Flashcard card) {
    return GlassContainer(
      key: const ValueKey('back'),
      width: 340,
      height: 320,
      borderRadius: 24,
      blur: 16,
      fillOpacity: 0.09,
      specularOpacity: 0.14,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.pronunciation,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onGlass,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.primaryLight),
                onPressed: () => SoundService.playLetter(card.audio),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Image.asset(card.image, height: 100, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.word ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Pyidaungsu',
                  color: AppColors.onGlass,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.primaryLight),
                onPressed: () => SoundService.playLetter(card.descriptionAudio),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white(0.65),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
