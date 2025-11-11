// modules/reader/lib/application/usecases/save_read_progress.dart
//
// NOTE TỔNG QUAN FILE
// --------------------
// Đây là usecase "SaveReadProgress" dành cho MODULE READER.
//
// Chức năng:
//   ➤ Khi user đọc 1 chapter, ReaderBloc sẽ gọi usecase này để
//     lưu TIẾN TRÌNH ĐỌC *THEO MANGA*:
//       - mangaId
//       - mangaTitle
//       - coverImageUrl
//       - chapterId (chương đang đọc)
//       - chapterNumber (số chương, ví dụ: "12")
//   ➤ Lưu CHẠP GẦN NHẤT, không lưu pageIndex (đã bỏ tính năng lưu trang).
//
// Lưu ở đâu?
//   ➤ LibraryRepositoryImpl -> Hive box `progress_box`.
//
// Vì sao module reader có file facade riêng?
//   ➤ Reader module không cần biết logic bên library.
//   ➤ Chỉ gọi 1 lớp "hộp giao tiếp" (facade) để bảo toàn kiến trúc tách module.
//   ➤ Reader không import lung tung domain của library, chỉ tạo điểm nối đúng.
//
// Tương lai:
//   ➤ Có thể mở rộng: lưu thời gian đọc, tổng số trang đã lướt qua,
//     hoặc đồng bộ đám mây nếu cần.
//
import 'package:library_manga/domain/repositories/library_repository.dart';

/// Usecase: SaveReadProgress
/// -------------------------
/// Facade để READER module gọi sang LIBRARY module.
///
/// Tham số cần truyền vào từ ReaderBloc:
///   - mangaId           : id của manga đang đọc
///   - mangaTitle        : tên manga để hiển thị lịch sử
///   - coverImageUrl     : ảnh cover lưu vào history
///   - chapterId         : id chương hiện tại
///   - chapterNumber     : số chương (string)
///
/// Tác vụ:
///   ➤ Gọi LibraryRepository.saveReadProgress(...)
///   ➤ Repository tự lo ghi vào Hive.
class SaveReadProgress {
  final LibraryRepository _repo;
  const SaveReadProgress(this._repo);

  Future<void> call({
    required String mangaId,
    required String mangaTitle,
    required String? coverImageUrl,
    required String chapterId,
    required String chapterNumber,
  }) {
    return _repo.saveReadProgress(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverImageUrl: coverImageUrl,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
    );
  }
}
