/// Word Model - Represents a vocabulary word with all its details
/// Compatible with both Hive and Firestore serialization
class Word {
  String word;
  String meaning;
  String synonyms;
  String antonyms;
  String sentence;
  String source;
  DateTime dateAdded;

  Word({
    required this.word,
    required this.meaning,
    this.synonyms = '',
    this.antonyms = '',
    this.sentence = '',
    this.source = '',
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  /// Create Word from Map (for Hive/Firestore deserialization)
  factory Word.fromMap(Map<String, dynamic> map) => Word(
    word: map['word'] ?? '',
    meaning: map['meaning'] ?? '',
    synonyms: map['synonyms'] ?? '',
    antonyms: map['antonyms'] ?? '',
    sentence: map['sentence'] ?? '',
    source: map['source'] ?? '',
    dateAdded: map['dateAdded'] != null
        ? DateTime.parse(map['dateAdded'])
        : DateTime.now(),
  );

  /// Convert Word to Map (for Hive/Firestore serialization)
  Map<String, dynamic> toMap() => {
    'word': word,
    'meaning': meaning,
    'synonyms': synonyms,
    'antonyms': antonyms,
    'sentence': sentence,
    'source': source,
    'dateAdded': dateAdded.toIso8601String(),
  };

  /// Copy with method for immutability
  Word copyWith({
    String? word,
    String? meaning,
    String? synonyms,
    String? antonyms,
    String? sentence,
    String? source,
    DateTime? dateAdded,
  }) {
    return Word(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      sentence: sentence ?? this.sentence,
      source: source ?? this.source,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
