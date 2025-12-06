import 'package:shared_dependencies/shared_dependencies.dart';

/// DioProvider: Cung cấp Dio instance đã được cấu hình chuẩn cho MangaDex.
class DioProvider {
  // Base URL của MangaDex API
  static const String baseUrl = 'https://api.mangadex.org';

  /// Tạo một Dio instance đã config headers và timeout.
  static Dio make() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // Tăng timeout để an toàn với mạng chậm
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        
        headers: {
          // 1. MangaDex YÊU CẦU User-Agent hợp lệ để không chặn request
          'User-Agent': 'MangaReaderApp/0.0.1 (flutter)',
          
          // 2. Yêu cầu server đóng kết nối sau khi xong
          // Tránh lỗi "Connection closed before full header"
          'Connection': 'close', 
        },
        
        // 3. TẮT persistentConnection: Buộc tạo socket mới mỗi request
        persistentConnection: false, 
      ),
    );

    // Thêm Log cho dễ debug (chỉ hiện khi debug mode)
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: false, // Tắt body response để đỡ rác log
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    return dio;
  }
}