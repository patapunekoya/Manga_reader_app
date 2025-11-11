// lib/application/usecases/get_chapter_pages.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là **usecase** thuộc module Reader.
// Usecase = một hành động nghiệp vụ đơn lẻ, tách khỏi UI và Data layer.
//
// Chức năng của usecase này khá rõ ràng:
//   ➤ Lấy toàn bộ danh sách trang (PageImage) của *một chapter*
//   ➤ Được gọi bởi ReaderBloc hoặc ReaderScreen.
//   ➤ Repository sẽ xử lý gọi API MangaDex và trả về list ảnh.
//
// Việc tách logic vào usecase giúp:
// - Dễ test, dễ mock
// - ReaderBloc nhẹ, không dính trực tiếp repository
// - Đúng chuẩn Clean Architecture

import '../../domain/entities/page_image.dart';
import '../../domain/repositories/reader_repository.dart';

/// GetChapterPages:
/// ----------------
/// Trả về toàn bộ danh sách trang (PageImage) của 1 chapter.
/// ReaderBloc gọi cái này khi user mở chapter.
///
/// Input:
///   - chapterId: id chapter MangaDex
///
/// Output:
///   - Future<List<PageImage>>
///
/// Repository chịu trách nhiệm fetch file data + ảnh.
class GetChapterPages {
  final ReaderRepository _repo;

  const GetChapterPages(this._repo);

  Future<List<PageImage>> call({required String chapterId}) {
    return _repo.getChapterPages(chapterId: chapterId);
  }
}
