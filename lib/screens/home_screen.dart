import 'package:flutter/material.dart';
import '../data/letters_data.dart';
import '../data/numbers_data.dart';
import '../models/letter.dart';
import 'tracing_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

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
                    '✏️ Myanmar Alphabet',
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF6C5CE7),
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: '🔤 Consonants'),
                    Tab(text: '🔢 Numbers'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ---- Tab Content ----
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _LetterGrid(items: myanmarLetters, crossAxisCount: 5),
                    _LetterGrid(items: myanmarNumbers, crossAxisCount: 4),
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
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TracingScreenWithNav(
                  items: items,
                  startIndex: index,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.character,
                  style: TextStyle(
                    fontFamily: 'Pyidaungsu',
                    fontSize: 28,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
