// lib/domain/repositories/reader_repository.dart
import '../entities/page_image.dart';

/// ReaderRepository:
/// - Lấy danh sách PageImage cho 1 chapterId
/// - Có thể prefetch (load sẵn, cache sẵn)
/// - Có thể report lỗi ảnh nếu cần
abstract class ReaderRepository {
  Future<List<PageImage>> getChapterPages({
    required String chapterId,
  });

  Future<void> prefetchPages({
    required List<PageImage> pages,
  });

  Future<void> reportImageError({
    required String chapterId,
    required int pageIndex,
    required String imageUrl,
  });
}
