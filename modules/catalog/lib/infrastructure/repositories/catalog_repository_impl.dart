// modules/catalog/lib/infrastructure/repositories/catalog_repository_impl.dart

import 'package:catalog/domain/repositories/catalog_repository.dart';
import 'package:catalog/domain/value_objects/manga_id.dart';
import 'package:catalog/domain/value_objects/language_code.dart';
import 'package:catalog/domain/value_objects/chapter_id.dart';
import 'package:catalog/domain/entities/manga.dart';
import 'package:catalog/domain/entities/chapter.dart';

import '../datasources/catalog_remote_ds.dart';
import '../datasources/catalog_local_ds.dart';

/// ======================================================================
/// Repository Implementation: CatalogRepositoryImpl
///
/// Vai trò:
///   - Nằm ở tầng Infrastructure. Triển khai interface Domain `CatalogRepository`.
///   - Điều phối giữa RemoteDataSource, LocalDataSource và mapping DTO/JSON
///     → Domain Entities (Manga, Chapter).
///   - Không để UI/BLoC biết JSON hay Dio; UI chỉ nhận Entity sạch.
///
/// Ghi chú tổng quát:
///   - `searchManga` dùng remote `/manga` (kèm cover_art) → map nhanh item search.
///   - `getMangaDetail` dùng `/manga/{id}?includes[]=author,cover_art`.
///   - `listChapters` dùng `/manga/{id}/feed` với chiến lược đa ngôn ngữ
///     (fallback priority) rồi chọn bản “tốt nhất” theo ngôn ngữ ưu tiên.
///
/// Mappers:
///   - `_mapMangaSearchItem` : map item search (nhẹ, tối ưu danh sách).
///   - `_mapMangaDetail`     : map detail (đầy đủ hơn, có author).
///   - `_mapChapter`         : map 1 record chapter từ feed → Chapter entity.
///
/// Lưu ý:
///   - `availableLanguages` lấy từ attributes.availableTranslatedLanguage
///     để UI lọc chapter theo ngôn ngữ thực sự có.
///   - Rating hiện để 0.0 (điểm giữ chỗ), có thể mở rộng từ /statistics sau.
/// ======================================================================
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remote;
  final CatalogLocalDataSource _local;

  CatalogRepositoryImpl(this._remote, this._local);

  // ----------------------------------------------------------------------
  // SEARCH
  // ----------------------------------------------------------------------
  @override
  Future<List<Manga>> searchManga({
    required String query,
    String? genre,
    required int offset,
    required int limit,
  }) async {
    // Gọi remote để lấy JSON raw items (đã includes cover_art)
    final raws = await _remote.searchMangaRaw(
      query: query,
      genre: genre,
      offset: offset,
      limit: limit,
    );
    // Map từng raw item → Manga entity (phiên bản rút gọn phục vụ list)
    return raws.map(_mapMangaSearchItem).toList();
  }

  // ----------------------------------------------------------------------
  // DETAIL
  // ----------------------------------------------------------------------
  @override
  Future<Manga> getMangaDetail({required MangaId mangaId}) async {
    // Gọi remote lấy 1 object data có includes author, cover_art
    final raw = await _remote.getMangaDetailRaw(mangaId: mangaId.value);
    if (raw == null) {
      throw StateError('Manga not found: ${mangaId.value}');
    }
    // Map JSON → Manga entity đầy đủ
    return _mapMangaDetail(raw);
  }

  // ----------------------------------------------------------------------
  // CHAPTER FEED (đa ngôn ngữ + fallback ưu tiên)
  // ----------------------------------------------------------------------
  @override
  Future<List<Chapter>> listChapters({
    required MangaId mangaId,
    required bool ascending,
    LanguageCode? languageFilter, // <<< nullable
    required int offset,
    required int limit,
  }) async {
    // Danh sách ngôn ngữ fallback theo mức phổ biến (có thể tinh chỉnh)
    final fallbacks = <String>[
      'vi', 'en', 'id', 'es', 'fr', 'pt-br', 'ru', 'de', 'it', 'tr', 'pt'
    ];

    // Nếu user chọn cụ thể → đưa ngôn ngữ đó lên đầu ưu tiên
    // Set → toList để vừa loại trùng vừa giữ ưu tiên
    final langs = <String>{
      if (languageFilter != null) languageFilter.value.toLowerCase(),
      ...fallbacks,
    }.toList();

    // Gọi feed đa ngôn ngữ, chọn bản tốt nhất theo ưu tiên
    final raws = await _remote.listChaptersRawWithFallback(
      mangaId: mangaId.value,
      ascending: ascending,
      languages: langs,
      offset: offset,
      limit: limit,
    );

    // Map JSON → Chapter entity, inject parent MangaId
    return raws.map((r) => _mapChapter(r, parentMangaId: mangaId)).toList();
  }

  // ===================== MAPPERS =====================

  /// Map 1 item search (nhẹ, không cần đầy đủ như detail) → Manga
  /// - Chọn title ưu tiên en → vi → ja → ja-ro → firstOrNull
  /// - Ghép cover URL nếu có fileName
  /// - Parse updatedAt (fallback epoch nếu null)
  /// - availableLanguages: để UI filter chapter theo ngôn ngữ thực sự có
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

    final availableLanguages =
        ((attrs['availableTranslatedLanguage'] as List?) ?? const [])
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return Manga(
      id: MangaId(id),
      title: title,
      description: (attrs['description'] is Map)
          ? ((attrs['description']['en'] ??
                  attrs['description']['vi'] ??
                  (attrs['description'] as Map).values.firstOrNull)
              ?.toString())
          : null,
      authorName: null, // Search item không luôn có author trong relationships
      coverImageUrl: (coverFile != null) ? buildCoverUrl(id, coverFile!) : null,
      tags: const [], // Nếu cần tags cho search có thể mở rộng parsing
      year: (attrs['year'] is int) ? attrs['year'] as int : null,
      status: (attrs['status']?.toString() ?? 'ongoing'),
      isFavorite: false, // Repo khác (Library) sẽ gán khi cần
      updatedAt: updatedAt,
      rating: rating,
      availableLanguages: availableLanguages, // <<< required
    );
  }

  /// Map chi tiết manga (đầy đủ hơn) → Manga
  /// - Lấy authorName từ relationships[type=author]
  /// - Ghép cover URL từ relationships[type=cover_art]
  /// - Mô tả đa ngôn ngữ: ưu tiên en → vi → firstOrNull
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

    final availableLanguages =
        ((attrs['availableTranslatedLanguage'] as List?) ?? const [])
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

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
      availableLanguages: availableLanguages, // <<< required
    );
  }

  /// Map 1 record chapter feed → Chapter
  /// - Chọn `updatedAt` ưu tiên: publishAt → readableAt → updatedAt → createdAt
  ///   để có mốc thời gian hợp lý khi hiển thị/sort.
  /// - title có thể rỗng; nếu rỗng → để null cho UI hiển thị fallback.
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

/// Tiện ích nho nhỏ: lấy phần tử đầu nếu có, null nếu rỗng.
/// Hỗ trợ chọn title/description khi map đa ngôn ngữ.
extension _FirstOrNull on Iterable {
  dynamic get firstOrNull => isEmpty ? null : first;
}
