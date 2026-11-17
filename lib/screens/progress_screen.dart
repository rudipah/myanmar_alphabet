import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../data/data_loader.dart';
import '../utils/app_colors.dart';
import '../services/preferences_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/nav_icon_button.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<MyanmarLetter> _consonants = [];
  List<MyanmarLetter> _numbers = [];
  Map<String, int> _letterProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final letters = await DataLoader.loadLetters();
      final numbers = await DataLoader.loadNumbers();
      final progress = await PreferencesService.getLetterProgress();

      if (mounted) {
        setState(() {
          _consonants = letters;
          _numbers = numbers;
          _letterProgress = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _progressPercentage {
    final total = _consonants.length + _numbers.length;
    if (total == 0) return 0.0;
    final practiced = _letterProgress.entries.where((e) => e.value > 0).length;
    return practiced / total;
  }

  int get _practicedCount =>
      _letterProgress.entries.where((e) => e.value > 0).length;

  Widget _buildSection(String title, List<MyanmarLetter> letters) {
    if (letters.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D4E),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: letters.length,
          itemBuilder: (context, index) {
            final card = letters[index];
            final count = _letterProgress[card.character] ?? 0;
            final isPracticed = count > 0;

            Color tierColor;
            int starCount = 0;

            if (count == 0) {
              tierColor = Colors.white;
            } else if (count < 4) {
              tierColor = Colors.orangeAccent;
              starCount = 1;
            } else if (count < 8) {
              tierColor = Colors.grey;
              starCount = 2;
            } else {
              tierColor = AppColors.primary;
              starCount = 3;
            }

            return Container(
              decoration: BoxDecoration(
                color: isPracticed
                    ? tierColor.withValues(alpha: 0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPracticed ? tierColor : Colors.grey[300]!,
                  width: isPracticed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPracticed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            starCount,
                            (i) => Icon(Icons.star,
                                size: 10, color: tierColor),
                          ),
                        ),
                      ),
                    Text(
                      card.character,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pyidaungsu',
                        color: isPracticed ? tierColor : const Color(0xFF2D2D4E),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // ---- Header ----
                    Row(
                      children: [
                        NavIconButton(
                          icon: Icons.arrow_back_ios_rounded,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'My Progress',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D2D4E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ---- Progress Bar ----
                    const Text(
                      'Learning Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D4E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progressPercentage,
                        backgroundColor: Colors.white,
                        color: AppColors.primary,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progressPercentage * 100).toInt()}% Completed  '
                      '($_practicedCount/${_consonants.length + _numbers.length} letters)',
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 32),

                    // ---- Sections ----
                    _buildSection('Consonants', _consonants),
                    _buildSection('Numbers', _numbers),
                  ],
                ),
        ),
      ),
    );
  }
}
