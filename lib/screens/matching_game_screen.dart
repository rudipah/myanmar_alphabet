import 'package:flutter/material.dart';
import 'dart:math';
import '../data/flashcard_data.dart';
import '../services/sound_service.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late List<GameCard> cards;
  int? firstSelectedIdx;
  int? secondSelectedIdx;
  bool isProcessing = false;
  int matchesFound = 0;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    setState(() {
      matchesFound = 0;
      firstSelectedIdx = null;
      secondSelectedIdx = null;
      isProcessing = false;

      // Pick 6 random cards to create 12 total items (6 letters, 6 images)
      final random = Random();
      List<Flashcard> selectedFlashcards = [];
      List<Flashcard> allCards = List.from(flashcards);
      allCards.shuffle();
      selectedFlashcards = allCards.take(6).toList();

      List<GameCard> gameDeck = [];
      for (var card in selectedFlashcards) {
        // Add the letter card
        gameDeck.add(GameCard(
            letter: card.letter,
            image: null,
            id: card.letter,
            type: CardType.letter));
        // Add the image card
        gameDeck.add(GameCard(
            letter: null,
            image: card.image,
            id: card.letter,
            type: CardType.image));
      }

      gameDeck.shuffle();
      cards = gameDeck;
    });
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
    final firstCard = cards[firstSelectedIdx!];
    final secondCard = cards[secondSelectedIdx!];

    if (firstCard.id == secondCard.id) {
      // Match found!
      setState(() {
        matchesFound++;
      });
      // Success sound
      SoundService.playLetter(
          firstCard.id!); // Use the letter audio as success sound

      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          firstSelectedIdx = null;
          secondSelectedIdx = null;
          isProcessing = false;
        });
      });
    } else {
      // No match
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Congratulations!", textAlign: TextAlign.center),
        content: const Text("You matched all the letters!",
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Menu"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _setupGame();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      body: SafeArea(
        child: Padding(
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
                    color: Color(0xFF6C5CE7),
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
                  itemCount: cards.length,
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
                      backgroundColor: const Color(0xFF6C5CE7),
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
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = cards[index];
    bool isSelected = index == firstSelectedIdx || index == secondSelectedIdx;
    bool isMatched =
        false; // We can add a 'matched' property to GameCard for better persistence

    // For simplicity in this version, we just check if the game is over or
    // if we need to track matched indices in a list.
    // Let's add a 'matched' property to GameCard in the definition below.

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFBDBBFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: isSelected
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
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: const Color(0xFF6C5CE7)),
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
  final CardType type;

  GameCard({this.letter, this.image, this.id, required this.type});
}
