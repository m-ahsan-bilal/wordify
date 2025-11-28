import 'dart:convert';

/// Backup data structure containing all app data
/// Follows the app's model architecture pattern
class BackupData {
  final List<Map<String, dynamic>> words;
  final Map<String, dynamic> streak;
  final List<Map<String, dynamic>> quizHistory;
  final List<Map<String, dynamic>> quizResults;
  final String backupDate;
  final String appVersion;

  BackupData({
    required this.words,
    required this.streak,
    required this.quizHistory,
    required this.quizResults,
    required this.backupDate,
    required this.appVersion,
  });

  /// Convert to JSON string
  String toJson() {
    return jsonEncode({
      'words': words,
      'streak': streak,
      'quizHistory': quizHistory,
      'quizResults': quizResults,
      'backupDate': backupDate,
      'appVersion': appVersion,
    });
  }

  /// Create from JSON string
  factory BackupData.fromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return BackupData(
      words: List<Map<String, dynamic>>.from(data['words'] ?? []),
      streak: Map<String, dynamic>.from(data['streak'] ?? {}),
      quizHistory: List<Map<String, dynamic>>.from(data['quizHistory'] ?? []),
      quizResults: List<Map<String, dynamic>>.from(data['quizResults'] ?? []),
      backupDate: data['backupDate'] ?? '',
      appVersion: data['appVersion'] ?? '',
    );
  }

  /// Create empty backup
  factory BackupData.empty() {
    return BackupData(
      words: [],
      streak: {},
      quizHistory: [],
      quizResults: [],
      backupDate: DateTime.now().toIso8601String(),
      appVersion: '1.0.0',
    );
  }
}

