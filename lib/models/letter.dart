class MyanmarLetter {
  final String character;    // The Myanmar letter e.g. "က"
  final String name;         // English name e.g. "Ka"
  final String emoji;        // Fun emoji for kids
  final int colorValue;      // Color as int e.g. 0xFFFF6B6B
  final String audioFile;    // Audio filename e.g. "ka.mp3"
  final String myanmarWord;  // Example Myanmar word
  final String wordMeaning;  // English meaning

  const MyanmarLetter({
    required this.character,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.audioFile,
    this.myanmarWord = '',
    this.wordMeaning = '',
  });

  /// Create from JSON (for loading from assets)
  factory MyanmarLetter.fromJson(Map<String, dynamic> json) {
    return MyanmarLetter(
      character: json['character'],
      name: json['name'],
      emoji: json['emoji'] ?? '',
      colorValue: int.parse(json['colorValue'].replaceAll('#', '0x')),
      audioFile: json['audioFile'],
    );
  }

  /// Convert to JSON (for saving)
  Map<String, dynamic> toJson() => {
        'character': character,
        'name': name,
        'emoji': emoji,
        'colorValue': '#${colorValue.toRadixString(16).padLeft(8, '0')}',
        'audioFile': audioFile,
      };
}
