// lib/infrastructure/datasources/catalog_remote_ds.dart
import 'package:dio/dio.dart';

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

  Future<List<Map<String, dynamic>>> searchMangaRaw({
    required String query,
    String? genre, 
    required int offset,
    required int limit,
  }) async {
    final response = await _dio.get(
      '/manga',
      queryParameters: {
        'title': query,
        'limit': limit,
        'offset': offset,
        'includes[]': ['cover_art'],
        // có thể thêm 'order[relevance]': 'desc' nếu API support
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
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
