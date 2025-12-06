import 'package:flutter/foundation.dart';
import 'package:library_manga/domain/entities/favorite_item.dart';
import 'package:library_manga/domain/entities/reading_progress.dart';
import 'package:library_manga/domain/repositories/library_repository.dart';
import 'package:library_manga/domain/value_objects/favorite_id.dart';
import 'package:library_manga/domain/value_objects/progress_id.dart';

import 'package:auth/domain/repositories/auth_repository.dart';
import '../datasources/library_firestore_ds.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final AuthRepository _authRepo;
  final LibraryFirestoreDataSource _remote;

  // FIX: Xóa tham số LibraryLocalDataSource thừa
  LibraryRepositoryImpl(this._authRepo, this._remote);

  String? get _userId => _authRepo.currentUser.id;
  bool get _isAuth => _authRepo.currentUser.isNotEmpty;

  @override
  Future<void> toggleFavorite({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  }) async {
    if (!_isAuth) return;

    try {
      final uid = _userId!;
      final exists = await _remote.checkFavoriteExists(uid, mangaId);

      if (exists) {
        await _remote.removeFavorite(uid, mangaId);
      } else {
        final now = DateTime.now().millisecondsSinceEpoch;
        await _remote.addFavorite(uid, {
          "mangaId": mangaId,
          "title": title,
          "coverImageUrl": coverImageUrl,
          "addedAt": now,
          "updatedAt": now,
        });
      }
    } catch (e) {
      debugPrint("Toggle Favorite Error: $e");
      // Không rethrow để tránh crash UI, chỉ log
    }
  }

  @override
  Future<void> removeFavorite(String mangaId) async {
    if (!_isAuth) return;
    try {
       await _remote.removeFavorite(_userId!, mangaId);
    } catch (e) {
       debugPrint("Remove Favorite Error: $e");
    }
  }

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    if (!_isAuth) return [];

    try {
      final rawList = await _remote.getFavorites(_userId!);
      return rawList.map((raw) {
        return FavoriteItem(
          id: FavoriteId(raw['mangaId']),
          title: raw['title'] ?? '',
          coverImageUrl: raw['coverImageUrl'],
          addedAt: DateTime.fromMillisecondsSinceEpoch(raw['addedAt'] ?? 0),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(raw['updatedAt'] ?? 0),
        );
      }).toList();
    } catch (e) {
      debugPrint("Get Favorites Error: $e");
      return [];
    }
  }

  @override
  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  }) async {
    if (!_isAuth) return;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _remote.saveProgress(_userId!, {
        "mangaId": mangaId,
        "mangaTitle": mangaTitle,
        "coverImageUrl": coverImageUrl,
        "lastChapterId": chapterId,
        "lastChapterNumber": chapterNumber,
        "savedAt": now,
      });
    } catch (e) {
      debugPrint("Save Progress Error: $e");
    }
  }

  @override
  Future<List<ReadingProgress>> getContinueReading() async {
    if (!_isAuth) return [];

    try {
      final rawList = await _remote.getAllHistory(_userId!);
      return rawList.map((raw) {
        return ReadingProgress(
          id: ProgressId(raw['mangaId']),
          mangaId: raw['mangaId'],
          mangaTitle: raw['mangaTitle'] ?? '',
          coverImageUrl: raw['coverImageUrl'],
          lastChapterId: raw['lastChapterId'] ?? '',
          lastChapterNumber: raw['lastChapterNumber'] ?? '',
          savedAt: DateTime.fromMillisecondsSinceEpoch(raw['savedAt'] ?? 0),
        );
      }).toList();
    } catch (e) {
      debugPrint("Get History Error: $e");
      return [];
    }
  }

  @override
  Future<ReadingProgress?> getProgressForManga(String mangaId) async {
    if (!_isAuth) return null;

    try {
      final raw = await _remote.getProgress(_userId!, mangaId);
      if (raw == null) return null;

      return ReadingProgress(
        id: ProgressId(raw['mangaId']),
        mangaId: raw['mangaId'],
        mangaTitle: raw['mangaTitle'] ?? '',
        coverImageUrl: raw['coverImageUrl'],
        lastChapterId: raw['lastChapterId'] ?? '',
        lastChapterNumber: raw['lastChapterNumber'] ?? '',
        savedAt: DateTime.fromMillisecondsSinceEpoch(raw['savedAt'] ?? 0),
      );
    } catch (e) {
      debugPrint("Get Progress Error: $e");
      return null;
    }
  }

  @override
  Future<void> clearAllProgress() async {
    if (!_isAuth) return;
    try {
        await _remote.clearAllHistory(_userId!);
    } catch (e) {
        debugPrint("Clear History Error: $e");
    }
  }
}