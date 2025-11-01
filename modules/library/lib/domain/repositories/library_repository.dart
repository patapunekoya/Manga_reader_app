// lib/domain/repositories/library_repository.dart
import '../entities/favorite_item.dart';
import '../entities/reading_progress.dart';

/// LibraryRepository:
/// - toggleFavorite: add/remove favorite manga
/// - getFavorites: trả list sort theo updatedAt desc
/// - saveReadProgress: lưu user đang đọc tới đâu
/// - getContinueReading: trả danh sách progress sort savedAt desc
abstract class LibraryRepository {
  Future<void> toggleFavorite({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  });

  Future<List<FavoriteItem>> getFavorites();

  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
    required int pageIndex,
  });

  Future<List<ReadingProgress>> getContinueReading();
}
