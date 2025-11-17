import '../../core/model/word_model.dart';
import '../../core/repositories/word_repository.dart';
import '../datasources/local/words_local_datasource.dart';
import '../datasources/remote/words_remote_datasource.dart';

/// Implementation of WordRepository
/// Uses local datasource (Hive) as primary, with remote (Firestore) for future sync
class WordRepositoryImpl implements WordRepository {
  final WordsLocalDatasource _localDatasource;
  // ignore: unused_field
  final WordsRemoteDatasource _remoteDatasource;

  WordRepositoryImpl({
    WordsLocalDatasource? localDatasource,
    WordsRemoteDatasource? remoteDatasource,
  }) : _localDatasource = localDatasource ?? WordsLocalDatasource(),
       _remoteDatasource = remoteDatasource ?? WordsRemoteDatasource();

  @override
  Future<void> addWord(Word word) async {
    // Add to local storage first
    await _localDatasource.addWord(word);

    // TODO: Later, sync to Firestore in background
    // try {
    //   await _remoteDatasource.addWord(word);
    // } catch (e) {
    //   // Log error but don't fail - local is primary
    //   debugPrint('Failed to sync word to Firestore: $e');
    // }
  }

  @override
  Future<void> updateWord(int index, Word word) async {
    await _localDatasource.updateWord(index, word);

    // TODO: Later, sync to Firestore
    // await _remoteDatasource.updateWord(documentId, word);
  }

  @override
  Future<void> deleteWord(int index) async {
    await _localDatasource.deleteWord(index);

    // TODO: Later, sync to Firestore
    // await _remoteDatasource.deleteWord(documentId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWords() async {
    // Primary: Get from local storage
    final localWords = await _localDatasource.getAllWords();

    // TODO: Later, merge with remote if needed
    // if (shouldSyncWithRemote) {
    //   final remoteWords = await _remoteDatasource.getAllWords();
    //   return _mergeWords(localWords, remoteWords);
    // }

    return localWords;
  }

  @override
  Future<List<Map<String, dynamic>>> getWordsByDate({DateTime? date}) async {
    return await _localDatasource.getWordsByDate(date: date);
  }

  @override
  Future<List<Map<String, dynamic>>> getTodaysWords() async {
    return await _localDatasource.getTodaysWords();
  }

  @override
  Future<List<String>> getTodaysWordTexts() async {
    return await _localDatasource.getTodaysWordTexts();
  }

  @override
  Future<int> getWordsCount() async {
    return await _localDatasource.getWordsCount();
  }

  @override
  Future<Map<String, dynamic>?> getWord(int index) async {
    return await _localDatasource.getWord(index);
  }

  /// Future method: Sync local words to Firestore
  Future<void> syncToRemote() async {
    // TODO: Implement sync logic
    // final localWords = await getAllWords();
    // final words = localWords.map((m) => Word.fromMap(m)).toList();
    // await _remoteDatasource.syncWords(words);
  }
}
