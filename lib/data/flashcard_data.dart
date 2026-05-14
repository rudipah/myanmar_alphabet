class Flashcard {
  final String letter;
  final String pronunciation;
  final String image;
  final String audio;
  final String description;

  Flashcard({
    required this.letter,
    required this.pronunciation,
    required this.image,
    required this.audio,
    required this.description,
  });
}

final List<Flashcard> flashcards = [
  // ================= KA GROUP =================
  Flashcard(
      letter: 'က',
      pronunciation: 'က (ka)',
      image: 'assets/images/ka.png',
      audio: 'ka.wav',
      description: 'Ka'),
  Flashcard(
      letter: 'ခ',
      pronunciation: 'ခ (kha)',
      image: 'assets/images/kha.png',
      audio: 'kha.wav',
      description: 'Kha'),
  Flashcard(
      letter: 'ဂ',
      pronunciation: 'ဂ (ga)',
      image: 'assets/images/ga.png',
      audio: 'ga.wav',
      description: 'Ga'),
  Flashcard(
      letter: 'ဃ',
      pronunciation: 'ဃ (gha)',
      image: 'assets/images/gha.png',
      audio: 'gha.wav',
      description: 'Gha'),
  Flashcard(
      letter: 'င',
      pronunciation: 'င (nga)',
      image: 'assets/images/nga.png',
      audio: 'nga.wav',
      description: 'Nga'),

  // ================= SA GROUP =================
  Flashcard(
      letter: 'စ',
      pronunciation: 'စ (sa)',
      image: 'assets/images/sa.png',
      audio: 'sa.wav',
      description: 'Sa'),
  Flashcard(
      letter: 'ဆ',
      pronunciation: 'ဆ (hsa)',
      image: 'assets/images/hsa.png',
      audio: 'hsa.wav',
      description: 'Hsa'),
  Flashcard(
      letter: 'ဇ',
      pronunciation: 'ဇ (za)',
      image: 'assets/images/za.png',
      audio: 'za.wav',
      description: 'Za'),
  Flashcard(
      letter: 'ဈ',
      pronunciation: 'ဈ (zha)',
      image: 'assets/images/zha.png',
      audio: 'zha.wav',
      description: 'Zha'),
  Flashcard(
      letter: 'ည',
      pronunciation: 'ည (nya)',
      image: 'assets/images/nya.png',
      audio: 'nya.wav',
      description: 'Nya'),

  // ================= TA GROUP =================
  Flashcard(
      letter: 'ဋ',
      pronunciation: 'ဋ (ta)',
      image: 'assets/images/ta.png',
      audio: 'ta.wav',
      description: 'Ta'),
  Flashcard(
      letter: 'ဌ',
      pronunciation: 'ဌ (tha)',
      image: 'assets/images/tha.png',
      audio: 'tha.wav',
      description: 'Tha'),
  Flashcard(
      letter: 'ဍ',
      pronunciation: 'ဍ (da)',
      image: 'assets/images/da.png',
      audio: 'da.wav',
      description: 'Da'),
  Flashcard(
      letter: 'ဎ',
      pronunciation: 'ဎ (dha)',
      image: 'assets/images/dha.png',
      audio: 'dha.wav',
      description: 'Dha'),
  Flashcard(
      letter: 'ဏ',
      pronunciation: 'ဏ (na)',
      image: 'assets/images/na1.png',
      audio: 'na1.wav',
      description: 'Na'),

  // ================= TA (DENTAL) =================
  Flashcard(
      letter: 'တ',
      pronunciation: 'တ (ta)',
      image: 'assets/images/ta2.png',
      audio: 'ta2.wav',
      description: 'Ta'),
  Flashcard(
      letter: 'ထ',
      pronunciation: 'ထ (hta)',
      image: 'assets/images/hta.png',
      audio: 'hta.wav',
      description: 'Hta'),
  Flashcard(
      letter: 'ဒ',
      pronunciation: 'ဒ (da)',
      image: 'assets/images/da2.png',
      audio: 'da2.wav',
      description: 'Da'),
  Flashcard(
      letter: 'ဓ',
      pronunciation: 'ဓ (dha)',
      image: 'assets/images/dha2.png',
      audio: 'dha2.wav',
      description: 'Dha'),
  Flashcard(
      letter: 'န',
      pronunciation: 'န (na)',
      image: 'assets/images/na.png',
      audio: 'na.wav',
      description: 'Na'),

  // ================= PA GROUP =================
  Flashcard(
      letter: 'ပ',
      pronunciation: 'ပ (pa)',
      image: 'assets/images/pa.png',
      audio: 'pa.wav',
      description: 'Pa'),
  Flashcard(
      letter: 'ဖ',
      pronunciation: 'ဖ (pha)',
      image: 'assets/images/pha.png',
      audio: 'pha.wav',
      description: 'Pha'),
  Flashcard(
      letter: 'ဗ',
      pronunciation: 'ဗ (ba)',
      image: 'assets/images/ba.png',
      audio: 'ba.wav',
      description: 'Ba'),
  Flashcard(
      letter: 'ဘ',
      pronunciation: 'ဘ (bha)',
      image: 'assets/images/bha.png',
      audio: 'bha.wav',
      description: 'Bha'),
  Flashcard(
      letter: 'မ',
      pronunciation: 'မ (ma)',
      image: 'assets/images/ma.png',
      audio: 'ma.wav',
      description: 'Ma'),

  // ================= YA GROUP =================
  Flashcard(
      letter: 'ယ',
      pronunciation: 'ယ (ya)',
      image: 'assets/images/ya.png',
      audio: 'ya.wav',
      description: 'Ya'),
  Flashcard(
      letter: 'ရ',
      pronunciation: 'ရ (ya/ra)',
      image: 'assets/images/ra.png',
      audio: 'ra.wav',
      description: 'Ra'),
  Flashcard(
      letter: 'လ',
      pronunciation: 'လ (la)',
      image: 'assets/images/la.png',
      audio: 'la.wav',
      description: 'La'),
  Flashcard(
      letter: 'ဝ',
      pronunciation: 'ဝ (wa)',
      image: 'assets/images/wa.png',
      audio: 'wa.wav',
      description: 'Wa'),
  Flashcard(
      letter: 'သ',
      pronunciation: 'သ (tha)',
      image: 'assets/images/tha2.png',
      audio: 'tha2.wav',
      description: 'Tha'),

  // ================= HA GROUP =================
  Flashcard(
      letter: 'ဟ',
      pronunciation: 'ဟ (ha)',
      image: 'assets/images/ha.png',
      audio: 'ha.wav',
      description: 'Ha'),
  Flashcard(
      letter: 'ဠ',
      pronunciation: 'ဠ (la)',
      image: 'assets/images/lla.png',
      audio: 'lla.wav',
      description: 'La'),
  Flashcard(
      letter: 'အ',
      pronunciation: 'အ (a)',
      image: 'assets/images/a.png',
      audio: 'a.wav',
      description: 'A'),
];
