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
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_progress_bar.dart';
import '../widgets/mesh_background.dart';

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
    // Screen closed while the data was loading, or not enough cards to build
    // a 4-option question.
    if (!mounted || _flashcards.length < 4) return;

    final random = Random();
    final correct = _flashcards[random.nextInt(_flashcards.length)];

    // Exactly 3 DISTINCT wrong answers (before, the same wrong letter could
    // be picked twice, giving two identical option buttons).
    final seen = <String>{correct.letter};
    final wrong = <Flashcard>[];
    for (final card in List<Flashcard>.from(_flashcards)..shuffle(random)) {
      if (seen.add(card.letter)) {
        wrong.add(card);
        if (wrong.length == 3) break;
      }
    }
    if (wrong.length < 3) return;

    final newOptions = [correct, ...wrong]..shuffle(random);

    setState(() {
      isAnswered = false;
      clickedIndex = null;
      correctCard = correct;
      options = newOptions;
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
      return const GlassScaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GlassScaffold(
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
                      color: AppColors.onGlass,
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
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white(0.8),
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
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    inactiveThumbColor: AppColors.white(0.7),
                    inactiveTrackColor: AppColors.white(0.12),
                    trackOutlineColor:
                        WidgetStatePropertyAll(AppColors.white(0.25)),
                  ),
                ],
              ),

              // ---- Progress Bar ----
              GlassProgressBar(
                value: (currentQuestionIndex + 1) / 10,
                height: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${currentQuestionIndex + 1} of 10',
                style: TextStyle(
                    color: AppColors.white(0.55), fontWeight: FontWeight.w500),
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
                          fontSize: 20, color: AppColors.onGlass),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      width: 150,
                      height: 150,
                      borderRadius: 24,
                      blur: 16,
                      fillOpacity: 0.09,
                      specularOpacity: 0.13,
                      alignment: Alignment.center,
                      onTap: () => SoundService.playLetter(correctCard.audio),
                      child: currentMode == QuizMode.visual
                          ? Text(
                              correctCard.letter,
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Pyidaungsu',
                                color: AppColors.onGlass,
                                shadows: [
                                  Shadow(
                                      color: AppColors.white(0.25),
                                      blurRadius: 24),
                                ],
                              ),
                            )
                          : const Icon(Icons.volume_up,
                              size: 80, color: AppColors.onGlass),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up,
                            size: 16, color: AppColors.white(0.45)),
                        const SizedBox(width: 4),
                        Text('Tap to hear sound',
                            style: TextStyle(
                                color: AppColors.white(0.45), fontSize: 12)),
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
                  child: GlassButton(
                    label: 'Next Question',
                    height: 60,
                    fontSize: 18,
                    trailing: const Icon(Icons.arrow_forward,
                        size: 20, color: AppColors.onGlass),
                    onPressed: _nextQuestion,
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

    Color? tint; // null = neutral glass
    Color? borderColor;

    if (isAnswered) {
      if (isCorrect) {
        tint = AppColors.glassCorrect.withValues(alpha: 0.28);
        borderColor = AppColors.glassCorrect.withValues(alpha: 0.7);
      } else if (clickedIndex == index) {
        tint = AppColors.glassWrong.withValues(alpha: 0.26);
        borderColor = AppColors.glassWrong.withValues(alpha: 0.7);
      }
    }

    return GlassContainer(
      borderRadius: 18,
      blur: 12,
      fillOpacity: 0.09,
      tint: tint,
      borderColor: borderColor,
      alignment: Alignment.center,
      onTap: () => _checkAnswer(index),
      child: Text(
        option.letter,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Pyidaungsu',
          color: AppColors.onGlass,
        ),
      ),
    );
  }
}
