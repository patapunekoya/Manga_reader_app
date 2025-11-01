// lib/application/usecases/prefetch_pages.dart
import '../../domain/entities/page_image.dart';
import '../../domain/repositories/reader_repository.dart';

/// PrefetchPages:
/// Cho phép tải trước/cache các trang sắp tới.
/// MVP: có thể làm rỗng (noop) nhưng ta vẫn giữ usecase để flow rõ.
class PrefetchPages {
  final ReaderRepository _repo;
  const PrefetchPages(this._repo);

  Future<void> call({required List<PageImage> pages}) {
    return _repo.prefetchPages(pages: pages);
  }
}
