import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../data/letters_data.dart';
import '../data/data_loader.dart';
import '../models/letter.dart';
import 'tracing_screen.dart';
import '../utils/app_colors.dart';
import '../utils/navigator_util.dart';

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

  // Data from JSON or hardcoded fallback
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

      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    _loadData();
  }

  /// Load data from JSON or use hardcoded fallback
  Future<void> _loadData() async {
    try {
      final letters = await DataLoader.loadLetters();
      final numbers = await DataLoader.loadNumbers();

      if (mounted) {
        setState(() {
          _consonantLetters = letters;
          _numberLetters = numbers;
        });
        debugPrint('Loaded ${letters.length} letters and ${numbers.length} numbers from JSON');
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

  // Keep hardcoded data for kIsWeb fallback
  static final List<MyanmarLetter> myanmarLetters = [
    // Row 1 — Velar stops
    MyanmarLetter(
        character: 'က',
        name: 'ka',
        emoji: '🐱',
        colorValue: 0xFFFF6B6B,
        audioFile: 'ka.ogg'),
    // myanmarWord: 'ကြာသပတေး',
    // wordMeaning: 'Thursday'),
    MyanmarLetter(
        character: 'ခ',
        name: 'kha',
        emoji: '🐶',
        colorValue: 0xFFFF9F43,
        audioFile: 'kha.ogg'),
    // myanmarWord: 'ခြင်း',
    // wordMeaning: 'basket'),
    MyanmarLetter(
        character: 'ဂ',
        name: 'ga',
        emoji: '🐸',
        colorValue: 0xFF54A0FF,
        audioFile: 'ga.ogg'),
    // myanmarWord: 'ဇင်း',
    // wordMeaning: 'ginger'),
    MyanmarLetter(
        character: 'ဃ',
        name: 'gha',
        emoji: '🦋',
        colorValue: 0xFF5F27CD,
        audioFile: 'gha.ogg'),
    // myanmarWord: 'ဃနာ',
    // wordMeaning: 'illness'),
    MyanmarLetter(
        character: 'င',
        name: 'nga',
        emoji: '🐠',
        colorValue: 0xFF00D2D3,
        audioFile: 'nga.ogg'),
    // myanmarWord: 'င်္ဂါ',
    // wordMeaning: 'Tuesday'),

    // Row 2 — Palatal stops
    MyanmarLetter(
        character: 'စ',
        name: 'sa',
        emoji: '🌸',
        colorValue: 0xFFFF6B9D,
        audioFile: 'sa.ogg'),
    // myanmarWord: 'စာ',
    // wordMeaning: 'book'),
    MyanmarLetter(
        character: 'ဆ',
        name: 'hsa',
        emoji: '🐢',
        colorValue: 0xFF26DE81,
        audioFile: 'hsa.ogg'),
    // myanmarWord: 'ဆိပ်',
    // wordMeaning: 'harbour'),
    MyanmarLetter(
        character: 'ဇ',
        name: 'za',
        emoji: '🦊',
        colorValue: 0xFFFD9644,
        audioFile: 'za.ogg'),
    // myanmarWord: 'ဇာတ်',
    // wordMeaning: 'story'),
    MyanmarLetter(
        character: 'ဈ',
        name: 'za',
        emoji: '🦅',
        colorValue: 0xFFE17055,
        audioFile: 'zha.ogg'),
    // myanmarWord: 'ဈေး',
    // wordMeaning: 'market'),
    MyanmarLetter(
        character: 'ည',
        name: 'nya',
        emoji: '🌙',
        colorValue: AppColors.primaryValue,
        audioFile: 'nya.ogg'),
    // myanmarWord: 'ညနေ',
    // wordMeaning: 'evening'),

    // Row 3 — Alveolar stops
    MyanmarLetter(
        character: 'ဋ',
        name: 'ta',
        emoji: '🐯',
        colorValue: 0xFFFF7675,
        audioFile: 'ta1.ogg'),
    // myanmarWord: 'ဋီကာ',
    // wordMeaning: 'commentary'),
    MyanmarLetter(
        character: 'ဌ',
        name: 'hta',
        emoji: '🦁',
        colorValue: 0xFFFDAB10,
        audioFile: 'hta1.ogg'),
    // myanmarWord: 'ဌာန',
    // wordMeaning: 'department'),
    MyanmarLetter(
        character: 'ဍ',
        name: 'da',
        emoji: '🐻',
        colorValue: 0xFF00CEC9,
        audioFile: 'da1.ogg'),
    // myanmarWord: 'ဍောတ်',
    // wordMeaning: 'small boat'),
    MyanmarLetter(
        character: 'ဎ',
        name: 'da',
        emoji: '🐼',
        colorValue: 0xFFA29BFE,
        audioFile: 'dha1.ogg'),
    // myanmarWord: 'ဎီကာ',
    // wordMeaning: 'annotated'),
    MyanmarLetter(
        character: 'ဏ',
        name: 'na',
        emoji: '🦒',
        colorValue: 0xFFFF4DA6,
        audioFile: 'na1.ogg'),
    // myanmarWord: 'ဏာဏ်',
    // wordMeaning: 'wisdom'),

    // Row 4 — Dental stops
    MyanmarLetter(
        character: 'တ',
        name: 'ta',
        emoji: '🐘',
        colorValue: 0xFF55EFC4,
        audioFile: 'ta2.ogg'),
    // myanmarWord: 'တောင်',
    // wordMeaning: 'mountain'),
    MyanmarLetter(
        character: 'ထ',
        name: 'hta',
        emoji: '🦓',
        colorValue: 0xFFFF6348,
        audioFile: 'hta2.ogg'),
    // myanmarWord: 'ထမင်း',
    // wordMeaning: 'rice'),
    MyanmarLetter(
        character: 'ဒ',
        name: 'da',
        emoji: '🦏',
        colorValue: 0xFF7BED9F,
        audioFile: 'da2.ogg'),
    // myanmarWord: 'ဒေါ်',
    // wordMeaning: 'aunty'),
    MyanmarLetter(
        character: 'ဓ',
        name: 'da',
        emoji: '🐊',
        colorValue: 0xFF70A1FF,
        audioFile: 'dha2.ogg'),
    // myanmarWord: 'ဓားမ',
    // wordMeaning: 'knife handle'),
    MyanmarLetter(
        character: 'န',
        name: 'na',
        emoji: '🌻',
        colorValue: 0xFFFD79A8,
        audioFile: 'na2.ogg'),
    // myanmarWord: 'နှင်း',
    // wordMeaning: 'snow'),

    // Row 5 — Labial stops
    MyanmarLetter(
        character: 'ပ',
        name: 'pa',
        emoji: '🦜',
        colorValue: AppColors.primaryValue,
        audioFile: 'pa.ogg'),
    // myanmarWord: 'ပန်း',
    // wordMeaning: 'flower'),
    MyanmarLetter(
        character: 'ဖ',
        name: 'pha',
        emoji: '🦚',
        colorValue: 0xFFE84393,
        audioFile: 'pha.ogg'),
    // myanmarWord: 'ဖရဲ',
    // wordMeaning: 'watermelon'),
    MyanmarLetter(
        character: 'ဗ',
        name: 'ba',
        emoji: '🦩',
        colorValue: 0xFF0984E3,
        audioFile: 'ba.ogg'),
    // myanmarWord: 'ဗိုလ်',
    // wordMeaning: 'captain'),
    MyanmarLetter(
        character: 'ဘ',
        name: 'ba',
        emoji: '🦋',
        colorValue: 0xFF00B894,
        audioFile: 'bha.ogg'),
    // myanmarWord: 'ဘုရား',
    // wordMeaning: 'temple'),
    MyanmarLetter(
        character: 'မ',
        name: 'ma',
        emoji: '🐵',
        colorValue: 0xFFA29BFE,
        audioFile: 'ma.ogg'),
    // myanmarWord: 'မိုး',
    // wordMeaning: 'rain'),

    // Row 6 — Approximants
    MyanmarLetter(
        character: 'ယ',
        name: 'ya',
        emoji: '🌈',
        colorValue: 0xFF00B894,
        audioFile: 'ya.ogg'),
    // myanmarWord: 'ယဉ်',
    // wordMeaning: 'vehicle'),
    MyanmarLetter(
        character: 'ရ',
        name: 'ya',
        emoji: '🦊',
        colorValue: 0xFFFF4757,
        audioFile: 'ya1.ogg'),
    // myanmarWord: 'ရေ',
    // wordMeaning: 'water'),
    MyanmarLetter(
        character: 'လ',
        name: 'la',
        emoji: '🌺',
        colorValue: 0xFF2ED573,
        audioFile: 'la.ogg'),
    // myanmarWord: 'လမ်း',
    // wordMeaning: 'road'),
    MyanmarLetter(
        character: 'ဝ',
        name: 'wa',
        emoji: '🐋',
        colorValue: 0xFF1E90FF,
        audioFile: 'wa.ogg'),
    // myanmarWord: 'ဝမ်း',
    // wordMeaning: 'stomach'),

    // Row 7 — Fricatives & others
    MyanmarLetter(
        character: 'သ',
        name: 'tha',
        emoji: '🌟',
        colorValue: 0xFFFFD32A,
        audioFile: 'tha.ogg'),
    // myanmarWord: 'သစ်ပင်',
    // wordMeaning: 'tree'),
    MyanmarLetter(
        character: 'ဟ',
        name: 'ha',
        emoji: '🦁',
        colorValue: 0xFFFF6B81,
        audioFile: 'ha.ogg'),
    // myanmarWord: 'ဟင်းသီး',
    // wordMeaning: 'vegetable'),
    MyanmarLetter(
        character: 'ဠ',
        name: 'la',
        emoji: '🌴',
        colorValue: 0xFF3AE374,
        audioFile: 'lla.ogg'),
    // myanmarWord: 'ဠာဏီ',
    // wordMeaning: 'wisdom'),
    MyanmarLetter(
        character: 'အ',
        name: 'a',
        emoji: '⭐',
        colorValue: 0xFFECCC68,
        audioFile: 'a.ogg'),
    // myanmarWord: 'အိမ်',
    // wordMeaning: 'house'),
  ];

  static const List<MyanmarLetter> myanmarNumbers = [
    // Row 8 — Numbers
    MyanmarLetter(
        character: '၀',
        name: 'zero',
        emoji: '🥚',
        colorValue: AppColors.primaryValue,
        audioFile: 'zero0.ogg'),
    // myanmarWord: 'သုည',
    // wordMeaning: 'zero'),
    MyanmarLetter(
        character: '၁',
        name: 'one',
        emoji: '🌟',
        colorValue: 0xFFFF6B6B,
        audioFile: 'one.ogg'),
    // myanmarWord: 'တစ်',
    // wordMeaning: 'one'),
    MyanmarLetter(
        character: '၂',
        name: 'two',
        emoji: '🍎',
        colorValue: 0xFFFF9F43,
        audioFile: 'two.ogg'),
    // myanmarWord: 'နှစ်',
    // wordMeaning: 'two'),
    MyanmarLetter(
        character: '၃',
        name: 'three',
        emoji: '🌸',
        colorValue: 0xFF26DE81,
        audioFile: 'three.ogg'),
    // myanmarWord: 'သုံး',
    // wordMeaning: 'three'),
    MyanmarLetter(
        character: '၄',
        name: 'four',
        emoji: '🦋',
        colorValue: 0xFF54A0FF,
        audioFile: 'four.ogg'),
    // myanmarWord: 'လေး',
    // wordMeaning: 'four'),
    MyanmarLetter(
        character: '၅',
        name: 'five',
        emoji: '🐠',
        colorValue: 0xFFFF6B9D,
        audioFile: 'five.ogg'),
    // myanmarWord: 'ငါး',
    // wordMeaning: 'five'),
    MyanmarLetter(
        character: '၆',
        name: 'six',
        emoji: '🐢',
        colorValue: 0xFF00D2D3,
        audioFile: 'six.ogg'),
    // myanmarWord: 'ခြောက်',
    // wordMeaning: 'six'),
    MyanmarLetter(
        character: '၇',
        name: 'seven',
        emoji: '🌈',
        colorValue: 0xFFFD9644,
        audioFile: 'seven.ogg'),
    // myanmarWord: 'ခုနစ်',
    // wordMeaning: 'seven'),
    MyanmarLetter(
        character: '၈',
        name: 'eight',
        emoji: '🐵',
        colorValue: 0xFFA29BFE,
        audioFile: 'eight.ogg'),
    // myanmarWord: 'ရှစ်',
    // wordMeaning: 'eight'),
    MyanmarLetter(
        character: '၉',
        name: 'nine',
        emoji: '🌻',
        colorValue: 0xFFE84393,
        audioFile: 'nine.ogg'),
    // myanmarWord: 'ကိုး',
    // wordMeaning: 'nine'),
    MyanmarLetter(
        character: '၁၀',
        name: 'ten',
        emoji: '🎉',
        colorValue: 0xFF00B894,
        audioFile: 'ten.ogg'),
    // myanmarWord: 'ဆယ်',
    // wordMeaning: 'ten'),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              // ---- Header ----
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2D2D4E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Learn Myanmar Alphabet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D2D4E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ---- Tab Bar ----
              // ---- Toggle Tabs (Duolingo Style) ----
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildToggleTab(
                      title: "🔤 Consonants",
                      selected: _currentIndex == 0,
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                          _tabController.animateTo(0);
                        });
                      },
                    ),
                    _buildToggleTab(
                      title: "🔢 Numbers",
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

              // ---- Tab Content ----
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
}

Widget _buildToggleTab({
  required String title,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: selected ? const Color(0xFF2D2D4E) : Colors.grey,
            ),
          ),
        ),
      ),
    ),
  );
}

// ---- Reusable grid ----
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
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              NavigatorUtil.push(
                context,
                TracingScreenWithNav(
                  items: items,
                  startIndex: index,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.character,
                    style: TextStyle(
                      fontFamily: 'Pyidaungsu',
                      fontSize: 30,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---- Tracing screen wrapper ----
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
