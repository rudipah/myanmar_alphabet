import 'package:flutter/material.dart';

import '../data/letters_data.dart';
import '../data/data_loader.dart';
import '../models/letter.dart';
import 'tracing_screen.dart';
import '../utils/app_colors.dart';
import '../utils/navigator_util.dart';
import '../services/ad_manager.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/nav_icon_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/mesh_background.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  List<MyanmarLetter> _consonantLetters = [];
  List<MyanmarLetter> _numberLetters = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _currentIndex = _tabController.index);
    });
    _loadData();

    // Update streak when user enters the learning screen
    AdManager.instance.preloadAds();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final letters = await DataLoader.loadLetters();
      final numbers = await DataLoader.loadNumbers();
      if (mounted) {
        setState(() {
          _consonantLetters = letters;
          _numberLetters = numbers;
        });
        debugPrint(
            'Loaded ${letters.length} letters and ${numbers.length} numbers from JSON');
      }
    } catch (e) {
      debugPrint('Data loading failed (using hardcoded data): $e');
      if (!mounted) return;
      setState(() {
        _consonantLetters = myanmarLetters;
        _numberLetters = myanmarNumbers;
      });
    }
  }

  // Hardcoded fallback data (used if JSON load fails or on web)
  static final List<MyanmarLetter> myanmarLetters = [
    MyanmarLetter(character: 'က', name: 'ka', emoji: '🐱', colorValue: 0xFFFF6B6B, audioFile: 'ka.ogg'),
    MyanmarLetter(character: 'ခ', name: 'kha', emoji: '🐶', colorValue: 0xFFFF9F43, audioFile: 'kha.ogg'),
    MyanmarLetter(character: 'ဂ', name: 'ga', emoji: '🐸', colorValue: 0xFF54A0FF, audioFile: 'ga.ogg'),
    MyanmarLetter(character: 'ဃ', name: 'gha', emoji: '🦋', colorValue: 0xFF5F27CD, audioFile: 'gha.ogg'),
    MyanmarLetter(character: 'င', name: 'nga', emoji: '🐠', colorValue: 0xFF00D2D3, audioFile: 'nga.ogg'),
    MyanmarLetter(character: 'စ', name: 'sa', emoji: '🌸', colorValue: 0xFFFF6B9D, audioFile: 'sa.ogg'),
    MyanmarLetter(character: 'ဆ', name: 'hsa', emoji: '🐢', colorValue: 0xFF26DE81, audioFile: 'hsa.ogg'),
    MyanmarLetter(character: 'ဇ', name: 'za', emoji: '🦊', colorValue: 0xFFFD9644, audioFile: 'za.ogg'),
    MyanmarLetter(character: 'ဈ', name: 'za', emoji: '🦅', colorValue: 0xFFE17055, audioFile: 'zha.ogg'),
    MyanmarLetter(character: 'ည', name: 'nya', emoji: '🌙', colorValue: AppColors.primaryValue, audioFile: 'nya.ogg'),
    MyanmarLetter(character: 'ဋ', name: 'ta', emoji: '🐯', colorValue: 0xFFFF7675, audioFile: 'ta1.ogg'),
    MyanmarLetter(character: 'ဌ', name: 'hta', emoji: '🦁', colorValue: 0xFFFDAB10, audioFile: 'hta1.ogg'),
    MyanmarLetter(character: 'ဍ', name: 'da', emoji: '🐻', colorValue: 0xFF00CEC9, audioFile: 'da1.ogg'),
    MyanmarLetter(character: 'ဎ', name: 'da', emoji: '🐼', colorValue: 0xFFA29BFE, audioFile: 'dha1.ogg'),
    MyanmarLetter(character: 'ဏ', name: 'na', emoji: '🦒', colorValue: 0xFFFF4DA6, audioFile: 'na1.ogg'),
    MyanmarLetter(character: 'တ', name: 'ta', emoji: '🐘', colorValue: 0xFF55EFC4, audioFile: 'ta2.ogg'),
    MyanmarLetter(character: 'ထ', name: 'hta', emoji: '🦓', colorValue: 0xFFFF6348, audioFile: 'hta2.ogg'),
    MyanmarLetter(character: 'ဒ', name: 'da', emoji: '🦏', colorValue: 0xFF7BED9F, audioFile: 'da2.ogg'),
    MyanmarLetter(character: 'ဓ', name: 'da', emoji: '🐊', colorValue: 0xFF70A1FF, audioFile: 'dha2.ogg'),
    MyanmarLetter(character: 'န', name: 'na', emoji: '🌻', colorValue: 0xFFFD79A8, audioFile: 'na2.ogg'),
    MyanmarLetter(character: 'ပ', name: 'pa', emoji: '🦜', colorValue: AppColors.primaryValue, audioFile: 'pa.ogg'),
    MyanmarLetter(character: 'ဖ', name: 'pha', emoji: '🦚', colorValue: 0xFFE84393, audioFile: 'pha.ogg'),
    MyanmarLetter(character: 'ဗ', name: 'ba', emoji: '🦩', colorValue: 0xFF0984E3, audioFile: 'ba.ogg'),
    MyanmarLetter(character: 'ဘ', name: 'ba', emoji: '🦋', colorValue: 0xFF00B894, audioFile: 'bha.ogg'),
    MyanmarLetter(character: 'မ', name: 'ma', emoji: '🐵', colorValue: 0xFFA29BFE, audioFile: 'ma.ogg'),
    MyanmarLetter(character: 'ယ', name: 'ya', emoji: '🌈', colorValue: 0xFF00B894, audioFile: 'ya.ogg'),
    MyanmarLetter(character: 'ရ', name: 'ya', emoji: '🦊', colorValue: 0xFFFF4757, audioFile: 'ya1.ogg'),
    MyanmarLetter(character: 'လ', name: 'la', emoji: '🌺', colorValue: 0xFF2ED573, audioFile: 'la.ogg'),
    MyanmarLetter(character: 'ဝ', name: 'wa', emoji: '🐋', colorValue: 0xFF1E90FF, audioFile: 'wa.ogg'),
    MyanmarLetter(character: 'သ', name: 'tha', emoji: '🌟', colorValue: 0xFFFFD32A, audioFile: 'tha.ogg'),
    MyanmarLetter(character: 'ဟ', name: 'ha', emoji: '🦁', colorValue: 0xFFFF6B81, audioFile: 'ha.ogg'),
    MyanmarLetter(character: 'ဠ', name: 'la', emoji: '🌴', colorValue: 0xFF3AE374, audioFile: 'lla.ogg'),
    MyanmarLetter(character: 'အ', name: 'a', emoji: '⭐', colorValue: 0xFFECCC68, audioFile: 'a.ogg'),
  ];

  static const List<MyanmarLetter> myanmarNumbers = [
    MyanmarLetter(character: '၀', name: 'zero', emoji: '🥚', colorValue: AppColors.primaryValue, audioFile: 'zero0.ogg'),
    MyanmarLetter(character: '၁', name: 'one', emoji: '🌟', colorValue: 0xFFFF6B6B, audioFile: 'one.ogg'),
    MyanmarLetter(character: '၂', name: 'two', emoji: '🍎', colorValue: 0xFFFF9F43, audioFile: 'two.ogg'),
    MyanmarLetter(character: '၃', name: 'three', emoji: '🌸', colorValue: 0xFF26DE81, audioFile: 'three.ogg'),
    MyanmarLetter(character: '၄', name: 'four', emoji: '🦋', colorValue: 0xFF54A0FF, audioFile: 'four.ogg'),
    MyanmarLetter(character: '၅', name: 'five', emoji: '🐠', colorValue: 0xFFFF6B9D, audioFile: 'five.ogg'),
    MyanmarLetter(character: '၆', name: 'six', emoji: '🐢', colorValue: 0xFF00D2D3, audioFile: 'six.ogg'),
    MyanmarLetter(character: '၇', name: 'seven', emoji: '🌈', colorValue: 0xFFFD9644, audioFile: 'seven.ogg'),
    MyanmarLetter(character: '၈', name: 'eight', emoji: '🐵', colorValue: 0xFFA29BFE, audioFile: 'eight.ogg'),
    MyanmarLetter(character: '၉', name: 'nine', emoji: '🌻', colorValue: 0xFFE84393, audioFile: 'nine.ogg'),
    MyanmarLetter(character: '၁၀', name: 'ten', emoji: '🎉', colorValue: 0xFF00B894, audioFile: 'ten.ogg'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  NavIconButton(
                    icon: Icons.arrow_back_ios_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Learn Myanmar Alphabet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onGlass,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassContainer(
                borderRadius: 30,
                blur: 10,
                fillOpacity: 0.08,
                specularOpacity: 0,
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildToggleTab(
                      title: '🔤 Consonants',
                      selected: _currentIndex == 0,
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                          _tabController.animateTo(0);
                        });
                      },
                    ),
                    _buildToggleTab(
                      title: '🔢 Numbers',
                      selected: _currentIndex == 1,
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                          _tabController.animateTo(1);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _LetterGrid(items: _consonantLetters, crossAxisCount: 5),
                    _LetterGrid(items: _numberLetters, crossAxisCount: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTab({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.white(0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.white(0.24) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: selected ? AppColors.onGlass : AppColors.white(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterGrid extends StatelessWidget {
  final List<MyanmarLetter> items;
  final int crossAxisCount;

  const _LetterGrid({
    required this.items,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = Color(item.colorValue);
        // blur: 0 -> no BackdropFilter per cell (33+ cells); the mesh behind
        // is smooth so it looks the same and stays cheap on low-end phones.
        return GlassContainer(
          borderRadius: 16,
          blur: 0,
          tint: color.withValues(alpha: 0.18),
          borderColor: color.withValues(alpha: 0.5),
          alignment: Alignment.center,
          onTap: () {
            NavigatorUtil.push(
              context,
              TracingScreenWithNav(items: items, startIndex: index),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.character,
                style: TextStyle(
                  fontFamily: 'Pyidaungsu',
                  fontSize: 30,
                  color: AppColors.onGlass,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: color.withValues(alpha: 0.8), blurRadius: 14),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onGlassMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TracingScreenWithNav extends StatefulWidget {
  final List<MyanmarLetter> items;
  final int startIndex;

  const TracingScreenWithNav({
    super.key,
    required this.items,
    required this.startIndex,
  });

  @override
  State<TracingScreenWithNav> createState() => _TracingScreenWithNavState();
}

class _TracingScreenWithNavState extends State<TracingScreenWithNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
  }

  void _nextLetter() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TracingScreen(
      letter: widget.items[_currentIndex],
      onNext: _nextLetter,
    );
  }
}
