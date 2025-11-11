// lib/application/usecases/report_image_error.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là usecase dùng để REPORT lỗi khi tải ảnh trang truyện.
//
// Ý nghĩa:
//   ➤ Khi Reader gặp lỗi load ảnh 1 trang, ta gọi usecase này
//     để thông báo lại cho Repository.
//   ➤ MVP: Repository chỉ cần "log / print" lỗi ra console.
//   ➤ Tương lai: có thể gửi metric, analytics hoặc lưu lại
//     để retry lần sau.
//
// Vì sao tách thành usecase?
//   - Đảm bảo kiến trúc sạch: Presentation (UI/Bloc) không
//     gọi trực tiếp repository mà luôn đi qua application layer.
//   - Dễ mở rộng thêm logic sau này (retry, log server...)
//   - ReaderBloc chỉ cần `.add(ReportError(...))` => dễ test.
//

import '../../domain/repositories/reader_repository.dart';

/// ReportImageError Usecase
/// -------------------------
/// Gửi dữ liệu lỗi ảnh về Repository.
///
/// Tham số:
///   - chapterId  : chương chứa ảnh bị lỗi
///   - pageIndex  : số trang (0-based)
///   - imageUrl   : URL ảnh tải lỗi
///
/// Repository sẽ quyết định làm gì:
///   - log error,
///   - thống kê lỗi,
///   - hoặc đơn giản bỏ qua.
class ReportImageError {
  final ReaderRepository _repo;
  const ReportImageError(this._repo);

  Future<void> call({
    required String chapterId,
    required int pageIndex,
    required String imageUrl,
  }) {
    return _repo.reportImageError(
      chapterId: chapterId,
      pageIndex: pageIndex,
      imageUrl: imageUrl,
    );
  }
}
