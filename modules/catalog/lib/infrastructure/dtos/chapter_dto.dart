// lib/infrastructure/dtos/chapter_dto.dart
import '../../domain/entities/chapter.dart';
import '../../domain/value_objects/chapter_id.dart';
import '../../domain/value_objects/manga_id.dart';

class ChapterDto {
  final String id;
  final String mangaId;
  final String chapterNumber;
  final String? title;
  final String? language;
  final DateTime? updatedAt;

  ChapterDto({
    required this.id,
    required this.mangaId,
    required this.chapterNumber,
    required this.title,
    required this.language,
    required this.updatedAt,
  });

  factory ChapterDto.fromMangaDexJson(Map<String, dynamic> json) {
    final chapId = json['id']?.toString() ?? '';
    final attrs =
        (json['attributes'] as Map<String, dynamic>? ?? {});

    final chapterNum = attrs['chapter']?.toString() ?? '';
    final chapterTitle = attrs['title']?.toString();
    final lang = attrs['translatedLanguage']?.toString();

    DateTime? upAt;
    final updatedAtRaw = attrs['updatedAt']?.toString();
    if (updatedAtRaw != null && updatedAtRaw.isNotEmpty) {
      upAt = DateTime.tryParse(updatedAtRaw);
    }

    // Lưu ý: response /chapter?manga={id} không chắc chắn
    // lồng mangaId trực tiếp, nhưng ta đã biết mangaId khi gọi,
    // repo_impl sẽ inject mangaId vào toDomain() chứ không rely ở đây.

    return ChapterDto(
      id: chapId,
      mangaId: '', // sẽ set sau
      chapterNumber: chapterNum,
      title: chapterTitle,
      language: lang,
      updatedAt: upAt,
    );
  }

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
