// lib/infrastructure/datasources/catalog_remote_ds.dart
import 'package:dio/dio.dart';
import 'mangadex_tags.dart';

/// CatalogRemoteDataSource:
/// Nhiệm vụ:
/// - gọi /manga để search
/// - gọi /manga/{id}?includes[]=author,cover_art để lấy chi tiết
/// - gọi /chapter?manga={id} ... để lấy danh sách chapter
///
/// Trả về raw Map/List JSON, chưa map sang entity domain.
/// RepositoryImpl sẽ lo convert.

class CatalogRemoteDataSource {
  final Dio _dio;

  CatalogRemoteDataSource(this._dio);

  Future<List<dynamic>> searchMangaRaw({
    required String query,
    String? genre,                  // <— thêm
    required int offset,
    required int limit,
  }) async {
    // Chuẩn bị query params cho MangaDex /manga
    final params = <String, dynamic>{
      'title'  : query.isNotEmpty ? query : null, // MangaDex ưu tiên 'title'
      'limit'  : limit,
      'offset' : offset,
      'includes[]': 'cover_art',
      'order[relevance]' : 'desc',                // tìm kiếm tương đối
      // Nếu muốn lọc ngôn ngữ: 'availableTranslatedLanguage[]': 'en'
      // hoặc 'vi' tùy dataset. Ông có thể thêm nếu cần.
    }..removeWhere((k, v) => v == null);

    // Map genre (từ dropdown) sang tag UUID nếu có
    if (genre != null && genre.trim().isNotEmpty) {
      final tagId = kMangaDexTagIds[genre.toLowerCase()];
      if (tagId != null) {
        // MangaDex cho phép nhiều tags: includedTags[]=<uuid>&includedTags[]=<uuid2>
        // Ở đây mình chỉ 1 cái từ dropdown
        params['includedTags[]'] = tagId;
        params['includedTagsMode'] = 'AND';
      }
    }

    final resp = await _dio.get('/manga', queryParameters: params);

    // MangaDex trả { result, response, data: [...] }
    final data = resp.data;
    if (data is Map && data['data'] is List) {
      return List<dynamic>.from(data['data'] as List);
    }
    return <dynamic>[];
  }

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

  Future<List<Map<String, dynamic>>> listChaptersRaw({
    required String mangaId,
    required bool ascending,
    required String language,
    required int offset,
    required int limit,
  }) async {
    // MangaDex chapters:
    // GET /chapter?manga={id}&translatedLanguage[]={en}&order[chapter]=asc
    final response = await _dio.get(
      '/chapter',
      queryParameters: {
        'manga': mangaId,
        'translatedLanguage[]': [language],
        'order[chapter]': ascending ? 'asc' : 'desc',
        'limit': limit,
        'offset': offset,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }

    return [];
  }
}

String buildCoverUrl(String mangaId, String fileName, {int size = 256}) {
  // size hợp lệ: 256, 512. Bỏ đuôi để lấy full gốc.
  if (size == 256 || size == 512) {
    return 'https://uploads.mangadex.org/covers/$mangaId/$fileName.$size.jpg';
  }
  return 'https://uploads.mangadex.org/covers/$mangaId/$fileName';
}
