// lib/domain/entities/reading_progress.dart
import 'package:equatable/equatable.dart';
import '../value_objects/progress_id.dart';

/// ReadingProgress:
/// Lưu tiến trình đọc cuối cùng của user cho 1 chapter.
///
/// Ta giữ:
/// - chapterId
/// - mangaId
/// - mangaTitle để show "Continue reading"
/// - coverImageUrl để show thumbnail
/// - chapterNumber để hiển thị "Ch.123"
/// - pageIndex (trang đang đọc dở)
/// - savedAt (thời điểm lưu -> dùng sort 'tiếp tục đọc')
class ReadingProgress extends Equatable {
  final ProgressId id; // chapterId
  final String chapterId;
  final String mangaId;
  final String mangaTitle;
  final String? coverImageUrl;
  final String chapterNumber;
  final int pageIndex;
  final DateTime savedAt;

  const ReadingProgress({
    required this.id,
    required this.chapterId,
    required this.mangaId,
    required this.mangaTitle,
    required this.coverImageUrl,
    required this.chapterNumber,
    required this.pageIndex,
    required this.savedAt,
  });

  ReadingProgress copyWith({
    String? mangaTitle,
    String? coverImageUrl,
    String? chapterNumber,
    int? pageIndex,
    DateTime? savedAt,
  }) {
    return ReadingProgress(
      id: id,
      chapterId: chapterId,
      mangaId: mangaId,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      pageIndex: pageIndex ?? this.pageIndex,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chapterId,
        mangaId,
        mangaTitle,
        coverImageUrl,
        chapterNumber,
        pageIndex,
        savedAt,
      ];
}
