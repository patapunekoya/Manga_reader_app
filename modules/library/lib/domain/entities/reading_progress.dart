// modules/library/lib/domain/entities/reading_progress.dart
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
