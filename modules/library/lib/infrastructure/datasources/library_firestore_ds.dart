import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// ============================================================================
/// LibraryFirestoreDataSource
/// ============================================================================
class LibraryFirestoreDataSource {
  final FirebaseFirestore _firestore;

  LibraryFirestoreDataSource(this._firestore);

  // --- PATH HELPERS ---
  // Collection Favorites: users/{userId}/favorites
  CollectionReference _getFavoritesCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites');
  }

  // Collection History: users/{userId}/history
  CollectionReference _getHistoryCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history');
  }

  // --- FAVORITES CLOUD OPERATIONS ---

  Future<void> saveFavorite(String userId, Map<String, dynamic> rawData) async {
    final mangaId = rawData['mangaId'];
    if (mangaId != null) {
      // Dùng mangaId làm Document ID
      await _getFavoritesCollection(userId).doc(mangaId).set(rawData, SetOptions(merge: true));
    }
  }

  Future<void> deleteFavorite(String userId, String mangaId) async {
    await _getFavoritesCollection(userId).doc(mangaId).delete();
  }

  @override
  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final snapshot = await _getFavoritesCollection(userId).get();
    // FIX: Ép kiểu tường minh (as Map<String, dynamic>)
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(); 
  }
  
  // --- HISTORY CLOUD OPERATIONS ---

  Future<void> saveProgress(String userId, Map<String, dynamic> rawData) async {
    final mangaId = rawData['mangaId'];
    if (mangaId != null) {
      // Dùng mangaId làm Document ID
      await _getHistoryCollection(userId).doc(mangaId).set(rawData, SetOptions(merge: true));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    final snapshot = await _getHistoryCollection(userId).get();
    // FIX: Ép kiểu tường minh (as Map<String, dynamic>)
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}