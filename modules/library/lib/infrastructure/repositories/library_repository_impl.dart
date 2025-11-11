import 'package:library_manga/domain/entities/favorite_item.dart';
import 'package:library_manga/domain/entities/reading_progress.dart';
import 'package:library_manga/domain/repositories/library_repository.dart';
import 'package:library_manga/domain/value_objects/favorite_id.dart';
import 'package:library_manga/domain/value_objects/progress_id.dart';
import '../datasources/library_local_ds.dart';

/// ============================================================================
/// LibraryRepositoryImpl
/// ============================================================================
/// Vai trò:
/// - Implement interface `LibraryRepository` cho module Library.
/// - Là lớp *trung gian domain ↔ data source*: nhận/đưa Entity & VO ra vào.
/// - Dùng `LibraryLocalDataSource` (Hive) để lưu offline Favorites và Progress.
///
/// Thiết kế/Quy ước dữ liệu (local):
/// - Favorites:
///     key   : mangaId (String)
///     value : Map{
///        "mangaId", "title", "coverImageUrl",
///        "addedAt", "updatedAt" (millisecondsSinceEpoch)
///     }
/// - Progress theo MANGA (không theo page):
///     key   : mangaId (String)
///     value : Map{
///        "mangaId", "mangaTitle", "coverImageUrl",
///        "lastChapterId", "lastChapterNumber",
///        "savedAt" (millisecondsSinceEpoch)
///     }
///
/// Lưu ý quan trọng:
/// - Phải gọi `_local.init()` trong bootstrap trước khi dùng repo này,
///   nếu không `LibraryLocalDataSource` sẽ quăng lỗi.
/// - Tất cả sort thời gian dùng DateTime.fromMillisecondsSinceEpoch.
/// - Ở đây không làm logic phức tạp, chỉ mapping raw Map ↔ Entity/VO.
/// ============================================================================
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource _local;
  LibraryRepositoryImpl(this._local);

  /// Toggle yêu thích:
  /// - Nếu đã tồn tại: xoá khỏi favorites.
  /// - Nếu chưa tồn tại: thêm mới với `addedAt` và `updatedAt` = now.
  ///
  /// Dùng epoch milli để nhẹ và ổn định khi sort.
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

  /// Xoá yêu thích theo mangaId (tiện dụng khi cần thao tác trực tiếp).
  @override
  Future<void> removeFavorite(String mangaId) async {
    await _local.deleteFavorite(mangaId);
  }

  /// Lấy danh sách Favorites dưới dạng Entity `FavoriteItem`:
  /// - Map raw -> Entity + VO `FavoriteId`
  /// - Sort theo `updatedAt` desc để item vừa “động” lên trước.
  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final rawList = _local.getAllFavoritesRaw();
    final items = rawList.map((raw) {
      final mangaId   = raw['mangaId']?.toString() ?? '';
      final title     = raw['title']?.toString() ?? '';
      final cover     = raw['coverImageUrl']?.toString();
      final addedAtMs = raw['addedAt'] is int ? raw['addedAt'] as int : 0;
      final updatedAtMs = raw['updatedAt'] is int ? raw['updatedAt'] as int : addedAtMs;

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

  /// Lưu tiến trình đọc THEO MANGA (không track page):
  /// - Ghi đè record theo key = mangaId.
  /// - Chỉ lưu chương gần nhất (id + number) và thời điểm `savedAt`.
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

  /// Lấy danh sách Continue Reading (đọc dở) để hiển thị strip ở Home:
  /// - Map raw -> `ReadingProgress` + `ProgressId(mangaId)`
  /// - Sort theo `savedAt` desc để item vừa đọc lên đầu.
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

  /// Lấy 1 progress theo mangaId để nút “Đọc tiếp” chạy đúng chương.
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

  /// Xoá sạch mọi progress. Dùng cho chức năng “Clear history” trong Settings.
  @override
  Future<void> clearAllProgress() async {
    await _local.clearAllProgress();
  }
}
