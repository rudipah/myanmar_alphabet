class Flashcard {
  final String letter;
  final String pronunciation;
  final String image;
  final String audio;
  final String description;
  final String? word;

  Flashcard({
    required this.letter,
    required this.pronunciation,
    required this.image,
    required this.audio,
    required this.description,
    this.word,
  });
}

final List<Flashcard> flashcards = [
  // ================= KA GROUP =================
  Flashcard(
      letter: 'က',
      pronunciation: 'က (ka)',
      image: 'assets/images/ka.png',
      audio: 'ka.wav',
      description: 'Baby',
      word: 'ကလေး'),
  Flashcard(
      letter: 'ခ',
      pronunciation: 'ခ (kha)',
      image: 'assets/images/kha.png',
      audio: 'kha.wav',
      description: 'Pencil',
      word: 'ခဲတံ'),
  Flashcard(
      letter: 'ဂ',
      pronunciation: 'ဂ (ga)',
      image: 'assets/images/gha.png',
      audio: 'ga.wav',
      description: 'Crab',
      word: 'ဂဏန်း'),
  // Flashcard(
  //     letter: 'ဃ',
  //     pronunciation: 'ဃ (gha)',
  //     image: 'assets/images/gha.png',
  //     audio: 'gha.wav',
  //     description: 'Gha',
  //     word: 'ဃီဝါ'),
  Flashcard(
      letter: 'င',
      pronunciation: 'င (nga)',
      image: 'assets/images/nga.png',
      audio: 'nga.wav',
      description: 'Fish',
      word: 'ငါး'),

  // ================= SA GROUP =================
  Flashcard(
      letter: 'စ',
      pronunciation: 'စ (sa)',
      image: 'assets/images/sa.png',
      audio: 'sa.wav',
      description: 'Grain',
      word: 'စပါး'),
  Flashcard(
      letter: 'ဆ',
      pronunciation: 'ဆ (hsa)',
      image: 'assets/images/hsa.png',
      audio: 'hsa.wav',
      description: 'Elephant',
      word: 'ဆင်'),
  Flashcard(
      letter: 'ဇ',
      pronunciation: 'ဇ (za)',
      image: 'assets/images/za.png',
      audio: 'za.wav',
      description: 'Owl',
      word: 'ဇီးကွက်'),
  Flashcard(
      letter: 'ဈ',
      pronunciation: 'ဈ (zha)',
      image: 'assets/images/zha.png',
      audio: 'zha.wav',
      description: 'Retailer',
      word: 'စျေးသည်'),
  Flashcard(
      letter: 'ည',
      pronunciation: 'ည (nya)',
      image: 'assets/images/nya.png',
      audio: 'nya.wav',
      description: 'Night',
      word: 'ညအခါ'),

  // ================= TA GROUP =================
  // Flashcard(
  //     letter: 'ဋ',
  //     pronunciation: 'ဋ (ta)',
  //     image: 'assets/images/ta.png',
  //     audio: 'ta.wav',
  //     description: 'Ta',
  //     word: 'ဋ္ဌာန'),
  // Flashcard(
  //     letter: 'ဌ',
  //     pronunciation: 'ဌ (tha)',
  //     image: 'assets/images/tha.png',
  //     audio: 'tha.wav',
  //     description: 'Tha',
  //     word: 'ဌာန'),
  // Flashcard(
  //     letter: 'ဍ',
  //     pronunciation: 'ဍ (da)',
  //     image: 'assets/images/da.png',
  //     audio: 'da.wav',
  //     description: 'Da',
  //     word: 'ဍာ'),
  // Flashcard(
  //     letter: 'ဎ',
  //     pronunciation: 'ဎ (dha)',
  //     image: 'assets/images/dha.png',
  //     audio: 'dha.wav',
  //     description: 'Dha',
  //     word: 'ဎာ'),
  // Flashcard(
  //     letter: 'ဏ',
  //     pronunciation: 'ဏ (na)',
  //     image: 'assets/images/na1.png',
  //     audio: 'na1.wav',
  //     description: 'Na',
  //     word: 'ဏ'),

  // ================= TA (DENTAL) =================
  Flashcard(
      letter: 'တ',
      pronunciation: 'တ (ta)',
      image: 'assets/images/ta.png',
      audio: 'ta2.wav',
      description: 'Hammer',
      word: 'တူ'),
  Flashcard(
      letter: 'ထ',
      pronunciation: 'ထ (hta)',
      image: 'assets/images/hta.png',
      audio: 'hta1.wav',
      description: 'Umbrella',
      word: 'ထီး'),
  Flashcard(
      letter: 'ဒ',
      pronunciation: 'ဒ (da)',
      image: 'assets/images/da2.png',
      audio: 'da2.wav',
      description: 'Peacock',
      word: 'ဒေါင်း'),
  Flashcard(
      letter: 'ဓ',
      pronunciation: 'ဓ (dha)',
      image: 'assets/images/dha2.png',
      audio: 'dha2.wav',
      description: 'Knife',
      word: 'ဓား'),
  Flashcard(
      letter: 'န',
      pronunciation: 'န (na)',
      image: 'assets/images/na.png',
      audio: 'na1.wav',
      description: 'Cow',
      word: 'နွား'),

  // ================= PA GROUP =================
  Flashcard(
      letter: 'ပ',
      pronunciation: 'ပ (pa)',
      image: 'assets/images/pa.png',
      audio: 'pa.wav',
      description: 'Apple',
      word: 'ပန်းသီး'),
  Flashcard(
      letter: 'ဖ',
      pronunciation: 'ဖ (pha)',
      image: 'assets/images/pha.png',
      audio: 'pha.wav',
      description: 'Watermelon',
      word: 'ဖရဲသီး'),
  Flashcard(
      letter: 'ဗ',
      pronunciation: 'ဗ (ba)',
      image: 'assets/images/ba.png',
      audio: 'ba.wav',
      description: 'Drum',
      word: 'ဗုံ'),
  Flashcard(
      letter: 'ဘ',
      pronunciation: 'ဘ (bha)',
      image: 'assets/images/bha.png',
      audio: 'bha.wav',
      description: 'Duck Egg',
      word: 'ဘဲဥ'),
  Flashcard(
      letter: 'မ',
      pronunciation: 'မ (ma)',
      image: 'assets/images/ma.png',
      audio: 'ma.wav',
      description: 'Horse',
      word: 'မြင်း'),

  // ================= YA GROUP =================
  Flashcard(
      letter: 'ယ',
      pronunciation: 'ယ (ya)',
      image: 'assets/images/ya.png',
      audio: 'ya.wav',
      description: 'Rabbit',
      word: 'ယုန်'),
  Flashcard(
      letter: 'ရ',
      pronunciation: 'ရ (ya)',
      image: 'assets/images/ra.png',
      audio: 'ya.wav',
      description: 'bucket',
      word: 'ရေပုံး'),
  Flashcard(
      letter: 'လ',
      pronunciation: 'လ (la)',
      image: 'assets/images/la.png',
      audio: 'la.wav',
      description: 'Butterfly',
      word: 'လိပ်ပြာ'),
  Flashcard(
      letter: 'ဝ',
      pronunciation: 'ဝ (wa)',
      image: 'assets/images/wa.png',
      audio: 'wa.wav',
      description: 'Bamboo',
      word: 'ဝါးပင်'),
  Flashcard(
      letter: 'သ',
      pronunciation: 'သ (tha)',
      image: 'assets/images/tha2.png',
      audio: 'tha.wav',
      description: 'Candy',
      word: 'သကြားလုံး'),

  // ================= HA GROUP =================
  Flashcard(
      letter: 'ဟ',
      pronunciation: 'ဟ (ha)',
      image: 'assets/images/ha.png',
      audio: 'ha.wav',
      description: 'Vegetable',
      word: 'ဟင်းသီးဟင်းရွက်'),
  // Flashcard(
  //     letter: 'ဠ',
  //     pronunciation: 'ဠ (la)',
  //     image: 'assets/images/lla.png',
  //     audio: 'lla.wav',
  //     description: 'La',
  //     word: 'ဠ'),
  Flashcard(
      letter: 'အ',
      pronunciation: 'အ (a)',
      image: 'assets/images/a.png',
      audio: 'a.wav',
      description: 'House',
      word: 'အိမ်'),
];
