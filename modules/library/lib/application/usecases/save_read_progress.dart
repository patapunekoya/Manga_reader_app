// modules/library/lib/application/usecases/save_read_progress.dart
//
// ============================================================================
// USECASE: SaveReadProgress
// ============================================================================
// Mục đích:
//   - Đây là Usecase thuộc tầng Application của module `library_manga`.
//   - Dùng để LƯU TIẾN TRÌNH ĐỌC (Reading Progress) cho một manga.
//   - Tiến trình ở đây KHÔNG bao gồm pageIndex (bạn lưu theo CHAPTER).
//
// Khi nào được gọi:
//   - Khi người dùng mở một chapter để đọc.
//   - Khi người dùng chuyển sang chapter khác.
//   - Khi nhấn nút "Tiếp tục đọc" sẽ load dữ liệu từ usecase khác,
//     còn chính usecase này đảm nhiệm nhiệm vụ ghi dữ liệu.
//
// Nhiệm vụ chính:
//   - Nhận dữ liệu tiến trình từ UI/BLoC:
//        mangaId
//        mangaTitle
//        coverImageUrl
//        chapterId
//        chapterNumber
//   - Forward xuống LibraryRepository.saveReadProgress()
//   - Repository sẽ xử lý lưu xuống Hive (local).
//
// Tại sao tách thành Usecase riêng:
//   - Đảm bảo nguyên tắc Single Responsibility: Usecase chỉ lo nghiệp vụ,
//     không dính dáng đến UI, database, hay serialization.
//   - Dễ test (mock repository).
//   - Tách biệt với tầng Infrastructure giúp giữ kiến trúc sạch.
//
// Kết quả trả về:
//   - Future<void>
//   - Không trả dữ liệu, chỉ ghi trạng thái tiến trình.
//
// Lưu ý:
//   - Trong thư viện đọc (library module), phần hiển thị "Continue Reading"
//     sẽ dựa vào dữ liệu được lưu bởi Usecase này.
//   - Nếu sau này muốn lưu thêm pageIndex, timestamp, device,...
//     chỉ cần chỉnh Repository + entity, không đụng vào UI.
// ============================================================================

import '../../domain/repositories/library_repository.dart';

/// Lưu chương gần nhất cho một manga (không có page).
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
    // Gửi toàn bộ thông tin xuống tầng Repository để lưu local
    return _repo.saveReadProgress(
      mangaId: mangaId,
      mangaTitle: mangaTitle,
      coverImageUrl: coverImageUrl,
      chapterId: chapterId,
      chapterNumber: chapterNumber,
    );
  }
}
