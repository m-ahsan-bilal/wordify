import '../../../core/model/xp_model.dart';

/// Remote data source for XP operations using Firestore
/// Handles all remote database operations for XP tracking
/// TODO: Implement when Firebase is integrated
class XPRemoteDatasource {
  static final XPRemoteDatasource _instance = XPRemoteDatasource._internal();
  factory XPRemoteDatasource() => _instance;
  XPRemoteDatasource._internal();

  // TODO: Add FirebaseFirestore instance when Firebase is integrated
  // late FirebaseFirestore _firestore;

  /// Initialize Firestore connection
  Future<void> init() async {
    // TODO: Initialize Firestore
    // _firestore = FirebaseFirestore.instance;
  }

  /// Get XP data from Firestore
  Future<XP> getXP(String userId) async {
    // TODO: Implement Firestore get
    // final doc = await _firestore.collection('users').doc(userId).get();
    // if (doc.exists) {
    //   final data = doc.data()!;
    //   return XP.fromMap(data['xp'] ?? {});
    // }
    
    // Return default XP for now
    return XP(totalXP: 0, currentLevel: 1);
  }

  /// Save XP data to Firestore
  Future<void> saveXP(String userId, XP xp) async {
    // TODO: Implement Firestore save
    // await _firestore.collection('users').doc(userId).set({
    //   'xp': xp.toMap(),
    //   'lastUpdated': FieldValue.serverTimestamp(),
    // }, SetOptions(merge: true));
  }

  /// Add XP and update in Firestore
  Future<({XP newXP, bool leveledUp})> addXP(String userId, int xpToAdd) async {
    // TODO: Implement Firestore transaction for atomic XP update
    // return await _firestore.runTransaction((transaction) async {
    //   final currentXP = await getXP(userId);
    //   final newXP = currentXP.addXP(xpToAdd);
    //   final leveledUp = newXP.didLevelUp(currentXP);
    //   
    //   await saveXP(userId, newXP);
    //   return (newXP: newXP, leveledUp: leveledUp);
    // });
    
    // Placeholder implementation
    final currentXP = await getXP(userId);
    final newXP = currentXP.addXP(xpToAdd);
    final leveledUp = newXP.didLevelUp(currentXP);
    await saveXP(userId, newXP);
    
    return (newXP: newXP, leveledUp: leveledUp);
  }

  /// Reset XP in Firestore
  Future<void> resetXP(String userId) async {
    // TODO: Implement Firestore reset
    // final resetXP = XP(totalXP: 0, currentLevel: 1, lastUpdated: DateTime.now());
    // await saveXP(userId, resetXP);
  }

  /// Sync XP data between local and remote
  Future<XP> syncXP(String userId, XP localXP) async {
    // TODO: Implement sync logic
    // 1. Get remote XP
    // 2. Compare timestamps
    // 3. Merge or choose most recent
    // 4. Update both local and remote if needed
    
    return localXP; // Placeholder
  }
}
