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
