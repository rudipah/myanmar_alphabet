import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../utils/app_colors.dart';

import '../models/letter.dart';
import '../models/flashcard.dart';

/// Helper class to load data from JSON asset files
class DataLoader {
  static Future<void> init() async {
    // Ensure assets are loaded
    await _preloadAssets();
  }

  static Future<void> _preloadAssets() async {
    // Preload all JSON files (silently for performance)
    try {
      await rootBundle.loadString('assets/data/letters.json');
      await rootBundle.loadString('assets/data/flashcards.json');
      await rootBundle.loadString('assets/data/numbers.json');
    } catch (e) {
      debugPrint('Asset preload skipped: $e');
    }
  }

  /// Load flashcards data from JSON
  static Future<List<Flashcard>> loadFlashcards() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/flashcards.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final flashcardsJson = jsonData['flashcards'] as List;

      return flashcardsJson.map((item) {
        final json = item as Map<String, dynamic>;
        // Use full path for audio files (assets/audio/...)
        return Flashcard(
          letter: json['letter'],
          pronunciation: json['pronunciation'],
          image: json['image'],
          audio: 'assets/audio/${json['audio']}',
          descriptionAudio: 'assets/audio/${json['descriptionAudio']}',
          description: json['description'],
          word: json['word'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to load flashcards: $e');
      // Fallback to hardcoded data
      return _fallbackFlashcards();
    }
  }

  /// Load letters data from JSON
  static Future<List<MyanmarLetter>> loadLetters() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/letters.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final lettersJson = jsonData['letters'] as List;

      return lettersJson.map((item) {
        final json = item as Map<String, dynamic>;
        return MyanmarLetter(
          character: json['character'],
          name: json['name'],
          emoji: json['emoji'],
          colorValue: _parseColor(json['colorValue']),
          audioFile: json['audioFile'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to load letters: $e');
      // Fallback to hardcoded letters
      return myanmarLetters;
    }
  }

  /// Load numbers data from JSON
  static Future<List<MyanmarLetter>> loadNumbers() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/numbers.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final numbersJson = jsonData['numbers'] as List;

      return numbersJson.map((item) {
        final json = item as Map<String, dynamic>;
        return MyanmarLetter(
          character: json['character'],
          name: json['name'],
          emoji: json['emoji'],
          colorValue: _parseColor(json['colorValue']),
          audioFile: json['audioFile'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to load numbers: $e');
      // Fallback to hardcoded numbers
      return _myanmarNumbers;
    }
  }

  static int _parseColor(String hexColor) {
    String cleanHex = hexColor.replaceAll('#', '').replaceAll('0x', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex'; // Add alpha if missing
    }
    return int.parse(cleanHex, radix: 16);
  }

  /// Hardcoded letters data (fallback)
  static const List<MyanmarLetter> myanmarLetters = [
    // Row 1 - Velar stops
    MyanmarLetter(
        character: 'က',
        name: 'ka',
        emoji: '🐱',
        colorValue: 0xFFFF6B6B,
        audioFile: 'ka.ogg'),
    // myanmarWord: 'ကြာသပတေး',
    // wordMeaning: 'Thursday'
    MyanmarLetter(
        character: 'ခ',
        name: 'kha',
        emoji: '🐶',
        colorValue: 0xFFFF9F43,
        audioFile: 'kha.ogg'),
    // myanmarWord: 'ခြင်း',
    // wordMeaning: 'basket'
    MyanmarLetter(
        character: 'ဂ',
        name: 'ga',
        emoji: '🐸',
        colorValue: 0xFF54A0FF,
        audioFile: 'ga.ogg'),
    // myanmarWord: 'ဂျင်း',
    // wordMeaning: 'ginger'),
    MyanmarLetter(
        character: 'ဃ',
        name: 'ga',
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

    // Row 2 - Palatal stops
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

    // Row 3 - Alveolar stops
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

    // Row 4 - Dental stops
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

    // Row 5 - Labial stops
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

    // Row 6 - Approximants
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

    // Row 7 - Fricatives & others
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

  /// Hardcoded numbers data (fallback)
  static const List<MyanmarLetter> _myanmarNumbers = [
    // Row 8 - Numbers
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

  /// Fallback flashcards (hardcoded)
  static List<Flashcard> _fallbackFlashcards() {
    return [
      Flashcard(
          letter: 'က',
          pronunciation: 'က (ka)',
          image: 'assets/images/ka.png',
          audio: 'ka.ogg',
          descriptionAudio: 'ka_word.ogg',
          description: 'Baby',
          word: 'ကလေး'),
      Flashcard(
          letter: 'ခ',
          pronunciation: 'ခ (kha)',
          image: 'assets/images/kha.png',
          audio: 'kha.ogg',
          descriptionAudio: 'kha_word.ogg',
          description: 'Pencil',
          word: 'ခဲတံ'),
      Flashcard(
          letter: 'ဂ',
          pronunciation: 'ဂ (ga)',
          image: 'assets/images/gha.png',
          audio: 'ga.ogg',
          descriptionAudio: 'ga_word.ogg',
          description: 'Crab',
          word: 'ဂဏန်း'),
      Flashcard(
          letter: 'င',
          pronunciation: 'င (nga)',
          image: 'assets/images/nga.png',
          audio: 'nga.ogg',
          descriptionAudio: 'nga_word.ogg',
          description: 'Fish',
          word: 'ငါး'),
      Flashcard(
          letter: 'စ',
          pronunciation: 'စ (sa)',
          image: 'assets/images/sa.png',
          audio: 'sa.ogg',
          descriptionAudio: 'sa_word.ogg',
          description: 'Grain',
          word: 'စပါး'),
      Flashcard(
          letter: 'ဆ',
          pronunciation: 'ဆ (hsa)',
          image: 'assets/images/hsa.png',
          audio: 'hsa.ogg',
          descriptionAudio: 'hsa_word.ogg',
          description: 'Elephant',
          word: 'ဆင်'),
      Flashcard(
          letter: 'ဇ',
          pronunciation: 'ဇ (za)',
          image: 'assets/images/za.png',
          audio: 'za.ogg',
          descriptionAudio: 'za_word.ogg',
          description: 'Owl',
          word: 'ဇီးကွက်'),
      Flashcard(
          letter: 'ဈ',
          pronunciation: 'ဈ (zha)',
          image: 'assets/images/zha.png',
          audio: 'zha.ogg',
          descriptionAudio: 'zha_word.ogg',
          description: 'Retailer',
          word: 'စျေးသူ'),
      Flashcard(
          letter: 'ည',
          pronunciation: 'ည (nya)',
          image: 'assets/images/nya.png',
          audio: 'nya.ogg',
          descriptionAudio: 'nya_word.ogg',
          description: 'Night',
          word: 'ညအခါ'),
      Flashcard(
          letter: 'တ',
          pronunciation: 'တ (ta)',
          image: 'assets/images/ta.png',
          audio: 'ta2.ogg',
          descriptionAudio: 'ta_word.ogg',
          description: 'Hammer',
          word: 'တူ'),
      Flashcard(
          letter: 'ထ',
          pronunciation: 'ထ (hta)',
          image: 'assets/images/hta.png',
          audio: 'hta1.ogg',
          descriptionAudio: 'hta_word.ogg',
          description: 'Umbrella',
          word: 'ထီး'),
      Flashcard(
          letter: 'ဒ',
          pronunciation: 'ဒ (da)',
          image: 'assets/images/da2.png',
          audio: 'da2.ogg',
          descriptionAudio: 'da_word.ogg',
          description: 'Peacock',
          word: 'ဒေါင်း'),
      Flashcard(
          letter: 'ဓ',
          pronunciation: 'ဓ (dha)',
          image: 'assets/images/dha2.png',
          audio: 'dha2.ogg',
          descriptionAudio: 'dha_word.ogg',
          description: 'Knife',
          word: 'ဓား'),
      Flashcard(
          letter: 'န',
          pronunciation: 'န (na)',
          image: 'assets/images/na.png',
          audio: 'na1.ogg',
          descriptionAudio: 'na_word.ogg',
          description: 'Cow',
          word: 'နွား'),
      Flashcard(
          letter: 'ပ',
          pronunciation: 'ပ (pa)',
          image: 'assets/images/pa.png',
          audio: 'pa.ogg',
          descriptionAudio: 'pa_word.ogg',
          description: 'Apple',
          word: 'ပန်းသီး'),
      Flashcard(
          letter: 'ဖ',
          pronunciation: 'ဖ (pha)',
          image: 'assets/images/pha.png',
          audio: 'pha.ogg',
          descriptionAudio: 'pha_word.ogg',
          description: 'Watermelon',
          word: 'ဖရဲသီး'),
      Flashcard(
          letter: 'ဗ',
          pronunciation: 'ဗ (ba)',
          image: 'assets/images/ba.png',
          audio: 'ba.ogg',
          descriptionAudio: 'ba_word.ogg',
          description: 'Drum',
          word: 'ဗုံ'),
      Flashcard(
          letter: 'ဘ',
          pronunciation: 'ဘ (bha)',
          image: 'assets/images/bha.png',
          audio: 'bha.ogg',
          descriptionAudio: 'bha_word.ogg',
          description: 'Duck Egg',
          word: 'ဘဲဥ'),
      Flashcard(
          letter: 'မ',
          pronunciation: 'မ (ma)',
          image: 'assets/images/ma.png',
          audio: 'ma.ogg',
          descriptionAudio: 'ma_word.ogg',
          description: 'Horse',
          word: 'မြင်း'),
      Flashcard(
          letter: 'ယ',
          pronunciation: 'ယ (ya)',
          image: 'assets/images/ya.png',
          audio: 'ya.ogg',
          descriptionAudio: 'ya_word.ogg',
          description: 'Rabbit',
          word: 'ယုန်'),
      Flashcard(
          letter: 'ရ',
          pronunciation: 'ရ (ya)',
          image: 'assets/images/ra.png',
          audio: 'ya1.ogg',
          descriptionAudio: 'ya1_word.ogg',
          description: 'Bucket',
          word: 'ရေပုံး'),
      Flashcard(
          letter: 'လ',
          pronunciation: 'လ (la)',
          image: 'assets/images/la.png',
          audio: 'la.ogg',
          descriptionAudio: 'la_word.ogg',
          description: 'Butterfly',
          word: 'လိပ်ပြာ'),
      Flashcard(
          letter: 'ဝ',
          pronunciation: 'ဝ (wa)',
          image: 'assets/images/wa.png',
          audio: 'wa.ogg',
          descriptionAudio: 'wa_word.ogg',
          description: 'Bamboo',
          word: 'ဝါးပင်'),
      Flashcard(
          letter: 'သ',
          pronunciation: 'သ (tha)',
          image: 'assets/images/tha2.png',
          audio: 'tha.ogg',
          descriptionAudio: 'tha_word.ogg',
          description: 'Candy',
          word: 'သကြားလုံး'),
      Flashcard(
          letter: 'ဟ',
          pronunciation: 'ဟ (ha)',
          image: 'assets/images/ha.png',
          audio: 'ha.ogg',
          descriptionAudio: 'ha_word.ogg',
          description: 'Vegetable',
          word: 'ဟင်းသီးဟင်းရွက်'),
      Flashcard(
          letter: 'အ',
          pronunciation: 'အ (a)',
          image: 'assets/images/a.png',
          audio: 'a.ogg',
          descriptionAudio: 'a_word.ogg',
          description: 'House',
          word: 'အိမ်'),
    ];
  }
}
