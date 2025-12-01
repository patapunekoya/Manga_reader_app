import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// ============================================================================
/// LibraryFirestoreDataSource (CLOUD ONLY)
/// ============================================================================
class LibraryFirestoreDataSource {
  final FirebaseFirestore _firestore;

  LibraryFirestoreDataSource(this._firestore);

  // --- PATH HELPERS ---
  CollectionReference _favRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  CollectionReference _historyRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('history');
  }

  // --- FAVORITES OPERATIONS ---

  // Kiểm tra xem user đã thích truyện này chưa
  Future<bool> checkFavoriteExists(String userId, String mangaId) async {
    final doc = await _favRef(userId).doc(mangaId).get();
    return doc.exists;
  }

  Future<void> addFavorite(String userId, Map<String, dynamic> data) async {
    // Dùng mangaId làm Document ID để tránh trùng lặp
    await _favRef(userId).doc(data['mangaId']).set(data);
  }

  Future<void> removeFavorite(String userId, String mangaId) async {
    await _favRef(userId).doc(mangaId).delete();
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    // Lấy tất cả, sắp xếp theo updatedAt giảm dần (mới nhất lên đầu)
    final snapshot = await _favRef(userId)
        .orderBy('updatedAt', descending: true)
        .get();
    
    return snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList();
  }

  // --- HISTORY OPERATIONS ---

  Future<void> saveProgress(String userId, Map<String, dynamic> data) async {
    // Merge: true để chỉ update trường thay đổi (nếu cần), ở đây ta ghi đè savedAt
    await _historyRef(userId).doc(data['mangaId']).set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getAllHistory(String userId) async {
    final snapshot = await _historyRef(userId)
        .orderBy('savedAt', descending: true)
        .get();
    
    return snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getProgress(String userId, String mangaId) async {
    final doc = await _historyRef(userId).doc(mangaId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearAllHistory(String userId) async {
    // Firestore không có lệnh "xóa cả collection", phải xóa từng doc.
    // Với app nhỏ, loop xóa là ổn. App lớn nên dùng Cloud Function.
    final snapshot = await _historyRef(userId).get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}