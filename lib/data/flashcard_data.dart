class Flashcard {
  final String letter;
  final String pronunciation;
  final String image;
  final String audio;
  final String descriptionAudio;
  final String description;
  final String? word;

  Flashcard({
    required this.letter,
    required this.pronunciation,
    required this.image,
    required this.audio,
    required this.descriptionAudio,
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

  // ================= SA GROUP =================
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
      word: 'စျေးသည်'),
  Flashcard(
      letter: 'ည',
      pronunciation: 'ည (nya)',
      image: 'assets/images/nya.png',
      audio: 'nya.ogg',
      descriptionAudio: 'nya_word.ogg',
      description: 'Night',
      word: 'ညအခါ'),

  // ================= TA (DENTAL) =================
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

  // ================= PA GROUP =================
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

  // ================= YA GROUP =================
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
      description: 'bucket',
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

  // ================= HA GROUP =================
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
