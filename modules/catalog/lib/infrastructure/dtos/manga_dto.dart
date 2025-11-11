// lib/infrastructure/dtos/manga_dto.dart

import '../../domain/entities/manga.dart';
import '../../domain/value_objects/manga_id.dart';

/// ======================================================================
/// DTO: MangaDto
///
/// Mục đích:
///   - Đại diện dữ liệu JSON từ MangaDex (endpoint /manga).
///   - Chứa toàn bộ logic parse JSON, relationships, attributes.
///   - Không được dùng trực tiếp ở UI/BLoC.
///   - RepositoryImpl sẽ chuyển MangaDto → Manga (Domain Entity).
///
/// Vai trò trong kiến trúc:
///   - Thuộc tầng Infrastructure.
///   - Tách biệt hoàn toàn Domain Entity khỏi cấu trúc JSON phức tạp.
///   - Chỉ DTO mới biết JSON của MangaDex.
///   - Domain chỉ nhận dữ liệu sạch (title, tags, coverUrl…).
///
/// Các nguồn JSON được dùng:
///   - `attributes`        : title, description, status, year, updatedAt…
///   - `relationships`     : cover_art, author
///   - `attributes.tags[]` : danh sách thể loại (mỗi tag cũng chứa name map)
///   - `availableTranslatedLanguage`: danh sách ngôn ngữ có chapter.
///
/// Lưu ý:
///   - Year có thể là int hoặc string → cần parse an toàn.
///   - Tiêu đề & mô tả là map đa ngôn ngữ, ưu tiên "en".
///   - Cover art cần ghép URL thủ công.
///   - Rating hiện chưa parse từ /statistics (để mở rộng sau).
///   - availableLanguages dùng cho UI filter chapter theo ngôn ngữ.
///
/// ======================================================================
class MangaDto {
  final String id;
  final String title;
  final String? description;
  final String status;
  final List<String> tags;
  final String? coverImageUrl;
  final String? authorName;
  final int? year;

  /// Thời điểm cập nhật gần nhất (nếu MangaDex trả về)
  final DateTime? updatedAt;

  /// Điểm rating (sẽ dùng nếu fetch từ /statistics sau này)
  final double? rating;

  /// Danh sách ngôn ngữ thực sự có chapter
  final List<String> availableLanguages;

  MangaDto({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.tags,
    required this.coverImageUrl,
    required this.authorName,
    required this.year,
    required this.updatedAt,
    required this.rating,
    required this.availableLanguages,
  });

  /// ======================================================================
  /// Parse JSON từ MangaDex → MangaDto
  ///
  /// JSON mẫu:
  /// {
  ///   "id": "...",
  ///   "attributes": { "title": {...}, "description": {...}, ... },
  ///   "relationships": [
  ///       { "type": "author", "attributes": {...} },
  ///       { "type": "cover_art", "attributes": {"fileName": "..."} }
  ///   ]
  /// }
  ///
  /// Ghi chú:
  ///   - pickTitle() & pickDesc() chọn ngôn ngữ ưu tiên (en).
  ///   - coverImageUrl tự build 256px theo chuẩn MangaDex.
  ///   - availableLanguages đọc từ attributes.availableTranslatedLanguage.
  /// ======================================================================
  factory MangaDto.fromMangaDexJson(Map<String, dynamic> json) {
    final mangaId = json['id']?.toString() ?? '';

    final attrs = (json['attributes'] as Map<String, dynamic>? ?? {});
    final rels =
        (json['relationships'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    // -------- title ----------
    String pickTitle(Map<String, dynamic> titleMap) {
      final en = titleMap['en'];
      if (en is String && en.isNotEmpty) return en;
      if (titleMap.isNotEmpty) return titleMap.values.first.toString();
      return 'Unknown Title';
    }
    final title = pickTitle((attrs['title'] as Map<String, dynamic>? ?? {}));

    // -------- description ----------
    String? pickDesc(Map<String, dynamic> descMap) {
      final en = descMap['en'];
      if (en is String && en.isNotEmpty) return en;
      if (descMap.isNotEmpty) return descMap.values.first.toString();
      return null;
    }
    final description =
        pickDesc((attrs['description'] as Map<String, dynamic>? ?? {}));

    // -------- status ----------
    final status = attrs['status']?.toString() ?? 'unknown';

    // -------- year ----------
    int? year;
    if (attrs['year'] != null) {
      final y = attrs['year'];
      if (y is int) year = y;
      else if (y is String) year = int.tryParse(y);
    }

    // -------- updatedAt ----------
    DateTime? updatedAt;
    final updatedAtRaw = attrs['updatedAt'];
    if (updatedAtRaw is String && updatedAtRaw.isNotEmpty) {
      try {
        updatedAt = DateTime.parse(updatedAtRaw);
      } catch (_) {
        updatedAt = null;
      }
    }

    // -------- rating (tùy chọn tương lai) ----------
    double? rating;

    // -------- authorName ----------
    String? authorName;
    for (final rel in rels) {
      if (rel['type'] == 'author') {
        final aAttr = (rel['attributes'] as Map<String, dynamic>? ?? {});
        final name = aAttr['name']?.toString();
        if (name != null && name.isNotEmpty) {
          authorName = name;
          break;
        }
      }
    }

    // -------- cover URL ----------
    String? coverImageUrl;
    for (final rel in rels) {
      if (rel['type'] == 'cover_art') {
        final coverAttrs = (rel['attributes'] as Map<String, dynamic>? ?? {});
        final fileName = coverAttrs['fileName']?.toString();
        if (fileName != null && fileName.isNotEmpty) {
          // Dùng ảnh 256px để tối ưu grid/list
          coverImageUrl =
              'https://uploads.mangadex.org/covers/$mangaId/$fileName.256.jpg';
        }
      }
    }

    // -------- tags ----------
    final tagsList = (attrs['tags'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map((tagJson) {
      final tAttr = (tagJson['attributes'] as Map<String, dynamic>? ?? {});
      final nameMap = (tAttr['name'] as Map<String, dynamic>? ?? {});
      final en = nameMap['en'];
      if (en is String && en.isNotEmpty) return en;
      if (nameMap.isNotEmpty) return nameMap.values.first.toString();
      return 'Unknown';
    }).toList();

    // -------- availableLanguages ----------
    final availableLanguages =
        (attrs['availableTranslatedLanguage'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toSet() // loại trùng
            .toList()
          ..sort();

    return MangaDto(
      id: mangaId,
      title: title,
      description: description,
      status: status,
      tags: tagsList,
      coverImageUrl: coverImageUrl,
      authorName: authorName,
      year: year,
      updatedAt: updatedAt,
      rating: rating,
      availableLanguages: availableLanguages,
    );
  }

  /// ======================================================================
  /// Mapping DTO → Domain Entity
  ///
  /// Domain Entity (Manga):
  ///   - Bao gồm logic sạch, không phụ thuộc JSON.
  ///   - isFavorite được RepositoryImpl bổ sung khi đọc Hive.
  /// ======================================================================
  Manga toDomain({bool isFavorite = false}) {
    return Manga(
      id: MangaId(id),
      title: title,
      description: description,
      status: status,
      tags: tags,
      coverImageUrl: coverImageUrl,
      authorName: authorName,
      year: year,
      updatedAt: updatedAt,
      rating: rating,
      isFavorite: isFavorite,
      availableLanguages: availableLanguages,
    );
  }
}
