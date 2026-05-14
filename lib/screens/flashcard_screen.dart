import 'package:flutter/material.dart';
import '../data/flashcard_data.dart';
import '../services/sound_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool isFlipped = false;

  Flashcard get currentCard => flashcards[currentIndex];

  void _nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % flashcards.length;
      isFlipped = false;
    });
  }

  void _prevCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + flashcards.length) % flashcards.length;
      isFlipped = false;
    });
  }

  void _flipCard() async {
    setState(() {
      isFlipped = !isFlipped;
    });

    if (isFlipped) {
      await SoundService.playLetter(currentCard.audio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    final rotate =
                        Tween(begin: 3.14, end: 0.0).animate(animation);

                    return AnimatedBuilder(
                      animation: rotate,
                      child: child,
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.rotationY(rotate.value),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30),
                  onPressed: _prevCard,
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 30),
                  onPressed: _nextCard,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFront(Flashcard card) {
    return Card(
      key: const ValueKey(true),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 260,
        height: 320,
        alignment: Alignment.center,
        child: Text(
          card.letter,
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pyidaungsu',
          ),
        ),
      ),
    );
  }

  Widget _buildBack(Flashcard card) {
    return Card(
      key: const ValueKey(false),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 260,
        height: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.pronunciation,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              card.image,
              height: 120,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
