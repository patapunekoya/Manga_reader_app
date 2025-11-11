// lib/domain/entities/chapter.dart

import 'package:equatable/equatable.dart';
import '../value_objects/chapter_id.dart';
import '../value_objects/manga_id.dart';

/// ======================================================================
/// Entity: Chapter
///
/// Mục đích:
///   - Đại diện 1 chương truyện (chapter) trong Domain.
///   - Là dữ liệu chuẩn dùng cho:
///       • list_chapters (Catalog module)
///       • MangaDetail screen (danh sách chapter)
///       • Reader screen (đọc từng chapter + prefetch)
///
/// Đặc điểm theo Domain:
///   - Không phụ thuộc JSON hoặc class hạ tầng (DTO).  
///   - Chỉ chứa Value Objects + primitive đã chuẩn hóa.
///   - Không chứa logic parse; việc này do DTO ở infrastructure thực hiện.
///
/// Các trường:
///   - [id]          : ChapterId (Value Object đảm bảo tính hợp lệ)
///   - [mangaId]     : MangaId gốc của chapter
///   - [chapterNumber]: String biểu diễn số chương ("1", "10.5", "extra")
///   - [title]        : Tiêu đề chapter (nullable, tùy API)
///   - [language]     : Mã ngôn ngữ ("en", "vi", …) dùng cho filter
///   - [updatedAt]    : DateTime chuẩn ISO, phục vụ sort/hiển thị
///
/// Equatable:
///   - Giúp so sánh entity dựa vào giá trị (value-based equality).
///   - Rất quan trọng cho Bloc khi diff state.
///
/// Lưu ý:
///   - chapterNumber dạng String để phù hợp MangaDex (có nhiều định dạng).
///   - updatedAt nullable vì API đôi khi không trả timestamp.
/// ======================================================================
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
