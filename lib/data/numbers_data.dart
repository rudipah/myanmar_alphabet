import '../models/letter.dart';
import '../utils/app_colors.dart';

/// Hardcoded numbers data (used as fallback when JSON loading fails)
/// This class wraps the static list for easier access from other parts of the app
class NumbersData {
  static const List<MyanmarLetter> letters = [
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

  NumbersData(); // Add unnamed constructor

  factory NumbersData.fromJson(List<dynamic> json) {
    return NumbersData();
  }

  static NumbersData fromDataFile = NumbersData();
}
