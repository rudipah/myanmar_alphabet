import 'package:flutter/material.dart';
import '../data/flashcard_data.dart';
import '../data/data_loader.dart';
import '../services/sound_service.dart';
import '../models/flashcard.dart';
import '../utils/app_colors.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool isFlipped = false;
  List<Flashcard> _flashcards = [];

  Flashcard get currentCard => _flashcards.isNotEmpty ? _flashcards[currentIndex] : Flashcard.empty();

  /// Load flashcards from JSON or use hardcoded fallback
  Future<void> _loadFlashcards() async {
    try {
      final data = await DataLoader.loadFlashcards();
      setState(() {
        _flashcards = data;
      });
      debugPrint('Loaded ${_flashcards.length} flashcards from JSON');
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

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void _repeatLetterAudio() async {
    await SoundService.playLetter(currentCard.audio);
  }

  void _repeatDescriptionAudio() async {
    await SoundService.playLetter(currentCard.descriptionAudio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header (Matching HomeScreen) ----
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildNavButton(Icons.arrow_back_ios_rounded, () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  const Text(
                    "Flashcards",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D2D4E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (detail) {
                      if (detail.primaryVelocity! < 0) {
                        _nextCard(); // Swipe Left -> Next
                      } else if (detail.primaryVelocity! > 0) {
                        _prevCard(); // Swipe Right -> Prev
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNavButton(Icons.arrow_back, _prevCard),
                    const SizedBox(width: 40),
                    _buildNavButton(Icons.arrow_forward, _nextCard),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: AppColors.primary),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFront(Flashcard card) {
    return Card(
      key: const ValueKey('front'),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 340,
        height: 320,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.indigo.withOpacity(0.05)],
          ),
        ),
        child: Text(
          card.letter,
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pyidaungsu',
            color: Color(0xFF2D2D4E),
          ),
        ),
      ),
    );
  }

  Widget _buildBack(Flashcard card) {
    return Card(
      key: const ValueKey('back'),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 340,
        height: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
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
                    color: Color(0xFF2D2D4E),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                  onPressed: _repeatLetterAudio,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Image.asset(
              card.image,
              height: 100,
              fit: BoxFit.contain,
            ),
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
                    color: Color(0xFF2D2D4E),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                  onPressed: _repeatDescriptionAudio,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              card.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
