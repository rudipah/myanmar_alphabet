import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'flashcard_screen.dart'; // Import the flashcard screen
import 'quiz_screen.dart'; // Import the quiz screen
import 'matching_game_screen.dart'; // Import the matching game screen
import 'settings_screen.dart'; // Import settings screen
import '../data/data_loader.dart'; // Import data loader
import '../models/flashcard.dart'; // Flashcard model type
import '../services/sound_service.dart'; // Import sound service
import '../utils/app_colors.dart';
import '../utils/navigator_util.dart';
import '../widgets/menu_button.dart';
import 'progress_screen.dart'; // Import the progress screen

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Flashcards list from loader
  late List<Flashcard> flashcards;
  Flashcard? _dailyLetter;

  @override
  void initState() {
    super.initState();

    // Initialize animations first (before async data loading)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    // Load flashcards from JSON
    _loadData();
  }

  Future<void> _loadData() async {
    // Load flashcards from JSON
    flashcards = await DataLoader.loadFlashcards();

    // Use a simpler deterministic seed - use letter index based on date
    final now = DateTime.now();
    if (flashcards.isNotEmpty) {
      // Use month-day combination as index (never zero)
      final index = ((now.month + now.day) % flashcards.length);
      setState(() {
        _dailyLetter = flashcards[index];
      });
    }

    // Start animations after data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToHome(BuildContext context) {
    NavigatorUtil.push(context, const HomeScreen());
  }

  void _navigateToFlashcards(BuildContext context) {
    NavigatorUtil.push(context, const FlashcardScreen());
  }

  void _navigateToQuiz(BuildContext context) {
    NavigatorUtil.push(context, const QuizScreen());
  }

  void _navigateToMatchingGame(BuildContext context) {
    NavigatorUtil.push(context, const MatchingGameScreen());
  }

  void _navigateToSettings(BuildContext context) {
    NavigatorUtil.push(context, const SettingsScreen());
  }

  void _navigateToProgress(BuildContext context) {
    NavigatorUtil.push(context, const ProgressScreen());
  }

  // void _navigateToProgress(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => const ProgressScreen(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              Color(0xFFA29BFE),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ---- App icon ----
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.4),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'က',
                          style: TextStyle(
                            fontFamily: 'Pyidaungsu',
                            fontSize: 64,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Letter of the Day Section ----
                    GestureDetector(
                      onTap: () {
                        SoundService.playLetter(_dailyLetter?.audio ?? 'a.ogg');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha:0.5), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "🌟 Letter of the Day: ",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              (_dailyLetter?.letter ?? '؟'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Pyidaungsu',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.volume_up, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Title ----

                    const Text(
                      'Learn Myanmar Alphabet',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap start to begin learning',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha:0.8),
                      ),
                    ),

                    const SizedBox(height: 52),

                    // ---- Buttons ----
                    Column(
                      children: [
                        // Primary Action: Start Learning
                        MenuButton(
                          label: 'Start Learning',
                          icon: const Text('✏️', style: TextStyle(fontSize: 22)),
                          onTap: () => _navigateToHome(context),
                          isPrimary: false,
                        ),
                        const SizedBox(height: 30),

                        // Game Modes Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 2.2,
                          children: [
                            MenuButton(
                              label: 'Flashcards',
                              icon: const Text('📚', style: TextStyle(fontSize: 22)),
                              onTap: () => _navigateToFlashcards(context),
                            ),
                            MenuButton(
                              label: 'Quiz Time',
                              icon: const Text('🎯', style: TextStyle(fontSize: 22)),
                              onTap: () => _navigateToQuiz(context),
                            ),
                            MenuButton(
                              label: 'Matching',
                              icon: const Text('🧩', style: TextStyle(fontSize: 22)),
                              onTap: () => _navigateToMatchingGame(context),
                            ),
                            MenuButton(
                              label: 'Progress',
                              icon: const Text('📊', style: TextStyle(fontSize: 22)),
                              onTap: () => _navigateToProgress(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Utilities Row
                        Row(
                          children: [
                            Expanded(
                              child: MenuButton(
                                label: 'Settings',
                                icon: const Text('⚙️', style: TextStyle(fontSize: 22)),
                                onTap: () => _navigateToSettings(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
