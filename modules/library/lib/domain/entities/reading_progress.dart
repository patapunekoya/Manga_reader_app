// modules/library/lib/domain/entities/reading_progress.dart
//
// =============================================================================
// ENTITY: ReadingProgress (Tiến trình đọc theo CHAPTER)
// =============================================================================
//
// Mục đích:
//   - Lưu **tiến độ đọc của user theo từng manga**, cụ thể là *chương gần nhất*
//     mà user đã đọc.
//   - Được lưu LOCAL (Hive), không cần API.
//   - Được dùng cho UI "Continue Reading" ở màn Home
//     để hiển thị manga nào đang đọc dở.
//
// Tại sao thiết kế kiểu này?
//   • Mỗi manga chỉ lưu **1 record duy nhất** => id = mangaId.
//   • Không tracking pageIndex (vị trí trang) vì kiến trúc mới
//     xác định progress theo CHAPTER.
//   • Khi user mở chương → usecase SaveReadProgress gọi repository
//     để update record tương ứng.
//
// Được sử dụng ở đâu?
//   - Usecase: GetContinueReading()
//   - Usecase: SaveReadProgress()
//   - HomeBloc → BuildHomeVM → ContinueReadingStrip
//   - ReaderView (khi user nhấn Next/Prev chapter)
//   - LibraryRepositoryImpl (load/save Hive)
//
// Các field:
//   id                → ProgressId (value object cho type safety)
//   mangaId           → khoá chính để lưu duy nhất 1 progress / manga
//   mangaTitle        → hiển thị trên UI
//   coverImageUrl     → hiển thị trên card Continue Reading
//
//   lastChapterId     → chương gần nhất user đã đọc
//   lastChapterNumber → để render text "Chap xx"
//   savedAt           → dùng để sort: manga nào đọc gần nhất lên đầu
//
// copyWith():
//   - Dùng khi update một vài field (vd update cover, hoặc chapter mới)
//   - Không đổi id và mangaId (khóa cố định)
//
// Equatable:
//   - So sánh theo value để Bloc/Home UI rebuild chính xác
//   - Tránh lỗi UI không cập nhật khi dùng List<ReadingProgress>
//
// =============================================================================

import 'package:equatable/equatable.dart';
import '../value_objects/progress_id.dart';

/// ReadingProgress theo CHAPTER:
/// - Key lưu theo mangaId (mỗi manga chỉ có 1 record - chương gần nhất)
/// - Lưu lastChapterId + lastChapterNumber + savedAt (không lưu page)
class ReadingProgress extends Equatable {
  final ProgressId id;          // dùng mangaId làm id
  final String mangaId;
  final String mangaTitle;
  final String? coverImageUrl;

  final String lastChapterId;
  final String lastChapterNumber;

  final DateTime savedAt;

  const ReadingProgress({
    required this.id,
    required this.mangaId,
    required this.mangaTitle,
    required this.coverImageUrl,
    required this.lastChapterId,
    required this.lastChapterNumber,
    required this.savedAt,
  });

  ReadingProgress copyWith({
    String? mangaTitle,
    String? coverImageUrl,
    String? lastChapterId,
    String? lastChapterNumber,
    DateTime? savedAt,
  }) {
    return ReadingProgress(
      id: id,
      mangaId: mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      lastChapterId: lastChapterId ?? this.lastChapterId,
      lastChapterNumber: lastChapterNumber ?? this.lastChapterNumber,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mangaId,
        mangaTitle,
        coverImageUrl,
        lastChapterId,
        lastChapterNumber,
        savedAt,
      ];
}
