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

  /// Calculate XP earned for this word based on complexity and completeness
  /// Balanced for future features like quizzes, reviews, achievements
  int get xp {
    int totalXP = 0;

    // Base XP for adding any word (reduced from 10 to 3)
    totalXP += 3;

    // XP based on word complexity (reduced significantly)
    if (word.length <= 4) {
      totalXP += 1; // Simple words: +1 XP (was +5)
    } else if (word.length <= 7) {
      totalXP += 2; // Medium words: +2 XP (was +10)
    } else {
      totalXP += 3; // Complex words: +3 XP (was +20)
    }

    // Small bonus XP for completeness (greatly reduced)
    if (meaning.isNotEmpty) totalXP += 2; // +2 XP for meaning (was +15)
    if (synonyms.isNotEmpty) totalXP += 1; // +1 XP for synonyms (was +10)
    if (antonyms.isNotEmpty) totalXP += 1; // +1 XP for antonyms (was +10)
    if (sentence.isNotEmpty) totalXP += 2; // +2 XP for sentence (was +15)

    return totalXP;
  }

  /// Calculate level based on word complexity and completeness
  int get level {
    int score = 0;

    // Base score from word complexity (length)
    if (word.length <= 4) {
      score += 1; // Simple words
    } else if (word.length <= 7) {
      score += 2; // Medium words
    } else {
      score += 3; // Complex words
    }

    // Bonus points for completeness (shows user engagement)
    if (meaning.isNotEmpty) score += 1;
    if (synonyms.isNotEmpty) score += 1;
    if (antonyms.isNotEmpty) score += 1;
    if (sentence.isNotEmpty) score += 1;

    // Convert score to level (1-3)
    if (score <= 3) return 1; // Lv 1 (Orange): Basic/incomplete
    if (score <= 5) return 2; // Lv 2 (Blue): Intermediate
    return 3; // Lv 3 (Green): Advanced/complete
  }

  /// Check if this word is considered "new" (added within 24 hours)
  bool get isNew {
    final hoursDiff = DateTime.now().difference(dateAdded).inHours;
    return hoursDiff <= 24;
  }

  /// Check if this word is considered "mastered"
  bool get isMastered {
    // A word is "mastered" if it has comprehensive information
    // This indicates the user has fully learned and documented it
    bool hasAllFields =
        meaning.isNotEmpty &&
        synonyms.isNotEmpty &&
        antonyms.isNotEmpty &&
        sentence.isNotEmpty;

    // Also consider longer, complex words as more likely to be mastered
    bool isComplexWord = word.length > 7;

    return hasAllFields && isComplexWord;
  }

  /// Get the number of days since this word was added
  int get daysSinceAdded {
    return DateTime.now().difference(dateAdded).inDays;
  }

  /// Get count of synonyms
  int get synonymCount {
    return synonyms.split(',').where((s) => s.trim().isNotEmpty).length;
  }

  /// Get count of antonyms
  int get antonymCount {
    return antonyms.split(',').where((a) => a.trim().isNotEmpty).length;
  }

  /// Get formatted review status text
  String get reviewStatusText {
    if (isNew) {
      return "Just added";
    } else if (daysSinceAdded == 1) {
      return "Added yesterday";
    } else if (daysSinceAdded <= 7) {
      return "Added ${daysSinceAdded}d ago";
    } else if (daysSinceAdded < 30) {
      return "Added ${daysSinceAdded}d ago";
    } else if (daysSinceAdded < 365) {
      final months = (daysSinceAdded / 30).floor();
      return "Added ${months}mo ago";
    } else {
      final years = (daysSinceAdded / 365).floor();
      return "Added ${years}y ago";
    }
  }
}
