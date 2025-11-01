// lib/application/usecases/get_chapter_pages.dart
import '../../domain/entities/page_image.dart';
import '../../domain/repositories/reader_repository.dart';

/// GetChapterPages:
/// Trả về toàn bộ danh sách trang (PageImage) của 1 chapter.
/// ReaderBloc gọi cái này khi mở chapter.
class GetChapterPages {
  final ReaderRepository _repo;
  const GetChapterPages(this._repo);

  Future<List<PageImage>> call({required String chapterId}) {
    return _repo.getChapterPages(chapterId: chapterId);
  }
}
