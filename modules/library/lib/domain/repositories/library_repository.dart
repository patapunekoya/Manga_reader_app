import '../entities/favorite_item.dart';
import '../entities/reading_progress.dart';

abstract class LibraryRepository {
  Future<void> toggleFavorite({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  });

  Future<List<FavoriteItem>> getFavorites();

  // Đánh dấu tiến trình theo MANGA (chỉ lưu lastChapter)
  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  });

  Future<List<ReadingProgress>> getContinueReading();

  // Lấy 1 progress theo mangaId (để “Đọc tiếp” chính xác)
  Future<ReadingProgress?> getProgressForManga(String mangaId);

  // NEW: xóa sạch lịch sử đọc
  Future<void> clearAllProgress();

  // Optional: xóa 1 favorite theo mangaId (long-press confirm sẽ gọi toggle cũng được)
  Future<void> removeFavorite(String mangaId);
}
