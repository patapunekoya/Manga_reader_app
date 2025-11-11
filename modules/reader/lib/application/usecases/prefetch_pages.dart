// lib/application/usecases/prefetch_pages.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là usecase hỗ trợ trải nghiệm Reader mượt hơn:
//   ➤ Prefetch = tải trước ảnh của các trang kế tiếp
//     (giúp khi người dùng lật trang không bị chờ load lâu)
//
// Ưu điểm khi tách thành usecase riêng:
// - ReaderBloc chỉ biết “prefetchPages()” chứ không quan tâm repository làm gì.
// - Repository có thể implement nhiều kiểu caching (memory/disk/network).
// - MVP có thể để "noop" nhưng vẫn đảm bảo kiến trúc sạch.
//
// Dòng chảy:
// ReaderBloc -> PrefetchPages -> ReaderRepository.prefetchPages()

import '../../domain/entities/page_image.dart';
import '../../domain/repositories/reader_repository.dart';

/// PrefetchPages:
/// --------------
/// Cho phép tải trước/cache danh sách ảnh (PageImage) sắp tới.
///
/// Param:
///   - pages: danh sách PageImage mà reader muốn cache trước.
///
/// Trả về:
///   - Future<void> (không trả dữ liệu, chỉ action).
///
/// Lưu ý: MVP có thể để rỗng nhưng repository vẫn phải có hàm này.
class PrefetchPages {
  final ReaderRepository _repo;
  const PrefetchPages(this._repo);

  Future<void> call({required List<PageImage> pages}) {
    return _repo.prefetchPages(pages: pages);
  }
}
