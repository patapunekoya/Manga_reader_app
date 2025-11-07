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

  // ---------------------------
  // SEARCH
  // ---------------------------
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

  // ---------------------------
  // DETAIL
  // ---------------------------
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

  // ---------------------------
  // CHAPTER FEED (đa ngôn ngữ + fallback)
  // ---------------------------
  /// Lấy chapter theo nhiều ngôn ngữ ưu tiên (ví dụ: ['en','vi','id']),
  /// sau đó **lọc giữ lại 1 ngôn ngữ tốt nhất cho mỗi chapterNumber** theo thứ tự ưu tiên.
  /// - ascending = true: cũ → mới
  /// - ascending = false: mới → cũ
  Future<List<Map<String, dynamic>>> listChaptersRawWithFallback({
    required String mangaId,
    required bool ascending,
    required List<String> languages, // ưu tiên theo thứ tự phần tử
    required int offset,
    required int limit,
  }) async {
    // Gọi 1 lần feed với toàn bộ languages (MangaDex cho phép lặp lại translatedLanguage[])
    final orderVal = ascending ? 'asc' : 'desc';

    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      // Sắp xếp chính theo thời điểm đọc được; tie-break theo chapter
      'order[readableAt]': orderVal,
      'order[chapter]': orderVal,

      // Multi-lang ưu tiên: truyền tất cả
      'translatedLanguage[]': languages,

      // Đừng lọc quá chặt để không “mất chap”
      'contentRating[]': ['safe', 'suggestive', 'erotica'],

      // Ổn định feed
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

    // Post-filter: Với cùng chapterNumber, chỉ giữ bản dịch theo ngôn ngữ ưu tiên cao nhất.
    final bestByChapterNo = <String, Map<String, dynamic>>{};
    for (final m in rawList) {
      final attrs = (m['attributes'] as Map?) ?? const {};
      final chapNo = (attrs['chapter'] ?? '').toString(); // có thể null/''/float
      final lang = (attrs['translatedLanguage'] ?? '').toString();

      // Khóa gộp theo chapterNumber; nếu trống, dùng id để tránh mất dữ liệu
      final key = (chapNo.isNotEmpty) ? chapNo : (m['id']?.toString() ?? '');

      if (!bestByChapterNo.containsKey(key)) {
        bestByChapterNo[key] = m;
        continue;
      }

      // Đang có bản A, so với B -> chọn ngôn ngữ có priority cao hơn
      final current = bestByChapterNo[key]!;
      final curLang =
          (((current['attributes'] as Map?) ?? const {})['translatedLanguage'] ??
                  '')
              .toString();

      final curPri = _langPriority(curLang, languages);
      final newPri = _langPriority(lang, languages);

      if (newPri < curPri) {
        bestByChapterNo[key] = m;
      }
    }

    // Trả về list theo thứ tự mong muốn
    final result = bestByChapterNo.values.toList();

    // Đảm bảo ổn định thứ tự (đôi khi map.values không giữ thứ tự mong muốn)
    result.sort((a, b) {
      final aAttrs = (a['attributes'] as Map?) ?? const {};
      final bAttrs = (b['attributes'] as Map?) ?? const {};
      final aReadable = DateTime.tryParse(aAttrs['readableAt']?.toString() ?? '');
      final bReadable = DateTime.tryParse(bAttrs['readableAt']?.toString() ?? '');
      int cmp;
      if (aReadable != null && bReadable != null) {
        cmp = aReadable.compareTo(bReadable);
      } else {
        // fallback: so sánh chapterNumber dạng số nếu có
        double tryParseNum(String? s) => double.tryParse((s ?? '').toString()) ?? double.nan;
        final aNum = tryParseNum(aAttrs['chapter']);
        final bNum = tryParseNum(bAttrs['chapter']);
        if (aNum.isNaN && bNum.isNaN) {
          cmp = 0;
        } else if (aNum.isNaN) {
          cmp = 1;
        } else if (bNum.isNaN) {
          cmp = -1;
        } else {
          cmp = aNum.compareTo(bNum);
        }
      }
      return ascending ? cmp : -cmp;
    });

    return result;
  }

  // ---------------------------
  // Helpers
  // ---------------------------

  int _langPriority(String lang, List<String> pref) {
    final idx = pref.indexOf(lang);
    return idx >= 0 ? idx : 999; // lang không có trong ưu tiên -> thấp nhất
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
          // hết retry -> ném lỗi ra cho caller
          throw e;
        }
        await Future.delayed(delay);
      }
    }
    // không tới đây được, nhưng để hàm hợp lệ
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
