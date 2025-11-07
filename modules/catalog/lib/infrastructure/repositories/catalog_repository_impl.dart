// modules/catalog/lib/infrastructure/repositories/catalog_repository_impl.dart
import 'package:catalog/domain/repositories/catalog_repository.dart';
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';
import 'package:catalog/domain/value_objects/chapter_id.dart';
import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/entities/chapter.dart';

import '../datasources/catalog_remote_ds.dart';
import '../datasources/catalog_local_ds.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remote;
  final CatalogLocalDataSource _local;

  CatalogRepositoryImpl(this._remote, this._local);

  @override
  Future<List<Manga>> searchManga({
    required String query,
    String? genre,
    required int offset,
    required int limit,
  }) async {
    final raws = await _remote.searchMangaRaw(
      query: query,
      genre: genre,
      offset: offset,
      limit: limit,
    );
    return raws.map(_mapMangaSearchItem).toList();
  }

  @override
  Future<Manga> getMangaDetail({required MangaId mangaId}) async {
    final raw = await _remote.getMangaDetailRaw(mangaId: mangaId.value);
    if (raw == null) {
      throw StateError('Manga not found: ${mangaId.value}');
    }
    return _mapMangaDetail(raw);
  }

  @override
  Future<List<Chapter>> listChapters({
    required MangaId mangaId,
    required bool ascending,
    required LanguageCode languageFilter,
    required int offset,
    required int limit,
  }) async {
    final fallbacks = <String>['vi', 'en', 'id', 'es', 'fr', 'pt-br', 'ru', 'de', 'it', 'tr', 'pt'];
    final langs = <String>{
      languageFilter.value.toLowerCase(),
      ...fallbacks,
    }.toList();

    final raws = await _remote.listChaptersRawWithFallback(
      mangaId: mangaId.value,
      ascending: ascending,
      languages: langs,
      offset: offset,
      limit: limit,
    );

    return raws.map((r) => _mapChapter(r, parentMangaId: mangaId)).toList();
  }

  Manga _mapMangaSearchItem(dynamic raw) {
    final map = raw as Map<String, dynamic>;
    final id = map['id']?.toString() ?? '';
    final attrs = (map['attributes'] as Map?) ?? const {};

    final titleMap = (attrs['title'] as Map?) ?? const {};
    final title = (titleMap['en'] ??
            titleMap['vi'] ??
            titleMap['ja'] ??
            titleMap['ja-ro'] ??
            titleMap.values.firstOrNull)
        ?.toString() ??
        'Untitled';

    String? coverFile;
    for (final rel in (map['relationships'] as List? ?? const [])) {
      if ((rel['type']?.toString() ?? '') == 'cover_art') {
        final fa = (rel['attributes'] as Map?) ?? const {};
        coverFile = fa['fileName']?.toString();
        break;
      }
    }

    final updatedAtIso = attrs['updatedAt']?.toString();
    final updatedAt = DateTime.tryParse(updatedAtIso ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    const double rating = 0.0;

    return Manga(
      id: MangaId(id),
      title: title,
      description: (attrs['description'] is Map)
          ? ((attrs['description']['en'] ??
                  attrs['description']['vi'] ??
                  (attrs['description'] as Map).values.firstOrNull)
              ?.toString())
          : null,
      authorName: null,
      coverImageUrl: (coverFile != null) ? buildCoverUrl(id, coverFile!) : null,
      tags: const [],
      year: (attrs['year'] is int) ? attrs['year'] as int : null,
      status: (attrs['status']?.toString() ?? 'ongoing'),
      isFavorite: false,
      updatedAt: updatedAt,
      rating: rating,
    );
  }

  Manga _mapMangaDetail(Map<String, dynamic> raw) {
    final id = raw['id']?.toString() ?? '';
    final attrs = (raw['attributes'] as Map?) ?? const {};

    final titleMap = (attrs['title'] as Map?) ?? const {};
    final title = (titleMap['en'] ??
            titleMap['vi'] ??
            titleMap['ja'] ??
            titleMap['ja-ro'] ??
            titleMap.values.firstOrNull)
        ?.toString() ??
        'Untitled';

    String? coverFile;
    String? authorName;
    for (final rel in (raw['relationships'] as List? ?? const [])) {
      final type = rel['type']?.toString() ?? '';
      if (type == 'cover_art') {
        final fa = (rel['attributes'] as Map?) ?? const {};
        coverFile = fa['fileName']?.toString();
      } else if (type == 'author') {
        final fa = (rel['attributes'] as Map?) ?? const {};
        authorName = fa['name']?.toString();
      }
    }

    final desc = (attrs['description'] is Map)
        ? ((attrs['description']['en'] ??
                attrs['description']['vi'] ??
                (attrs['description'] as Map).values.firstOrNull)
            ?.toString())
        : null;

    final updatedAtIso = attrs['updatedAt']?.toString();
    final updatedAt = DateTime.tryParse(updatedAtIso ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    const double rating = 0.0;

    return Manga(
      id: MangaId(id),
      title: title,
      description: desc,
      authorName: authorName,
      coverImageUrl: (coverFile != null) ? buildCoverUrl(id, coverFile!) : null,
      tags: const [],
      year: (attrs['year'] is int) ? attrs['year'] as int : null,
      status: (attrs['status']?.toString() ?? 'ongoing'),
      isFavorite: false,
      updatedAt: updatedAt,
      rating: rating,
    );
  }

  // >>> UPDATED: truyền updatedAt cho Chapter
  Chapter _mapChapter(
    Map<String, dynamic> raw, {
    required MangaId parentMangaId,
  }) {
    final id = raw['id']?.toString() ?? '';
    final attrs = (raw['attributes'] as Map?) ?? const {};

    final chapNo = (attrs['chapter'] ?? '').toString();
    final title = (attrs['title']?.toString().trim().isNotEmpty ?? false)
        ? attrs['title']?.toString()
        : null;
    final lang = (attrs['translatedLanguage']?.toString());

    // Ưu tiên publishAt -> readableAt -> updatedAt -> createdAt
    final publishAtIso = attrs['publishAt']?.toString();
    final readableAtIso = attrs['readableAt']?.toString();
    final updatedAtIso = attrs['updatedAt']?.toString();
    final createdAtIso = attrs['createdAt']?.toString();

    final updatedAt =
        DateTime.tryParse(publishAtIso ?? '') ??
        DateTime.tryParse(readableAtIso ?? '') ??
        DateTime.tryParse(updatedAtIso ?? '') ??
        DateTime.tryParse(createdAtIso ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return Chapter(
      id: ChapterId(id),
      mangaId: parentMangaId,
      chapterNumber: chapNo,
      title: title,
      language: lang,
      updatedAt: updatedAt,
    );
  }
}

extension _FirstOrNull on Iterable {
  dynamic get firstOrNull => isEmpty ? null : first;
}
