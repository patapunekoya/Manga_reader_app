// modules/catalog/lib/infrastructure/datasources/catalog_remote_ds.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'mangadex_tags.dart';

/// ======================================================================
/// DataSource (Remote): CatalogRemoteDataSource
///
/// Mục đích:
///   - Là lớp làm việc trực tiếp với API MangaDex qua Dio.
///   - Chỉ trả về JSON raw (Map/List) để RepositoryImpl chịu trách nhiệm mapping
///     sang Entity (Manga, Chapter, …).
///
/// Endpoints chính dùng:
///   - /manga                                → search
///   - /manga/{id}?includes[]=author,cover_art → detail
///   - /manga/{id}/feed                      → danh sách chapter (ổn định hơn /chapter?manga=)
///
/// Quy ước:
///   - Không throw custom domain error ở đây; để nguyên Dio error cho layer trên xử lý.
///   - Luôn phòng thủ kiểu dữ liệu trước khi cast (Map/List).
///   - Có helper `_getWithRetry` để retry nhẹ với lỗi mạng tạm thời.
///   - Tag filter: map tên thể loại → tag id qua `kMangaDexTagIds`.
///
/// Lưu ý sorting chapter feed:
///   - Ưu tiên `readableAt` (thời điểm đọc được), fallback theo `chapter` numeric.
///   - Có 2 biến thể:
///       • listChaptersRawWithFallback: nhiều ngôn ngữ, chọn “bản tốt nhất” theo thứ tự ưu tiên.
///       • listChaptersRaw: 1 ngôn ngữ hoặc tất cả.
/// ======================================================================
class CatalogRemoteDataSource {
  final Dio _dio;
  CatalogRemoteDataSource(this._dio);

  // --------------------------- SEARCH ---------------------------
  /// Tìm kiếm manga.
  /// Params:
  ///   - query : chuỗi tìm kiếm (có thể rỗng)
  ///   - genre : tên thể loại (nullable). Sẽ map sang tagId nếu có.
  ///   - offset/limit: phân trang.
  /// Trả về:
  ///   - Danh sách item JSON (dynamic) từ key `data` của MangaDex.
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
  /// Lấy chi tiết manga bao gồm author và cover_art qua includes[].
  /// Trả về:
  ///   - Map JSON của 1 manga (`data`), hoặc null nếu không đúng cấu trúc.
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
  /// Lấy chapter theo nhiều ngôn ngữ ưu tiên (ví dụ: ['en','vi','id']).
  /// Chiến lược:
  ///   - Gọi feed 1 lần với translatedLanguage[]=... (đa ngôn ngữ).
  ///   - Nhóm theo `chapterNumber` (attributes.chapter).
  ///   - Với mỗi nhóm, chọn 1 bản “tốt nhất” dựa theo thứ tự ưu tiên ngôn ngữ.
  ///   - Sort kết quả cuối theo readableAt (hoặc chapter number nếu thiếu).
  ///
  /// Ghi chú:
  ///   - `contentRating[]` giữ 3 mức để không bị thiếu kết quả phổ biến.
  ///   - `includeFuturePublishAt=0` và `includeEmptyPages=0` để lọc noise.
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

    // Sắp xếp kết quả cuối
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
        // Fallback theo chapter number dạng số nếu thiếu readableAt
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
  /// Lấy feed theo 1 ngôn ngữ hoặc tất cả nếu [language] == null.
  /// - Nếu language != null → translatedLanguage[]=<language>
  /// - Nếu null → không truyền translatedLanguage → trả tất cả
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
  /// Thứ tự ưu tiên ngôn ngữ: càng nhỏ càng ưu tiên.
  int _langPriority(String lang, List<String> pref) {
    final idx = pref.indexOf(lang);
    return idx >= 0 ? idx : 999;
  }

  /// Helper retry đơn giản cho GET:
  /// - [maxRetry] số lần thử lại (mặc định 2).
  /// - [delay] thời gian chờ giữa các lần thử.
  /// - Throw lỗi cuối cùng nếu hết retry.
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

/// ======================================================================
/// Utility: buildCoverUrl
/// - Dựng URL ảnh cover theo kích thước:
///     • size = 256 hoặc 512 → thêm đuôi .{size}.jpg
///     • size khác          → trả file gốc (không thêm đuôi)
/// - Thường dùng để hiện thumbnail ở list/grid.
/// ======================================================================
String buildCoverUrl(String mangaId, String fileName, {int size = 256}) {
  if (size == 256 || size == 512) {
    return 'https://uploads.mangadex.org/covers/$mangaId/$fileName.$size.jpg';
  }
  return 'https://uploads.mangadex.org/covers/$mangaId/$fileName';
}
