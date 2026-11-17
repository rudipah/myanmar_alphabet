import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../data/data_loader.dart';
import '../services/sound_service.dart';
import '../models/flashcard.dart';
import '../utils/app_colors.dart';
import '../services/preferences_service.dart';
import '../services/ad_manager.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/nav_icon_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/mesh_background.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  List<GameCard>? cards;
  int? firstSelectedIdx;
  int? secondSelectedIdx;
  bool isProcessing = false;
  int matchesFound = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _setupGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _setupGame() async {
    try {
      final allFlashcards = await DataLoader.loadFlashcards();
      setState(() {
        matchesFound = 0;
        firstSelectedIdx = null;
        secondSelectedIdx = null;
        isProcessing = false;

        final shuffledCards = List<Flashcard>.from(allFlashcards)..shuffle();
        final selectedFlashcards = shuffledCards.take(6).toList();

        final gameDeck = <GameCard>[];
        for (var card in selectedFlashcards) {
          gameDeck.add(GameCard(
            letter: card.letter,
            image: null,
            id: card.letter,
            audio: card.audio,
            wordAudio: card.descriptionAudio,
            type: CardType.letter,
          ));
          gameDeck.add(GameCard(
            letter: null,
            image: card.image,
            id: card.letter,
            audio: card.audio,
            wordAudio: card.descriptionAudio,
            type: CardType.image,
          ));
        }

        gameDeck.shuffle();
        cards = gameDeck;
      });
    } catch (e) {
      debugPrint('Error setting up game: $e');
    }
  }

  void _onCardTap(int index) {
    if (isProcessing || index == firstSelectedIdx) return;

    setState(() {
      if (firstSelectedIdx == null) {
        firstSelectedIdx = index;
      } else {
        secondSelectedIdx = index;
        isProcessing = true;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (cards == null) return;
    final firstCard = cards![firstSelectedIdx!];
    final secondCard = cards![secondSelectedIdx!];

    if (firstCard.id == secondCard.id) {
      HapticFeedback.lightImpact();
      setState(() {
        matchesFound++;
        cards![firstSelectedIdx!].isMatched = true;
        cards![secondSelectedIdx!].isMatched = true;
      });
      PreferencesService.incrementLetterProgress(firstCard.id ?? '');
      SoundService.playLetterAndWord(
          firstCard.audio ?? '', firstCard.wordAudio ?? '');

      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          firstSelectedIdx = null;
          secondSelectedIdx = null;
          isProcessing = false;
        });
      });
    } else {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          firstSelectedIdx = null;
          secondSelectedIdx = null;
          isProcessing = false;
        });
      });
    }
  }

  void _showWinDialog() {
    PreferencesService.recordStudyActivity(); // finished a matching round
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration,
                    color: Colors.deepPurple, size: 60),
                const SizedBox(height: 12),
                const Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You matched all the letters!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    AdManager.instance.showInterstitialAd();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Menu'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _setupGame();
                  },
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ---- Header ----
                  Row(
                    children: [
                      NavIconButton(
                        icon: Icons.arrow_back_ios_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Matching Game',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onGlass),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    borderRadius: 20,
                    blur: 12,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Matches: $matchesFound / 6',
                      style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.onGlass,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: cards?.length ?? 0,
                      itemBuilder: (context, index) => _buildCard(index),
                    ),
                  ),
                  if (matchesFound == 6)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: 240,
                        child: GlassButton(
                          label: 'See Result',
                          height: 56,
                          fontSize: 18,
                          onPressed: _showWinDialog,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    if (cards == null) return const SizedBox.shrink();
    final card = cards![index];
    final isSelected =
        index == firstSelectedIdx || index == secondSelectedIdx;
    final isMatched = card.isMatched;

    // Face-down: purple glass. Selected: bright glass. Matched: green glass.
    Color tint;
    Color border;
    if (isMatched) {
      tint = AppColors.glassCorrect.withValues(alpha: 0.28);
      border = AppColors.glassCorrect.withValues(alpha: 0.75);
    } else if (isSelected) {
      tint = AppColors.white(0.22);
      border = AppColors.white(0.6);
    } else {
      tint = AppColors.primary.withValues(alpha: 0.35);
      border = const Color(0x59B4A0FF);
    }

    return GestureDetector(
      onTap: () {
        if (!isMatched) _onCardTap(index);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GlassContainer(
          borderRadius: 16,
          blur: 0,
          tint: tint,
          borderColor: border,
          alignment: Alignment.center,
          child: isSelected || isMatched
              ? (card.type == CardType.letter
                  ? Text(card.letter!,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pyidaungsu',
                          color: AppColors.onGlass))
                  : Image.asset(card.image!,
                      width: 90, height: 90, fit: BoxFit.contain))
              : Icon(Icons.help_outline, size: 32, color: AppColors.white(0.85)),
        ),
      ),
    );
  }
}

enum CardType { letter, image }

class GameCard {
  final String? letter;
  final String? image;
  final String? id;
  final String? audio;
  final String? wordAudio;
  final CardType type;
  bool isMatched;

  GameCard({
    this.letter,
    this.image,
    this.id,
    this.audio,
    this.wordAudio,
    required this.type,
    this.isMatched = false,
  });
}
