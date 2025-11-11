import 'package:dio/dio.dart';

/// ---------------------------------------------------------------------------
/// DiscoveryRemoteDataSource
/// ---------------------------------------------------------------------------
/// Nhiệm vụ:
/// - Tầng DataSource (infrastructure): gọi trực tiếp MangaDex API bằng Dio.
/// - Trả về RAW JSON ở dạng List<Map<String, dynamic>> để RepositoryImpl parse
///   sang entity (FeedItem). Ở lớp này KHÔNG làm chuyện domain mapping.
/// 
/// Yêu cầu môi trường (Bootstrap/DI):
/// - PHẢI đăng ký sẵn Dio với baseUrl = https://api.mangadex.org
///   ví dụ:
///   sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
///     baseUrl: "https://api.mangadex.org",
///   )));
///
/// Lý do thiết kế:
/// - Phân tách rõ: DataSource = I/O + gọi HTTP, Repository = mapping + rule.
/// - Dễ mock trong unit test: mock DataSource để test Repository/UseCase.
/// ---------------------------------------------------------------------------
class DiscoveryRemoteDataSource {
  /// HTTP client dùng chung, được inject từ DI (GetIt).
  final Dio _dio;

  /// Khởi tạo với Dio đã cấu hình sẵn (baseUrl, timeout, interceptor nếu có).
  DiscoveryRemoteDataSource(this._dio);

  // -------------------------------------------------------------------------
  // fetchTrending
  // -------------------------------------------------------------------------
  /// Mục đích:
  /// - Lấy danh sách manga đang "hot/phổ biến".
  /// - Dựa trên tiêu chí followedCount giảm dần của MangaDex.
  ///
  /// Endpoint:
  /// - GET /manga
  /// - Query:
  ///   - limit: số item mỗi trang (phân trang phía client)
  ///   - offset: vị trí bắt đầu (0, 20, ...)
  ///   - includes[]: ['cover_art'] để có thông tin ảnh bìa
  ///   - order[followedCount]=desc để sắp xếp theo lượt follow giảm dần
  ///
  /// Tham số:
  /// - [offset] và [limit] do tầng trên (UseCase/Bloc) quyết định.
  ///
  /// Trả về:
  /// - List<Map<String, dynamic>> chính là mảng "data" trong JSON của MangaDex.
  /// - Nếu không đúng schema, trả về list rỗng (không ném exception ở đây).
  Future<List<Map<String, dynamic>>> fetchTrending({
    required int offset,
    required int limit,
  }) async {
    // Gọi HTTP GET với queryParameters đúng chuẩn MangaDex.
    final Response resp = await _dio.get(
      '/manga',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        // includes[] có thể truyền 1 mảng để vừa có cover_art, sau này muốn thêm author cũng được.
        'includes[]': ['cover_art'],
        'order[followedCount]': 'desc',
      },
    );

    // MangaDex trả dạng { "result": "...", "data": [ ... ] }
    // Ở đây chỉ cần data thô, mapping để Repository lo.
    final data = resp.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    // Fallback an toàn: không quăng lỗi để UI/Repo tự xử lý empty state.
    return <Map<String, dynamic>>[];
  }

  // -------------------------------------------------------------------------
  // fetchLatestUpdates
  // -------------------------------------------------------------------------
  /// Mục đích:
  /// - Lấy danh sách manga mới cập nhật gần đây.
  ///
  /// Endpoint:
  /// - GET /manga
  /// - Query:
  ///   - limit, offset tương tự trên
  ///   - includes[]: ['cover_art'] để hiển thị cover ở feed
  ///   - order[updatedAt]=desc để sắp xếp theo thời gian cập nhật gần nhất
  ///
  /// Trả về:
  /// - List<Map<String, dynamic>> là mảng raw item của MangaDex.
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
