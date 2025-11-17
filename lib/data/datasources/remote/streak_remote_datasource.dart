// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/model/streak_model.dart';

/// Remote data source for Streak operations using Firebase Firestore
/// This is prepared for future Firebase integration
/// Currently returns empty/mock data but maintains the interface
class StreakRemoteDatasource {
  static final StreakRemoteDatasource _instance =
      StreakRemoteDatasource._internal();
  factory StreakRemoteDatasource() => _instance;
  StreakRemoteDatasource._internal();

  // Firestore instance (uncomment when ready)
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String userId = 'user_id'; // Get from auth

  /// Initialize Firestore connection
  Future<void> init() async {
    // TODO: Initialize Firebase Firestore connection
    // await Firebase.initializeApp();
  }

  /// Get streak data from Firestore
  Future<Streak> getStreak() async {
    // TODO: Implement Firestore streak retrieval
    // final doc = await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .get();
    // final data = doc.data();
    // if (data != null && data.containsKey('streak')) {
    //   return Streak.fromMap(data['streak']);
    // }

    return Streak(currentStreak: 0); // Return default for now
  }

  /// Save streak data to Firestore
  Future<void> saveStreak(Streak streak) async {
    // TODO: Implement Firestore streak save
    // await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .set({'streak': streak.toMap()}, SetOptions(merge: true));
  }

  /// Reset streak in Firestore
  Future<void> resetStreak() async {
    // TODO: Implement Firestore streak reset
    // await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .set({'streak': Streak(currentStreak: 0).toMap()},
    //         SetOptions(merge: true));
  }

  /// Sync streak from local to Firestore
  Future<void> syncStreak(Streak localStreak) async {
    // TODO: Implement streak sync logic
    // Compare local and remote streaks, keep the higher one
    // final remoteStreak = await getStreak();
    // if (localStreak.currentStreak > remoteStreak.currentStreak) {
    //   await saveStreak(localStreak);
    // }
  }
}
