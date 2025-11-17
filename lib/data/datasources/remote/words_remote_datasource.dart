// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/model/word_model.dart';

/// Remote data source for Word operations using Firebase Firestore
/// This is prepared for future Firebase integration
/// Currently returns empty/mock data but maintains the interface
class WordsRemoteDatasource {
  static final WordsRemoteDatasource _instance =
      WordsRemoteDatasource._internal();
  factory WordsRemoteDatasource() => _instance;
  WordsRemoteDatasource._internal();

  // Firestore instance (uncomment when ready)
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String userId = 'user_id'; // Get from auth

  /// Initialize Firestore connection
  Future<void> init() async {
    // TODO: Initialize Firebase Firestore connection
    // await Firebase.initializeApp();
  }

  /// Add a new word to Firestore
  Future<void> addWord(Word word) async {
    // TODO: Implement Firestore word addition
    // await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .collection('words')
    //     .add(word.toMap());
  }

  /// Update an existing word in Firestore
  Future<void> updateWord(String documentId, Word word) async {
    // TODO: Implement Firestore word update
    // await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .collection('words')
    //     .doc(documentId)
    //     .update(word.toMap());
  }

  /// Delete a word from Firestore
  Future<void> deleteWord(String documentId) async {
    // TODO: Implement Firestore word deletion
    // await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .collection('words')
    //     .doc(documentId)
    //     .delete();
  }

  /// Get all words from Firestore
  Future<List<Map<String, dynamic>>> getAllWords() async {
    // TODO: Implement Firestore word retrieval
    // final snapshot = await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .collection('words')
    //     .orderBy('dateAdded', descending: true)
    //     .get();
    // return snapshot.docs.map((doc) => doc.data()).toList();

    return []; // Return empty list for now
  }

  /// Get words for a specific date from Firestore
  Future<List<Map<String, dynamic>>> getWordsByDate({DateTime? date}) async {
    // TODO: Implement Firestore date-based query
    // date ??= DateTime.now();
    // final startOfDay = DateTime(date.year, date.month, date.day);
    // final endOfDay = startOfDay.add(const Duration(days: 1));

    // final snapshot = await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .collection('words')
    //     .where('dateAdded', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
    //     .where('dateAdded', isLessThan: endOfDay.toIso8601String())
    //     .get();
    // return snapshot.docs.map((doc) => doc.data()).toList();

    return []; // Return empty list for now
  }

  /// Sync local words to Firestore
  Future<void> syncWords(List<Word> localWords) async {
    // TODO: Implement batch upload to Firestore
    // final batch = _firestore.batch();
    // for (final word in localWords) {
    //   final docRef = _firestore
    //       .collection('users')
    //       .doc(userId)
    //       .collection('words')
    //       .doc();
    //   batch.set(docRef, word.toMap());
    // }
    // await batch.commit();
  }
}
