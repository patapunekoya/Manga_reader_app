// modules/library/lib/domain/repositories/library_repository.dart
//
// =============================================================================
// REPOSITORY CONTRACT: LibraryRepository
// =============================================================================
//
// Vai trò:
//   - Abstraction tầng Domain cho “thư viện cá nhân” của user:
//       • Yêu thích (Favorites)
//       • Tiếp tục đọc (Reading Progress) theo CHAPTER
//   - Ẩn chi tiết lưu trữ (Hive, SQLite, SharedPrefs...), tầng trên chỉ gọi
//     qua interface này. Dễ test/mock và thay đổi storage sau này.
//
// Dùng ở đâu:
//   - Usecases:
//       • ToggleFavorite
//       • GetFavorites
//       • SaveReadProgress
//       • GetContinueReading
//       • GetProgressForManga
//       • ClearAllProgress / RemoveFavorite (tùy UI dùng)
//   - UI/Home:
//       • BuildHomeVM lấy Continue Reading + hiển thị Favorites riêng.
//   - MangaDetail / Reader:
//       • Khi user bấm “Yêu thích” hoặc hoàn tất đọc chapter -> update progress.
//
// Gợi ý triển khai (ở Infrastructure):
//   - Với Hive:
//       • Box<FavoriteItem> theo key = mangaId
//       • Box<ReadingProgress> theo key = mangaId
//       • Sort ContinueReading theo savedAt desc khi trả ra.
//   - Đảm bảo tất cả thao tác I/O là async, tránh block UI.
//   - Nên bọc lỗi I/O, trả exception gọn để UI hiện snack bar hợp lý.
//
// Quy ước dữ liệu:
//   - Favorites: lưu tối thiểu mangaId, title, coverImageUrl, timestamps.
//   - ReadingProgress: lưu theo CHAPTER gần nhất (không page).
//   - “toggleFavorite”: nếu đang có thì xóa, chưa có thì thêm mới.
//
// =============================================================================

import '../entities/favorite_item.dart';
import '../entities/reading_progress.dart';

abstract class LibraryRepository {
  /// Thêm hoặc gỡ **yêu thích** cho 1 manga.
  /// - Nếu mangaId đã tồn tại trong favorites -> remove.
  /// - Nếu chưa có -> insert [mangaId, title, coverImageUrl, timestamps].
  /// Dùng cho nút tim ở MangaDetail.
  Future<void> toggleFavorite({
    required String mangaId,
    required String title,
    required String? coverImageUrl,
  });

  /// Lấy toàn bộ danh sách **Favorites** để render grid/list.
  /// Gợi ý: sort theo updatedAt desc để item mới tương tác lên đầu.
  Future<List<FavoriteItem>> getFavorites();

  // Đánh dấu tiến trình theo MANGA (chỉ lưu lastChapter)
  /// Lưu **tiến trình đọc** theo CHAPTER cho 1 manga:
  /// - Key: mangaId (mỗi manga duy nhất 1 record).
  /// - Ghi đè: lastChapterId, lastChapterNumber, savedAt = now.
  /// - Dùng khi user bắt đầu/tiếp tục/hoàn tất đọc 1 chapter.
  Future<void> saveReadProgress({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  });

  /// Lấy danh sách các **ReadingProgress** đã lưu,
  /// gợi ý sort savedAt desc để Home “Continue Reading” hiển thị hợp lý.
  Future<List<ReadingProgress>> getContinueReading();

  /// Lấy **progress của 1 manga** bất kỳ để “Đọc tiếp” chính xác.
  /// Trả về null nếu manga chưa có progress.
  Future<ReadingProgress?> getProgressForManga(String mangaId);

  // NEW: xóa sạch lịch sử đọc
  /// Xóa toàn bộ **ReadingProgress** (không ảnh hưởng Favorites).
  /// Hữu ích cho mục “Clear history” trong phần cài đặt.
  Future<void> clearAllProgress();

  // Optional: xóa 1 favorite theo mangaId (long-press confirm sẽ gọi toggle cũng được)
  /// Xóa cứng 1 **Favorite** theo mangaId.
  /// Dùng cho thao tác long-press hoặc menu context, nếu không muốn toggle.
  Future<void> removeFavorite(String mangaId);
}
