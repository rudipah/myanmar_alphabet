import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../data/data_loader.dart';
import '../services/sound_service.dart';
import '../models/flashcard.dart';
import '../utils/app_colors.dart';
import '../services/preferences_service.dart';

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
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
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

        // Pick 6 random cards to create 12 total items (6 letters, 6 images)
        List<Flashcard> selectedFlashcards = [];
        List<Flashcard> shuffledCards = List.from(allFlashcards);
        shuffledCards.shuffle();
        selectedFlashcards = shuffledCards.take(6).toList();

        List<GameCard> gameDeck = [];
        for (var card in selectedFlashcards) {
          // Add the letter card
          gameDeck.add(GameCard(
              letter: card.letter,
              image: null,
              id: card.letter,
              audio: card.audio,
              type: CardType.letter));
          // Add the image card
          gameDeck.add(GameCard(
              letter: null,
              image: card.image,
              id: card.letter,
              audio: card.audio,
              type: CardType.image));
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
      // Match found!
      HapticFeedback.lightImpact();
      setState(() {
        matchesFound++;
        cards![firstSelectedIdx!].isMatched = true;
        cards![secondSelectedIdx!].isMatched = true;
      });
      // Save progress
      PreferencesService.incrementLetterProgress(firstCard.id ?? '');
      // Success sound
      SoundService.playLetter(
          firstCard.audio ?? ''); // Use the audio file for success sound

      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          firstSelectedIdx = null;
          secondSelectedIdx = null;
          isProcessing = false;
        });
      });
    } else {
      // No match
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
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  "Congratulations!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You matched all the letters!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Menu"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _setupGame();
                  },
                  child: const Text("Play Again"),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildNavButton(Icons.arrow_back_ios_rounded,
                          () => Navigator.pop(context)),
                      const SizedBox(width: 12),
                      const Text(
                        "Matching Game",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D2D4E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Matches: $matchesFound / 6",
                    style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 columns x 4 rows = 12 cards
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: cards!.length,
                      itemBuilder: (context, index) {
                        return _buildCard(index);
                      },
                    ),
                  ),
                  if (matchesFound == 6)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: _showWinDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("See Result",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
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
    bool isSelected = index == firstSelectedIdx || index == secondSelectedIdx;
    bool isMatched = card.isMatched;

    return GestureDetector(
      onTap: () {
        if (!isMatched) {
          _onCardTap(index);
        }
      },
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isMatched
                ? Colors.greenAccent
                : (isSelected ? Colors.white : const Color(0xFFBDBBFF)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ],
            border: Border.all(
              color: isMatched
                  ? Colors.green
                  : (isSelected ? AppColors.primary : Colors.transparent),
              width: isMatched ? 3 : 2,
            ),
          ),
          child: Center(
            child: isSelected || isMatched
                ? (card.type == CardType.letter
                    ? Text(card.letter!,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pyidaungsu',
                            color: Color(0xFF2D2D4E)))
                    : Image.asset(card.image!,
                        width: 90, height: 90, fit: BoxFit.contain))
                : const Icon(Icons.help_outline, size: 32, color: Colors.white),
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: AppColors.primary),
        onPressed: onPressed,
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
  final CardType type;
  bool isMatched;

  GameCard({this.letter, this.image, this.id, this.audio, required this.type, this.isMatched = false});
}
