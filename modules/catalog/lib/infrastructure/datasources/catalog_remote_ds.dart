// modules/catalog/lib/infrastructure/datasources/catalog_remote_ds.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'mangadex_tags.dart';

/// CatalogRemoteDataSource:
/// - /manga: search
/// - /manga/{id}?includes[]=author,cover_art: detail
/// - /manga/{id}/feed: danh sách chapter (ổn định hơn /chapter?manga=)
///
/// Trả JSON raw, Repository lo mapping.
class CatalogRemoteDataSource {
  final Dio _dio;
  CatalogRemoteDataSource(this._dio);

  // --------------------------- SEARCH ---------------------------
  Future<List<dynamic>> searchMangaRaw({
    required String query,
    String? genre,
    required int offset,
    required int limit,
  }) async {
    final params = <String, dynamic>{
      'title': query.isNotEmpty ? query : null,
      'limit': limit,
      'offset': offset,
      'includes[]': 'cover_art',
      'order[relevance]': 'desc',
    }..removeWhere((k, v) => v == null);

    if (genre != null && genre.trim().isNotEmpty) {
      final tagId = kMangaDexTagIds[genre.toLowerCase()];
      if (tagId != null) {
        params['includedTags[]'] = tagId;
        params['includedTagsMode'] = 'AND';
      }
    }

    final resp = await _dio.get('/manga', queryParameters: params);
    final data = resp.data;
    if (data is Map && data['data'] is List) {
      return List<dynamic>.from(data['data'] as List);
    }
    return const <dynamic>[];
  }

  // --------------------------- DETAIL ---------------------------
  Future<Map<String, dynamic>?> getMangaDetailRaw({
    required String mangaId,
  }) async {
    final response = await _dio.get(
      '/manga/$mangaId',
      queryParameters: {
        'includes[]': ['author', 'cover_art'],
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }
    return null;
  }

  // --------------------------- FEED: đa ngôn ngữ + fallback ---------------------------
  /// Lấy chapter theo nhiều ngôn ngữ ưu tiên (ví dụ: ['en','vi','id']),
  /// sau đó lọc giữ lại 1 ngôn ngữ tốt nhất cho mỗi chapterNumber theo thứ tự ưu tiên.
  Future<List<Map<String, dynamic>>> listChaptersRawWithFallback({
    required String mangaId,
    required bool ascending,
    required List<String> languages, // ưu tiên theo thứ tự phần tử
    required int offset,
    required int limit,
  }) async {
    final orderVal = ascending ? 'asc' : 'desc';
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'order[readableAt]': orderVal,
      'order[chapter]': orderVal,
      'translatedLanguage[]': languages,
      'contentRating[]': ['safe', 'suggestive', 'erotica'],
      'includeFuturePublishAt': 0,
      'includeEmptyPages': 0,
    };

    final res = await _getWithRetry(
      () => _dio.get('/manga/$mangaId/feed', queryParameters: params),
    );

    final data = res?.data;
    if (data is! Map<String, dynamic> || data['data'] is! List) {
      return const <Map<String, dynamic>>[];
    }
    final rawList = List<Map<String, dynamic>>.from(data['data'] as List);

    // Giữ 1 bản tốt nhất cho mỗi chapterNumber theo ưu tiên ngôn ngữ
    final bestByChapterNo = <String, Map<String, dynamic>>{};
    for (final m in rawList) {
      final attrs = (m['attributes'] as Map?) ?? const {};
      final chapNo = (attrs['chapter'] ?? '').toString();
      final lang = (attrs['translatedLanguage'] ?? '').toString();
      final key = (chapNo.isNotEmpty) ? chapNo : (m['id']?.toString() ?? '');

      if (!bestByChapterNo.containsKey(key)) {
        bestByChapterNo[key] = m;
        continue;
      }
      final current = bestByChapterNo[key]!;
      final curLang =
          (((current['attributes'] as Map?) ?? const {})['translatedLanguage'] ?? '')
              .toString();

      final curPri = _langPriority(curLang, languages);
      final newPri = _langPriority(lang, languages);
      if (newPri < curPri) bestByChapterNo[key] = m;
    }

    final result = bestByChapterNo.values.toList();
    result.sort((a, b) {
      final aAttrs = (a['attributes'] as Map?) ?? const {};
      final bAttrs = (b['attributes'] as Map?) ?? const {};
      final aReadable = DateTime.tryParse(aAttrs['readableAt']?.toString() ?? '');
      final bReadable = DateTime.tryParse(bAttrs['readableAt']?.toString() ?? '');
      int cmp;
      if (aReadable != null && bReadable != null) {
        cmp = aReadable.compareTo(bReadable);
      } else {
        double n(String? s) => double.tryParse((s ?? '').toString()) ?? double.nan;
        final aNum = n(aAttrs['chapter']);
        final bNum = n(bAttrs['chapter']);
        if (aNum.isNaN && bNum.isNaN) cmp = 0;
        else if (aNum.isNaN) cmp = 1;
        else if (bNum.isNaN) cmp = -1;
        else cmp = aNum.compareTo(bNum);
      }
      return ascending ? cmp : -cmp;
    });

    return result;
  }

  // --------------------------- FEED: 1 ngôn ngữ hoặc ALL ---------------------------
  /// Nếu [language] == null => lấy tất cả ngôn ngữ. Nếu không, chỉ 1 ngôn ngữ.
  Future<List<Map<String, dynamic>>> listChaptersRaw({
    required String mangaId,
    required bool ascending,
    String? language,
    required int offset,
    required int limit,
  }) async {
    final orderVal = ascending ? 'asc' : 'desc';
    final qp = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'order[readableAt]': orderVal,
      'order[chapter]': orderVal,
      'contentRating[]': ['safe', 'suggestive', 'erotica'],
      'includeFuturePublishAt': 0,
      'includeEmptyPages': 0,
    };
    if (language != null && language.isNotEmpty) {
      qp['translatedLanguage[]'] = [language];
    }

    final res = await _getWithRetry(
      () => _dio.get('/manga/$mangaId/feed', queryParameters: qp),
    );

    final data = res?.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return const <Map<String, dynamic>>[];
  }

  // --------------------------- Helpers ---------------------------
  int _langPriority(String lang, List<String> pref) {
    final idx = pref.indexOf(lang);
    return idx >= 0 ? idx : 999;
  }

  Future<Response<dynamic>?> _getWithRetry(
    Future<Response<dynamic>> Function() call, {
    int maxRetry = 2,
    Duration delay = const Duration(milliseconds: 350),
  }) async {
    Object? lastError;
    for (int i = 0; i <= maxRetry; i++) {
      try {
        return await call();
      } catch (e) {
        lastError = e;
        if (i == maxRetry) {
          throw e;
        }
        await Future.delayed(delay);
      }
    }
    if (lastError != null) {
      throw lastError!;
    }
    return null;
  }
}

// Build URL cover
String buildCoverUrl(String mangaId, String fileName, {int size = 256}) {
  if (size == 256 || size == 512) {
    return 'https://uploads.mangadex.org/covers/$mangaId/$fileName.$size.jpg';
  }
  return 'https://uploads.mangadex.org/covers/$mangaId/$fileName';
}
