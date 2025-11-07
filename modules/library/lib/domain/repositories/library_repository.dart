// modules/library/lib/domain/repositories/library_repository.dart
import '../entities/favorite_item.dart';
import '../entities/reading_progress.dart';

abstract class LibraryRepository {
  Future<void> toggleFavorite({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  });

  Future<List<FavoriteItem>> getFavorites();

  /// Lưu CHAPTER gần nhất cho MANGA (ghi đè theo mangaId)
  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  });

  /// Lấy danh sách manga có “đọc tiếp” (sort savedAt desc)
  Future<List<ReadingProgress>> getContinueReading();

  /// Lấy progress cho 1 manga (null nếu chưa có)
  Future<ReadingProgress?> getProgressForManga(String mangaId);
}
