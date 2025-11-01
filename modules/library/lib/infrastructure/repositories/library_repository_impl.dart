// lib/infrastructure/repositories/library_repository_impl.dart
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
    // Nếu đã tồn tại thì xóa => unfavorite
    final existing = _local.getFavoriteRaw(mangaId);

    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing != null) {
      // đã favorite => giờ bỏ
      await _local.deleteFavorite(mangaId);
    } else {
      // chưa có => thêm
      final data = {
        "mangaId": mangaId,
        "title": title,
        "coverImageUrl": coverImageUrl,
        "addedAt": now,
        "updatedAt": now,
      };
      await _local.putFavoriteRaw(mangaId, data);
    }
  }

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final rawList = _local.getAllFavoritesRaw();

    final items = rawList.map((raw) {
      final mangaId = raw['mangaId']?.toString() ?? '';
      final title = raw['title']?.toString() ?? '';
      final cover = raw['coverImageUrl']?.toString();
      final addedAtMs = raw['addedAt'] is int ? raw['addedAt'] as int : 0;
      final updatedAtMs =
          raw['updatedAt'] is int ? raw['updatedAt'] as int : addedAtMs;

      return FavoriteItem(
        id: FavoriteId(mangaId),
        title: title,
        coverImageUrl: cover,
        addedAt: DateTime.fromMillisecondsSinceEpoch(addedAtMs),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
      );
    }).toList();

    // sort theo updatedAt desc (mới tương tác sẽ lên đầu)
    items.sort(
      (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );

    return items;
  }

  @override
  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
    required int pageIndex,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final data = {
      "chapterId": chapterId,
      "mangaId": mangaId,
      "mangaTitle": mangaTitle,
      "coverImageUrl": coverImageUrl,
      "chapterNumber": chapterNumber,
      "pageIndex": pageIndex,
      "savedAt": now,
    };

    await _local.putProgressRaw(chapterId, data);
  }

  @override
  Future<List<ReadingProgress>> getContinueReading() async {
    final rawList = _local.getAllProgressRaw();

    final list = rawList.map((raw) {
      final chapterId = raw['chapterId']?.toString() ?? '';
      final mangaId = raw['mangaId']?.toString() ?? '';
      final mangaTitle = raw['mangaTitle']?.toString() ?? '';
      final cover = raw['coverImageUrl']?.toString();
      final chapterNumber = raw['chapterNumber']?.toString() ?? '';
      final pageIndexRaw = raw['pageIndex'];
      final pageIndex = pageIndexRaw is int ? pageIndexRaw : 0;
      final savedAtMs =
          raw['savedAt'] is int ? raw['savedAt'] as int : 0;

      return ReadingProgress(
        id: ProgressId(chapterId),
        chapterId: chapterId,
        mangaId: mangaId,
        mangaTitle: mangaTitle,
        coverImageUrl: cover,
        chapterNumber: chapterNumber,
        pageIndex: pageIndex,
        savedAt: DateTime.fromMillisecondsSinceEpoch(savedAtMs),
      );
    }).toList();

    // sort theo savedAt desc -> cái đọc gần nhất nằm trên cùng
    list.sort(
      (a, b) => b.savedAt.compareTo(a.savedAt),
    );

    return list;
  }
}
