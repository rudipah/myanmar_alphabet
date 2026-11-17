import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';
import 'matching_game_screen.dart';
import 'settings_screen.dart';
import '../data/data_loader.dart';
import '../models/flashcard.dart';
import '../services/sound_service.dart';
import '../services/preferences_service.dart';
import '../utils/app_colors.dart';
import '../widgets/menu_button.dart';
import '../widgets/banner_ad_widget.dart';
import 'progress_screen.dart';

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

  List<Flashcard> flashcards = [];
  Flashcard? _dailyLetter;
  int _streak = 0;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();

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

    _loadData();
  }

  Future<void> _loadData() async {
    flashcards = await DataLoader.loadFlashcards();

    if (flashcards.isNotEmpty) {
      // Use day-of-year so every calendar day shows a unique letter
      final now = DateTime.now();
      // Compare as UTC dates so a daylight-saving change can't shift the day.
      final dayOfYear = DateTime.utc(now.year, now.month, now.day)
              .difference(DateTime.utc(now.year, 1, 1))
              .inDays +
          1;
      final index = dayOfYear % flashcards.length;
      _dailyLetter = flashcards[index];
    }

    final streak = await PreferencesService.getCurrentStreak();
    final soundEnabled = await PreferencesService.isSoundEnabled();

    if (mounted) {
      setState(() {
        _streak = streak;
        _soundEnabled = soundEnabled;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animController.forward();
      });
    }
  }

  /// Opens a screen, then refreshes the streak badge when the child returns
  /// (studying inside that screen may have extended it).
  Future<void> _open(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    final streak = await PreferencesService.getCurrentStreak();
    if (mounted) setState(() => _streak = streak);
  }

  Future<void> _toggleSound() async {
    final newValue = !_soundEnabled;
    await PreferencesService.setSoundEnabled(newValue);
    if (!newValue) await SoundService.stop(); // Cut off any audio already playing
    if (mounted) setState(() => _soundEnabled = newValue);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The gradient wraps the whole Scaffold (not just the body) so it also
    // shows behind the banner ad / bottom safe area instead of white.
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const BannerAdWidget(),
        body: SizedBox.expand(
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
                    // ---- Top Row: streak + mute ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '$_streak day${_streak == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        // Mute toggle
                        GestureDetector(
                          onTap: _toggleSound,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              _soundEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---- App icon ----
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
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

                    // ---- Letter of the Day ----
                    GestureDetector(
                      onTap: () {
                        if (_soundEnabled) {
                          SoundService.playLetter(
                              _dailyLetter?.audio ?? 'a.ogg');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🌟 Letter of the Day: ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
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
                            const Icon(Icons.volume_up,
                                color: Colors.white, size: 20),
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
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 52),

                    // ---- Buttons ----
                    Column(
                      children: [
                        MenuButton(
                          label: 'Start Learning',
                          icon: const Text('✏️',
                              style: TextStyle(fontSize: 22)),
                          onTap: () =>
                              _open(const HomeScreen()),
                          isPrimary: false,
                        ),
                        const SizedBox(height: 30),

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
                              icon: const Text('📚',
                                  style: TextStyle(fontSize: 22)),
                              onTap: () => _open(const FlashcardScreen()),
                            ),
                            MenuButton(
                              label: 'Quiz Time',
                              icon: const Text('🎯',
                                  style: TextStyle(fontSize: 22)),
                              onTap: () => _open(const QuizScreen()),
                            ),
                            MenuButton(
                              label: 'Matching',
                              icon: const Text('🧩',
                                  style: TextStyle(fontSize: 22)),
                              onTap: () => _open(const MatchingGameScreen()),
                            ),
                            MenuButton(
                              label: 'Progress',
                              icon: const Text('📊',
                                  style: TextStyle(fontSize: 22)),
                              onTap: () => _open(const ProgressScreen()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        Row(
                          children: [
                            Expanded(
                              child: MenuButton(
                                label: 'Settings',
                                icon: const Text('⚙️',
                                    style: TextStyle(fontSize: 22)),
                                onTap: () => _open(const SettingsScreen()),
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
      ),
    );
  }
}
