// lib/domain/repositories/reader_repository.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là interface (abstract class) cho tầng Reader Repository.
//
// Vai trò:
//   ➤ Quy định những hành vi cần có để module Reader hoạt động:
//         1. Lấy danh sách trang (PageImage) theo chapterId
//         2. Prefetch ảnh (cache trước, optional cho MVP)
//         3. Báo lỗi ảnh khi load fail (log hoặc gửi server)
//
//   ➤ Tầng application/usecases (GetChapterPages, PrefetchPages,
//     ReportImageError) sẽ gọi vào ReaderRepository.
//   ➤ Tầng infrastructure sẽ implement file này bằng việc gọi
//     MangaDex API (chapter -> at-home server -> ảnh).
//
// Lợi ích:
//   ➤ Phân tách sạch domain khỏi tầng API/network.
//   ➤ Dễ thay backend, đổi cách load ảnh mà UI + Bloc không cần sửa.
//
// Ghi chú quan trọng:
//   - PageImage là entity domain.
//   - Chính implementation sẽ convert JSON MangaDex thành PageImage.
//
import '../entities/page_image.dart';

/// ReaderRepository:
/// -----------------
/// Định nghĩa 3 chức năng chính mà module Reader cần.
/// Tầng infrastructure sẽ implement những hàm này.
abstract class ReaderRepository {
  /// Lấy toàn bộ danh sách trang (PageImage) cho 1 chapter.
  Future<List<PageImage>> getChapterPages({
    required String chapterId,
  });

  /// Prefetch/load trước ảnh (tùy chọn, MVP có thể noop).
  Future<void> prefetchPages({
    required List<PageImage> pages,
  });

  /// Báo cáo lỗi ảnh (UI load img bị fail).
  /// MVP: chỉ cần log hoặc print.
  Future<void> reportImageError({
    required String chapterId,
    required int pageIndex,
    required String imageUrl,
  });
}
