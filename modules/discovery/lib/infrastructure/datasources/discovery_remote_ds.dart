import 'package:dio/dio.dart';

/// DiscoveryRemoteDataSource
/// nhiệm vụ: gọi trực tiếp MangaDex API và trả raw JSON dạng List<Map>
/// RepositoryImpl sẽ lo parse sang entity FeedItem.
///
/// YÊU CẦU QUAN TRỌNG:
/// - Trong bootstrap/get_it bạn PHẢI register Dio(baseUrl: https://api.mangadex.org)
///   ví dụ:
///   sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
///     baseUrl: "https://api.mangadex.org",
///   )));
class DiscoveryRemoteDataSource {
  final Dio _dio;
  DiscoveryRemoteDataSource(this._dio);

  /// gọi /manga?order[followedCount]=desc -> manga hot / phổ biến
  Future<List<Map<String, dynamic>>> fetchTrending({
    required int offset,
    required int limit,
  }) async {
    final Response resp = await _dio.get(
      '/manga',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'includes[]': ['cover_art'],
        'order[followedCount]': 'desc',
      },
    );

    final data = resp.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return <Map<String, dynamic>>[];
  }

  /// gọi /manga?order[updatedAt]=desc -> manga mới cập nhật
  Future<List<Map<String, dynamic>>> fetchLatestUpdates({
    required int offset,
    required int limit,
  }) async {
    final Response resp = await _dio.get(
      '/manga',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'includes[]': ['cover_art'],
        'order[updatedAt]': 'desc',
      },
    );

    final data = resp.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return <Map<String, dynamic>>[];
  }
}
