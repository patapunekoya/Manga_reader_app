// lib/infrastructure/dtos/manga_dto.dart
import '../../domain/entities/manga.dart';
import '../../domain/value_objects/manga_id.dart';

/// MangaDto: trung gian giữa JSON của MangaDex và Manga entity.
/// Chứa logic parse JSON và relationships.
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

  /// Điểm rating (nếu sau này lấy từ statistics)
  final double? rating;

  /// NEW: danh sách ngôn ngữ thực sự có chapter
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
    required this.availableLanguages, // NEW
  });

  /// parse từ json /manga item (có relationships)
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
      if (y is int) {
        year = y;
      } else if (y is String) {
        year = int.tryParse(y);
      }
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

    // -------- rating ----------
    double? rating;

    // -------- authorName từ relationships ----------
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

    // -------- cover url từ relationships ----------
    String? coverImageUrl;
    for (final rel in rels) {
      if (rel['type'] == 'cover_art') {
        final coverAttrs = (rel['attributes'] as Map<String, dynamic>? ?? {});
        final fileName = coverAttrs['fileName']?.toString();
        if (fileName != null && fileName.isNotEmpty) {
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

    // -------- availableLanguages (tự động filter UI) ----------
    final availableLanguages =
        (attrs['availableTranslatedLanguage'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toSet()
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
      availableLanguages: availableLanguages, // NEW
    );
  }

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
      availableLanguages: availableLanguages, // NEW
    );
  }
}
