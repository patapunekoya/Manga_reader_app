// lib/infrastructure/dtos/manga_dto.dart
import '../../domain/entities/manga.dart';
import '../../domain/value_objects/manga_id.dart';

/// MangaDto: trung gian giữa JSON của MangaDex và Manga entity.
/// Chứa logic parse JSON khá dơ, nên để ở tầng infra.

class MangaDto {
  final String id;
  final String title;
  final String? description;
  final String status;
  final List<String> tags;
  final String? coverImageUrl;
  final String? authorName;
  final int? year;
  final double? rating;

  MangaDto({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.tags,
    required this.coverImageUrl,
    required this.authorName,
    required this.year,
    required this.rating,
  });

  /// parse từ json /manga item (có relationships)
  factory MangaDto.fromMangaDexJson(Map<String, dynamic> json) {
    final mangaId = json['id']?.toString() ?? '';

    final attrs =
        (json['attributes'] as Map<String, dynamic>? ?? {});
    final rels = (json['relationships'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    // title
    String pickTitle(Map<String, dynamic> titleMap) {
      // ưu tiên en
      if (titleMap['en'] is String &&
          (titleMap['en'] as String).isNotEmpty) {
        return titleMap['en'] as String;
      }
      if (titleMap.isNotEmpty) {
        return titleMap.values.first.toString();
      }
      return 'Unknown Title';
    }

    final title = pickTitle(
      (attrs['title'] as Map<String, dynamic>? ?? {}),
    );

    // description (take 'en' or first)
    String? pickDesc(Map<String, dynamic> descMap) {
      if (descMap['en'] is String &&
          (descMap['en'] as String).isNotEmpty) {
        return descMap['en'] as String;
      }
      if (descMap.isNotEmpty) {
        return descMap.values.first.toString();
      }
      return null;
    }

    final description = pickDesc(
      (attrs['description'] as Map<String, dynamic>? ?? {}),
    );

    // status
    final status = attrs['status']?.toString() ?? 'unknown';

    // publication year if exists
    int? year;
    if (attrs['year'] != null) {
      final y = attrs['year'];
      if (y is int) {
        year = y;
      } else if (y is String) {
        year = int.tryParse(y);
      }
    }

    // rating / score (MangaDex có bayesianRating trong statistics,
    // nhưng có thể không luôn có sẵn ở đây. Tạm null.)
    double? rating;

    // authorName from relationships[type=='author']
    String? authorName;
    for (final rel in rels) {
      if (rel['type'] == 'author') {
        final aAttr =
            (rel['attributes'] as Map<String, dynamic>? ?? {});
        final name = aAttr['name']?.toString();
        if (name != null && name.isNotEmpty) {
          authorName = name;
          break;
        }
      }
    }

    // cover url build từ relationships[type=='cover_art']
    String? coverImageUrl;
    for (final rel in rels) {
      if (rel['type'] == 'cover_art') {
        final coverAttrs =
            (rel['attributes'] as Map<String, dynamic>? ?? {});
        final fileName = coverAttrs['fileName']?.toString();
        if (fileName != null && fileName.isNotEmpty) {
          coverImageUrl =
              'https://uploads.mangadex.org/covers/$mangaId/$fileName.256.jpg';
        }
      }
    }

    // tags
    final tagsList = (attrs['tags'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map((tagJson) {
      final tAttr = (tagJson['attributes']
          as Map<String, dynamic>? ??
          {});
      final nameMap = (tAttr['name']
          as Map<String, dynamic>? ??
          {});
      if (nameMap['en'] is String &&
          (nameMap['en'] as String).isNotEmpty) {
        return nameMap['en'] as String;
      }
      if (nameMap.isNotEmpty) {
        return nameMap.values.first.toString();
      }
      return 'Unknown';
    }).toList();

    return MangaDto(
      id: mangaId,
      title: title,
      description: description,
      status: status,
      tags: tagsList,
      coverImageUrl: coverImageUrl,
      authorName: authorName,
      year: year,
      rating: rating,
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
      rating: rating,
      isFavorite: isFavorite,
    );
  }
}
