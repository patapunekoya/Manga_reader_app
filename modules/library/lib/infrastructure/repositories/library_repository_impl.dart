// modules/library/lib/infrastructure/repositories/library_repository_impl.dart
import 'package:library_manga/domain/entities/favorite_item.dart';
import 'package:library_manga/domain/entities/reading_progress.dart';
import 'package:library_manga/domain/repositories/library_repository.dart';
import 'package:library_manga/domain/value_objects/favorite_id.dart';
import 'package:library_manga/domain/value_objects/progress_id.dart';
import '../datasources/library_local_ds.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource _local;
  LibraryRepositoryImpl(this._local);

  @override
  Future<void> toggleFavorite({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  }) async {
    final existing = _local.getFavoriteRaw(mangaId);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing != null) {
      await _local.deleteFavorite(mangaId);
    } else {
      await _local.putFavoriteRaw(mangaId, {
        "mangaId": mangaId,
        "title": title,
        "coverImageUrl": coverImageUrl,
        "addedAt": now,
        "updatedAt": now,
      });
    }
  }

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final rawList = _local.getAllFavoritesRaw();
    final items = rawList.map((raw) {
      final mangaId = raw['mangaId']?.toString() ?? '';
      final title   = raw['title']?.toString() ?? '';
      final cover   = raw['coverImageUrl']?.toString();
      final addedAtMs  = raw['addedAt'] is int ? raw['addedAt'] as int : 0;
      final updatedAtMs= raw['updatedAt'] is int ? raw['updatedAt'] as int : addedAtMs;
      return FavoriteItem(
        id: FavoriteId(mangaId),
        title: title,
        coverImageUrl: cover,
        addedAt: DateTime.fromMillisecondsSinceEpoch(addedAtMs),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
      );
    }).toList();

    items.sort((a,b)=> b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _local.putProgressByMangaId(mangaId, {
      "mangaId": mangaId,
      "mangaTitle": mangaTitle,
      "coverImageUrl": coverImageUrl,
      "lastChapterId": chapterId,
      "lastChapterNumber": chapterNumber,
      "savedAt": now,
    });
  }

  @override
  Future<List<ReadingProgress>> getContinueReading() async {
    final rawList = _local.getAllProgressRaw();
    final list = rawList.map((raw) {
      final mangaId       = raw['mangaId']?.toString() ?? '';
      final mangaTitle    = raw['mangaTitle']?.toString() ?? '';
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
    }).toList();

    list.sort((a,b)=> b.savedAt.compareTo(a.savedAt));
    return list;
  }

  @override
  Future<ReadingProgress?> getProgressForManga(String mangaId) async {
    final raw = _local.getProgressByMangaId(mangaId);
    if (raw == null) return null;

    final mangaTitle    = raw['mangaTitle']?.toString() ?? '';
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
}
