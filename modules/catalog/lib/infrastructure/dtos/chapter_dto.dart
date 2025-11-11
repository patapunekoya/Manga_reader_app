// lib/infrastructure/dtos/chapter_dto.dart

import '../../domain/entities/chapter.dart';
import '../../domain/value_objects/chapter_id.dart';
import '../../domain/value_objects/manga_id.dart';

/// ======================================================================
/// DTO: ChapterDto
///
/// Mục đích:
///   - Đại diện dữ liệu *thô đã parse JSON* từ MangaDex.
///   - Là lớp trung gian giữa API (remote datasource) và Domain Entity.
///   - Không dùng trực tiếp trong UI hoặc BLoC.
///
/// Kiến trúc hạ tầng:
///   - Tầng Infrastructure quản lý DTO.
///   - DTO biết định dạng JSON của MangaDex.
///   - Domain Entity (Chapter) là dữ liệu sạch, chuẩn hóa.
///
/// Các bước:
///   1. RemoteDataSource trả JSON raw.
///   2. DTO.fromMangaDexJson chuyển JSON → ChapterDto.
///   3. RepositoryImpl gọi `toDomain()` để tạo Entity (Chapter).
///
/// Lưu ý quan trọng:
///   - MangaDex /feed và /chapter API **không luôn chứa mangaId** bên trong item.
///   - Vì vậy `mangaId` trong DTO để trống (''), RepositoryImpl sẽ truyền
///     đúng mangaId vào `toDomain(mangaIdOverride: ...)`.
///
/// ======================================================================
class ChapterDto {
  final String id;
  final String mangaId;           // placeholder – inject từ repo_impl
  final String chapterNumber;     // số chương dưới dạng string
  final String? title;            // tiêu đề chương (nullable)
  final String? language;         // mã ngôn ngữ
  final DateTime? updatedAt;      // thời gian cập nhật

  ChapterDto({
    required this.id,
    required this.mangaId,
    required this.chapterNumber,
    required this.title,
    required this.language,
    required this.updatedAt,
  });

  /// ======================================================================
  /// Factory: parse JSON từ MangaDex → ChapterDto
  ///
  /// JSON format ví dụ:
  /// {
  ///   "id": "123",
  ///   "attributes": {
  ///     "chapter": "10",
  ///     "title": "The Hunt",
  ///     "translatedLanguage": "en",
  ///     "updatedAt": "2023-03-01T10:00:00+00:00"
  ///   }
  /// }
  ///
  /// - Không gán mangaId ở đây vì API không đảm bảo có field đó.
  /// - RepositoryImpl phải truyền "mangaIdOverride".
  /// ======================================================================
  factory ChapterDto.fromMangaDexJson(Map<String, dynamic> json) {
    final chapId = json['id']?.toString() ?? '';
    final attrs = (json['attributes'] as Map<String, dynamic>? ?? {});

    final chapterNum = attrs['chapter']?.toString() ?? '';
    final chapterTitle = attrs['title']?.toString();
    final lang = attrs['translatedLanguage']?.toString();

    DateTime? upAt;
    final updatedAtRaw = attrs['updatedAt']?.toString();
    if (updatedAtRaw != null && updatedAtRaw.isNotEmpty) {
      upAt = DateTime.tryParse(updatedAtRaw);
    }

    return ChapterDto(
      id: chapId,
      mangaId: '', // sẽ override ở toDomain()
      chapterNumber: chapterNum,
      title: chapterTitle,
      language: lang,
      updatedAt: upAt,
    );
  }

  /// ======================================================================
  /// Mapping DTO → Domain Entity
  ///
  /// Vì DTO không chứa mangaId, ta bắt buộc truyền [mangaIdOverride].
  ///
  /// Domain Entity: Chapter
  ///   - Là dữ liệu sạch, không phụ thuộc JSON.
  ///   - Sử dụng Value Objects (ChapterId, MangaId).
  /// ======================================================================
  Chapter toDomain({required String mangaIdOverride}) {
    return Chapter(
      id: ChapterId(id),
      mangaId: MangaId(mangaIdOverride),
      chapterNumber: chapterNumber,
      title: title,
      language: language,
      updatedAt: updatedAt,
    );
  }
}
