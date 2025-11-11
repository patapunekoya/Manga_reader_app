// modules/library_manga/lib/application/usecases/get_continue_reading.dart
//
// ============================================================================
// USECASE: GetContinueReading
// ============================================================================
// Nhiệm vụ:
//   - Đây là Usecase thuộc tầng Application của module `library_manga`.
//   - Tầng Application KHÔNG xử lý logic UI, KHÔNG đụng network trực tiếp.
//   - Usecase này chỉ điều phối nghiệp vụ: yêu cầu dữ liệu từ Repository,
//     sau đó trả kết quả cho Bloc hoặc ViewModel.
//
// Vai trò trong kiến trúc:
//   - HomeScreen cần lấy danh sách "Continue Reading" (truyện người dùng đang
//     đọc dở).
//   - Bloc ở màn Home sẽ gọi usecase này thông qua BuildHomeVM.
//   - Usecase giúp cô lập logic business, tách khỏi UI và datasource.
//
// Flow hoạt động:
//   1) _repo.getContinueReading() -> gọi vào Repository
//   2) Repository sẽ truy vấn Hive (local storage) để lấy danh sách
//      ReadingProgress (mangaId, chapter đang đọc, trang đang đọc).
//   3) Trả về danh sách ReadingProgress đã được sort theo savedAt DESC
//      để hiển thị "mới đọc gần nhất" lên trước.
//
// Ghi chú kiến trúc sạch (Clean Architecture / DDD):
//   - Usecase chỉ chứa *một hành động duy nhất* (Single Responsibility).
//   - Dễ dàng mock test để test logic HomeBloc mà không phụ thuộc vào Hive.
// ============================================================================

import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/library_repository.dart';

class GetContinueReading {
  final LibraryRepository _repo;

  const GetContinueReading(this._repo);

  Future<List<ReadingProgress>> call() {
    // chuyển nhiệm vụ xuống Repository
    return _repo.getContinueReading();
  }
}
