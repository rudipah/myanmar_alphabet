import 'package:shared_preferences/shared_preferences.dart';

// ProgressService handles persistence of letter mastery and high scores.
class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static const String _masteryKey = 'letter_mastery';
  static const String _highScoreKey = 'quiz_high_score';

  // Mark a letter as mastered (e.g., after a successful tracing or quiz)
  Future<void> markLetterMastered(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> masteredLetters = prefs.getStringList(_masteryKey) ?? [];
    
    if (!masteredLetters.contains(letter)) {
      masteredLetters.add(letter);
      await prefs.setStringList(_masteryKey, masteredLetters);
    }
  }

  // Check if a specific letter is mastered
  Future<bool> isLetterMastered(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> masteredLetters = prefs.getStringList(_masteryKey) ?? [];
    return masteredLetters.contains(letter);
  }

  // Get all mastered letters
  Future<List<String>> getMasteredLetters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_masteryKey) ?? [];
  }

  // Save high score for quiz
  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int currentHigh = prefs.getInt(_highScoreKey) ?? 0;
    if (score > currentHigh) {
      await prefs.setInt(_highScoreKey, score);
    }
  }

  // Get high score
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  // Reset all progress
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
