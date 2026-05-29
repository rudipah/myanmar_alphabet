/// Flashcard class definition
class Flashcard {
  final String letter;
  final String pronunciation;
  final String image;
  final String audio;
  final String descriptionAudio;
  final String description;
  final String? word;

  Flashcard._empty(this.letter, this.pronunciation, this.image, this.audio, this.descriptionAudio, this.description, this.word);

  /// Static empty constructor for fallback
  static Flashcard empty([String letter = '?', String pronunciation = '?', String image = '', String audio = '', String descriptionAudio = '', String description = '?', String? word]) {
    return Flashcard._empty(letter, pronunciation, image, audio, descriptionAudio, description, word);
  }

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
