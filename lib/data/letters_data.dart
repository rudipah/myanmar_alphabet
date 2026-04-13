import '../models/letter.dart';

const List<MyanmarLetter> myanmarLetters = [
  // Row 1 — Velar stops
  MyanmarLetter(character: 'က', name: 'Ka',  emoji: '🐱', colorValue: 0xFFFF6B6B, audioFile: 'ka.mp3',   myanmarWord: 'ကြာသပတေး', wordMeaning: 'Thursday'),
  MyanmarLetter(character: 'ခ', name: 'Kha', emoji: '🐶', colorValue: 0xFFFF9F43, audioFile: 'kha.mp3',  myanmarWord: 'ခြင်း',     wordMeaning: 'basket'),
  MyanmarLetter(character: 'ဂ', name: 'Ga',  emoji: '🐸', colorValue: 0xFF54A0FF, audioFile: 'ga.mp3',   myanmarWord: 'ဂျင်း',     wordMeaning: 'ginger'),
  MyanmarLetter(character: 'ဃ', name: 'Gha', emoji: '🦋', colorValue: 0xFF5F27CD, audioFile: 'gha.mp3',  myanmarWord: 'ဃနာ',       wordMeaning: 'illness'),
  MyanmarLetter(character: 'င', name: 'Nga', emoji: '🐠', colorValue: 0xFF00D2D3, audioFile: 'nga.mp3',  myanmarWord: 'င်္ဂါ',     wordMeaning: 'Tuesday'),

  // Row 2 — Palatal stops
  MyanmarLetter(character: 'စ', name: 'Sa',  emoji: '🌸', colorValue: 0xFFFF6B9D, audioFile: 'sa.mp3',   myanmarWord: 'စာ',         wordMeaning: 'book'),
  MyanmarLetter(character: 'ဆ', name: 'Hsa', emoji: '🐢', colorValue: 0xFF26DE81, audioFile: 'hsa.mp3',  myanmarWord: 'ဆိပ်',       wordMeaning: 'harbour'),
  MyanmarLetter(character: 'ဇ', name: 'Za',  emoji: '🦊', colorValue: 0xFFFD9644, audioFile: 'za.mp3',   myanmarWord: 'ဇာတ်',       wordMeaning: 'story'),
  MyanmarLetter(character: 'ဈ', name: 'Zha', emoji: '🦅', colorValue: 0xFFE17055, audioFile: 'zha.mp3',  myanmarWord: 'ဈေး',        wordMeaning: 'market'),
  MyanmarLetter(character: 'ည', name: 'Nya', emoji: '🌙', colorValue: 0xFF6C5CE7, audioFile: 'nya.mp3',  myanmarWord: 'ညနေ',        wordMeaning: 'evening'),

  // Row 3 — Alveolar stops
  MyanmarLetter(character: 'ဋ', name: 'Ta',  emoji: '🐯', colorValue: 0xFFFF7675, audioFile: 'ta1.mp3',  myanmarWord: 'ဋီကာ',       wordMeaning: 'commentary'),
  MyanmarLetter(character: 'ဌ', name: 'Hta', emoji: '🦁', colorValue: 0xFFFDAB10, audioFile: 'hta1.mp3', myanmarWord: 'ဌာန',        wordMeaning: 'department'),
  MyanmarLetter(character: 'ဍ', name: 'Da',  emoji: '🐻', colorValue: 0xFF00CEC9, audioFile: 'da1.mp3',  myanmarWord: 'ဍောတ်',      wordMeaning: 'small boat'),
  MyanmarLetter(character: 'ဎ', name: 'Dha', emoji: '🐼', colorValue: 0xFFA29BFE, audioFile: 'dha1.mp3', myanmarWord: 'ဎီကာ',       wordMeaning: 'annotated'),
  MyanmarLetter(character: 'ဏ', name: 'Na',  emoji: '🦒', colorValue: 0xFFFF4DA6, audioFile: 'na1.mp3',  myanmarWord: 'ဏာဏ်',       wordMeaning: 'wisdom'),

  // Row 4 — Dental stops
  MyanmarLetter(character: 'တ', name: 'Ta',  emoji: '🐘', colorValue: 0xFF55EFC4, audioFile: 'ta2.mp3',  myanmarWord: 'တောင်',      wordMeaning: 'mountain'),
  MyanmarLetter(character: 'ထ', name: 'Hta', emoji: '🦓', colorValue: 0xFFFF6348, audioFile: 'hta2.mp3', myanmarWord: 'ထမင်း',      wordMeaning: 'rice'),
  MyanmarLetter(character: 'ဒ', name: 'Da',  emoji: '🦏', colorValue: 0xFF7BED9F, audioFile: 'da2.mp3',  myanmarWord: 'ဒေါ်',       wordMeaning: 'aunty'),
  MyanmarLetter(character: 'ဓ', name: 'Dha', emoji: '🐊', colorValue: 0xFF70A1FF, audioFile: 'dha2.mp3', myanmarWord: 'ဓားမ',       wordMeaning: 'knife handle'),
  MyanmarLetter(character: 'န', name: 'Na',  emoji: '🌻', colorValue: 0xFFFD79A8, audioFile: 'na2.mp3',  myanmarWord: 'နှင်း',      wordMeaning: 'snow'),

  // Row 5 — Labial stops
  MyanmarLetter(character: 'ပ', name: 'Pa',  emoji: '🦜', colorValue: 0xFF6C5CE7, audioFile: 'pa.mp3',   myanmarWord: 'ပန်း',       wordMeaning: 'flower'),
  MyanmarLetter(character: 'ဖ', name: 'Pha', emoji: '🦚', colorValue: 0xFFE84393, audioFile: 'pha.mp3',  myanmarWord: 'ဖရဲ',        wordMeaning: 'watermelon'),
  MyanmarLetter(character: 'ဗ', name: 'Ba',  emoji: '🦩', colorValue: 0xFF0984E3, audioFile: 'ba.mp3',   myanmarWord: 'ဗိုလ်',      wordMeaning: 'captain'),
  MyanmarLetter(character: 'ဘ', name: 'Bha', emoji: '🦋', colorValue: 0xFF00B894, audioFile: 'bha.mp3',  myanmarWord: 'ဘုရား',      wordMeaning: 'temple'),
  MyanmarLetter(character: 'မ', name: 'Ma',  emoji: '🐵', colorValue: 0xFFA29BFE, audioFile: 'ma.mp3',   myanmarWord: 'မိုး',       wordMeaning: 'rain'),

  // Row 6 — Approximants
  MyanmarLetter(character: 'ယ', name: 'Ya',  emoji: '🌈', colorValue: 0xFF00B894, audioFile: 'ya.mp3',   myanmarWord: 'ယဉ်',        wordMeaning: 'vehicle'),
  MyanmarLetter(character: 'ရ', name: 'Ra',  emoji: '🦊', colorValue: 0xFFFF4757, audioFile: 'ra.mp3',   myanmarWord: 'ရေ',         wordMeaning: 'water'),
  MyanmarLetter(character: 'လ', name: 'La',  emoji: '🌺', colorValue: 0xFF2ED573, audioFile: 'la.mp3',   myanmarWord: 'လမ်း',       wordMeaning: 'road'),
  MyanmarLetter(character: 'ဝ', name: 'Wa',  emoji: '🐋', colorValue: 0xFF1E90FF, audioFile: 'wa.mp3',   myanmarWord: 'ဝမ်း',       wordMeaning: 'stomach'),

  // Row 7 — Fricatives & others
  MyanmarLetter(character: 'သ', name: 'Tha', emoji: '🌟', colorValue: 0xFFFFD32A, audioFile: 'tha.mp3',  myanmarWord: 'သစ်ပင်',    wordMeaning: 'tree'),
  MyanmarLetter(character: 'ဟ', name: 'Ha',  emoji: '🦁', colorValue: 0xFFFF6B81, audioFile: 'ha.mp3',   myanmarWord: 'ဟင်းသီး',   wordMeaning: 'vegetable'),
  MyanmarLetter(character: 'ဠ', name: 'Lla', emoji: '🌴', colorValue: 0xFF3AE374, audioFile: 'lla.mp3',  myanmarWord: 'ဠာဏီ',      wordMeaning: 'wisdom'),
  MyanmarLetter(character: 'အ', name: 'A',   emoji: '⭐', colorValue: 0xFFECCC68, audioFile: 'a.mp3',    myanmarWord: 'အိမ်',       wordMeaning: 'house'),
];
