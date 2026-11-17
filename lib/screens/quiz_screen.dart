import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../data/data_loader.dart';
import '../services/sound_service.dart';
import '../models/flashcard.dart';
import '../utils/app_colors.dart';
import '../services/preferences_service.dart';
import '../services/ad_manager.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/nav_icon_button.dart';

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
  int? clickedIndex;
  bool isAnswered = false;
  QuizMode currentMode = QuizMode.visual;
  List<Flashcard> _flashcards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards().then((_) => _generateQuestion());
  }

  Future<void> _loadFlashcards() async {
    try {
      _flashcards = await DataLoader.loadFlashcards();
      debugPrint('Loaded ${_flashcards.length} flashcards from JSON');
    } catch (e) {
      debugPrint('Failed to load flashcards (using fallback): $e');
    }
  }

  void _generateQuestion() {
    setState(() {
      isAnswered = false;
      clickedIndex = null;

      final random = Random();
      correctCard = _flashcards[random.nextInt(_flashcards.length)];

      List<Flashcard> wrongOptions = [];
      while (wrongOptions.length < 3) {
        final randomCard = _flashcards[random.nextInt(_flashcards.length)];
        if (randomCard.letter != correctCard.letter) {
          wrongOptions.add(randomCard);
        }
      }

      options = [correctCard, ...wrongOptions];
      options.shuffle();
      isLoading = false;
    });

    if (currentMode == QuizMode.audio) {
      SoundService.playLetter(correctCard.audio);
    }
  }

  void _checkAnswer(int index) {
    if (isAnswered) return;

    final isCorrect = options[index].letter == correctCard.letter;

    // Haptic feedback
    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      isAnswered = true;
      clickedIndex = index;
      if (isCorrect) {
        score++;
        PreferencesService.incrementLetterProgress(correctCard.letter);
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
    PreferencesService.recordStudyActivity(); // finished a full quiz round
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                const SizedBox(height: 12),
                const Text(
                  'Quiz Complete!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You scored $score out of 10!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      AdManager.instance.showInterstitialAd();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Menu'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        currentQuestionIndex = 0;
                        score = 0;
                        _generateQuestion();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
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
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0EEFF),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Alphabet Quiz',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D2D4E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ---- Mode Toggle ----
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    currentMode == QuizMode.visual ? 'Visual Mode' : 'Audio Mode',
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: currentMode == QuizMode.visual,
                    onChanged: (val) {
                      setState(() {
                        currentMode = val ? QuizMode.visual : QuizMode.audio;
                        _generateQuestion();
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),

              // ---- Progress Bar ----
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / 10,
                backgroundColor: Colors.white,
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${currentQuestionIndex + 1} of 10',
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // ---- Question Area ----
              Center(
                child: Column(
                  children: [
                    Text(
                      currentMode == QuizMode.visual
                          ? 'Which letter is this?'
                          : 'Which letter is this sound?',
                      style: const TextStyle(
                          fontSize: 20, color: Color(0xFF2D2D4E)),
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
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: currentMode == QuizMode.visual
                              ? Text(
                                  correctCard.letter,
                                  style: const TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Pyidaungsu'),
                                )
                              : const Icon(Icons.volume_up,
                                  size: 80, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_up,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Tap to hear sound',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- Options Grid ----
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) =>
                      _buildOptionButton(options[index], index),
                ),
              ),

              // ---- Next Button (only shown after answering) ----
              if (isAnswered)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Next Question',
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

  Widget _buildOptionButton(Flashcard option, int index) {
    final isCorrect = option.letter == correctCard.letter;

    Color bgColor = Colors.white;
    Color borderColor = AppColors.primary.withValues(alpha: 0.3);
    double borderWidth = 1;

    if (isAnswered) {
      if (isCorrect) {
        bgColor = Colors.greenAccent;
        borderColor = Colors.green;
        borderWidth = 2;
      } else if (clickedIndex == index) {
        bgColor = Colors.redAccent;
        borderColor = Colors.red;
        borderWidth = 2;
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Center(
          child: Text(
            option.letter,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pyidaungsu',
              color: Color(0xFF2D2D4E),
            ),
          ),
        ),
      ),
    );
  }
}
