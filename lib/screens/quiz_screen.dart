import 'package:flutter/material.dart';
import 'dart:math';
import '../data/flashcard_data.dart';
import '../services/sound_service.dart';

enum QuizMode { visual, audio }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  late Flashcard correctCard;
  late List<Flashcard> options;
  int? clickedIndex; // null: not answered, stores the index of the chosen option
  bool isAnswered = false;
  QuizMode currentMode = QuizMode.visual;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      isAnswered = false;
      clickedIndex = null;
      
      // Pick a random card as the correct answer
      final random = Random();
      correctCard = flashcards[random.nextInt(flashcards.length)];
      
      // Create a list of options (correct + 3 random distractors)
      List<Flashcard> wrongOptions = [];
      while (wrongOptions.length < 3) {
        final randomCard = flashcards[random.nextInt(flashcards.length)];
        if (randomCard.letter != correctCard.letter) {
          wrongOptions.add(randomCard);
        }
      }
      
      options = [correctCard, ...wrongOptions];
      options.shuffle();
    });

    // Automatically play sound if in Audio mode
    if (currentMode == QuizMode.audio) {
      SoundService.playLetter(correctCard.audio);
    }
  }

  void _checkAnswer(int index) {
    if (isAnswered) return;

    setState(() {
      isAnswered = true;
      clickedIndex = index;
      if (options[index].letter == correctCard.letter) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    currentQuestionIndex++;
    if (currentQuestionIndex < 10) {
      _generateQuestion();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Quiz Complete!", textAlign: TextAlign.center),
        content: Text(
          "You scored $score out of 10!",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back to Menu"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentQuestionIndex = 0;
                score = 0;
                _generateQuestion();
              });
            },
            child: const Text("Try Again"),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildNavButton(Icons.arrow_back_ios_rounded, () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  const Text(
                    "Alphabet Quiz",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D2D4E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    currentMode == QuizMode.visual ? "Visual Mode" : "Audio Mode",
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: currentMode == QuizMode.visual,
                    onChanged: (val) {
                      setState(() {
                        currentMode = val ? QuizMode.visual : QuizMode.audio;
                        _generateQuestion(); // Reset question when switching modes for a fresh start
                      });
                    },
                    activeColor: const Color(0xFF6C5CE7),
                  ),
                ],
              ),
              
              // Progress Bar
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / 10,
                backgroundColor: Colors.white,
                color: const Color(0xFF6C5CE7),
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Text(
                "Question ${currentQuestionIndex + 1} of 10",
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              
              // The Question Area
              Center(
                child: Column(
                  children: [
                    Text(
                      currentMode == QuizMode.visual ? "Which letter is this?" : "Which letter is this sound?",
                      style: const TextStyle(fontSize: 20, color: Color(0xFF2D2D4E)),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => SoundService.playLetter(correctCard.audio),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: currentMode == QuizMode.visual 
                            ? Text(
                                correctCard.letter,
                                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, fontFamily: 'Pyidaungsu'),
                              )
                            : const Icon(Icons.volume_up, size: 80, color: Color(0xFF6C5CE7)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_up, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text("Tap to hear sound", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Options Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildOptionButton(options[index], index);
                  },
                ),
              ),
              
              // Next Button
              if (isAnswered)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Next Question", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(Flashcard option, int index) {
    bool isCorrect = option.letter == correctCard.letter;
    Color color = Colors.white;
    
    if (isAnswered) {
      if (isCorrect) {
        color = Colors.greenAccent;
      } else if (clickedIndex == index) {
        color = Colors.redAccent;
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
          border: Border.all(
            color: isAnswered && isCorrect ? Colors.green : const Color(0xFF6C5CE7).withOpacity(0.3),
            width: isAnswered && isCorrect ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            option.letter,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Pyidaungsu', color: Color(0xFF2D2D4E)),
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
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: const Color(0xFF6C5CE7)),
        onPressed: onPressed,
      ),
    );
  }
}
