// lib/domain/entities/chapter.dart
import 'package:equatable/equatable.dart';
import '../value_objects/chapter_id.dart';
import '../value_objects/manga_id.dart';

/// Chapter: 1 chương truyện.
/// Dùng cho list_chapters và cho Reader screen (chỗ chọn chapter).
class Chapter extends Equatable {
  final ChapterId id;
  final MangaId mangaId;
  final String chapterNumber;    // "123"
  final String? title;           // "A New Dawn"
  final String? language;        // "en"
  final DateTime? updatedAt;     // parse ISO để sort/hiển thị

  const Chapter({
    required this.id,
    required this.mangaId,
    required this.chapterNumber,
    required this.title,
    required this.language,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        mangaId,
        chapterNumber,
        title,
        language,
        updatedAt,
      ];
}
