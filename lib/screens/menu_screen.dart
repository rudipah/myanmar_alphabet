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
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';
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

    final soundEnabled = await PreferencesService.isSoundEnabled();

    if (mounted) {
      setState(() {
        _soundEnabled = soundEnabled;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animController.forward();
      });
    }
  }

  Future<void> _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
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
                  const GlassContainer(
                    width: 110,
                    height: 110,
                    borderRadius: 30,
                    blur: 16,
                    specularOpacity: 0.22,
                    alignment: Alignment.center,
                    child: Text(
                      'က',
                      style: TextStyle(
                        fontFamily: 'Pyidaungsu',
                        fontSize: 64,
                        color: AppColors.onGlass,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---- Letter of the Day ----
                  GlassContainer(
                    borderRadius: 20,
                    blur: 14,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    onTap: () {
                      if (_soundEnabled) {
                        SoundService.playLetter(
                            _dailyLetter?.audio ?? 'a.ogg');
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🌟 Letter of the Day: ',
                          style: TextStyle(
                              color: AppColors.onGlass,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          (_dailyLetter?.letter ?? '؟'),
                          style: const TextStyle(
                            color: AppColors.onGlass,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pyidaungsu',
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.volume_up,
                            color: AppColors.onGlassMuted, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---- Title ----
                  const Text(
                    'Learn Myanmar Alphabet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onGlass,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap start to begin learning',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onGlassMuted,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ---- Buttons ----
                  Column(
                    children: [
                      MenuButton(
                        label: 'Start Learning',
                        icon: const Text('✏️', style: TextStyle(fontSize: 22)),
                        onTap: () => _open(const HomeScreen()),
                        isPrimary: true,
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
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
                      const SizedBox(height: 24),
                      MenuButton(
                        label: 'Settings',
                        icon: const Text('⚙️', style: TextStyle(fontSize: 22)),
                        onTap: () => _open(const SettingsScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
