// modules/library/lib/infrastructure/repositories/library_repository_impl.dart

import 'package:library_manga/domain/entities/favorite_item.dart';
import 'package:library_manga/domain/entities/reading_progress.dart';
import 'package:library_manga/domain/repositories/library_repository.dart';
import 'package:library_manga/domain/value_objects/favorite_id.dart';
import 'package:library_manga/domain/value_objects/progress_id.dart';
import '../datasources/library_local_ds.dart';
import 'package:flutter/foundation.dart';

// THÊM: Dependencies cho Cloud Sync
import '../datasources/library_firestore_ds.dart'; // Import Firestore DS vừa tạo
import 'package:auth/domain/repositories/auth_repository.dart'; // Import Auth Repository


/// ============================================================================
/// LibraryRepositoryImpl
/// CẬP NHẬT: Thêm logic đồng bộ Local ↔ Cloud (Firestore)
/// ============================================================================
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource _local;
  final AuthRepository _authRepo; 
  final LibraryFirestoreDataSource _remote; 

  // CONSTRUCTOR MỚI: Nhận 3 dependencies (Local, Auth, Remote)
  LibraryRepositoryImpl(this._local, this._authRepo, this._remote); 

  // Getter tiện ích
  String? get _currentUserId => _authRepo.currentUser.id;
  bool get _isAuthenticated => _authRepo.currentUser.isNotEmpty;


  // --- HELPERS (Mapping) ---
  
  // Map FavoriteItem from raw map (giữ nguyên logic cũ)
  FavoriteItem _favFromMap(Map<String, dynamic> raw) {
    final mangaId  = raw['mangaId']?.toString() ?? '';
    final title  = raw['title']?.toString() ?? '';
    final cover  = raw['coverImageUrl']?.toString();
    final addedAtMs = raw['addedAt'] is int ? raw['addedAt'] as int : 0;
    final updatedAtMs = raw['updatedAt'] is int ? raw['updatedAt'] as int : addedAtMs;

    return FavoriteItem(
      id: FavoriteId(mangaId),
      title: title,
      coverImageUrl: cover,
      addedAt: DateTime.fromMillisecondsSinceEpoch(addedAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }

  // Map ReadingProgress from raw map (giữ nguyên logic cũ)
  ReadingProgress _progressFromMap(Map<String, dynamic> raw) {
    final mangaId  = raw['mangaId']?.toString() ?? '';
    final mangaTitle   = raw['mangaTitle']?.toString() ?? '';
    final cover         = raw['coverImageUrl']?.toString();
    final lastChapterId = raw['lastChapterId']?.toString() ?? '';
    final lastNum       = raw['lastChapterNumber']?.toString() ?? '';
    final savedAtMs     = raw['savedAt'] is int ? raw['savedAt'] as int : 0;

    return ReadingProgress(
      id: ProgressId(mangaId),
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverImageUrl: cover,
      lastChapterId: lastChapterId,
      lastChapterNumber: lastNum,
      savedAt: DateTime.fromMillisecondsSinceEpoch(savedAtMs),
    );
  }


  // --- FAVORITES IMPLEMENTATIONS ---

  @override
  Future<void> toggleFavorite({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  }) async {
    final existing = _local.getFavoriteRaw(mangaId);
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 1. Ghi/Xóa LOCAL (Hive)
    if (existing != null) {
      await _local.deleteFavorite(mangaId);
    } else {
      final data = {
        "mangaId": mangaId,
        "title": title,
        "coverImageUrl": coverImageUrl,
        "addedAt": now,
        "updatedAt": now,
      };
      await _local.putFavoriteRaw(mangaId, data);
    }

    // 2. LOGIC ĐỒNG BỘ CHO FIRESTORE (Fire-and-forget sync)
    if (_isAuthenticated) {
      if (existing != null) {
        // Xóa Cloud
        _remote.deleteFavorite(_currentUserId!, mangaId).catchError((e) => debugPrint("Firestore Delete Fav Error: $e"));
      } else {
        // Thêm/Update Cloud
        final data = _local.getFavoriteRaw(mangaId);
        if(data != null) {
            _remote.saveFavorite(_currentUserId!, data).catchError((e) => debugPrint("Firestore Save Fav Error: $e"));
        }
      }
    }
  }

  @override
  Future<void> removeFavorite(String mangaId) async {
    await _local.deleteFavorite(mangaId);
    
    // NEW: Sync xóa lên Firestore
    if (_isAuthenticated) {
      _remote.deleteFavorite(_currentUserId!, mangaId).catchError((e) => debugPrint("Firestore Remove Fav Error: $e"));
    }
  }

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    // TODO: LOGIC SYNC FROM CLOUD: Lấy data từ Cloud về Local nếu user mới đăng nhập
    // For now, only load local
    
    final rawList = _local.getAllFavoritesRaw();
    final items = rawList.map(_favFromMap).toList();

    items.sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));
    return items;
  }
  
  // --- PROGRESS IMPLEMENTATIONS ---

  @override
  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = {
      "mangaId": mangaId,
      "mangaTitle": mangaTitle,
      "coverImageUrl": coverImageUrl,
      "lastChapterId": chapterId,
      "lastChapterNumber": chapterNumber,
      "savedAt": now,
    };
    await _local.putProgressByMangaId(mangaId, data);

    // NEW: LOGIC ĐỒNG BỘ PROGRESS CHO FIRESTORE
    if (_isAuthenticated) {
      _remote.saveProgress(_currentUserId!, data).catchError((e) => debugPrint("Firestore Save Progress Error: $e"));
    }
  }

  @override
  Future<List<ReadingProgress>> getContinueReading() async {
    // TODO: LOGIC SYNC FROM CLOUD (Lấy data mới nhất từ Firestore)

    final rawList = _local.getAllProgressRaw();
    final list = rawList.map(_progressFromMap).toList();

    list.sort((a,b)=> b.savedAt.compareTo(a.savedAt));
    return list;
  }

  @override
  Future<ReadingProgress?> getProgressForManga(String mangaId) async {
    final raw = _local.getProgressByMangaId(mangaId);
    if (raw == null) return null;

    return _progressFromMap(raw);
  }

  @override
  Future<void> clearAllProgress() async {
    await _local.clearAllProgress();
    
    // NEW: Xóa khỏi cloud
    if (_isAuthenticated) {
      // Cần viết hàm clearAllProgress trong LibraryFirestoreDataSource
    }
  }
}