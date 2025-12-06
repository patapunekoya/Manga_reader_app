import 'package:shared_dependencies/shared_dependencies.dart';
import 'di/reader_injection.dart';
import 'presentation/routes/reader_routes.dart';

class ReaderModule {
  /// Khởi tạo DI cho module Reader
  static Future<void> di() async {
    await initReaderDI();
  }

  /// Lấy danh sách routes của Reader
  static List<GoRoute> get routes => ReaderRoutes.routes;
  
  /// Bloc Providers (Nếu cần global, Reader thường ko cần global bloc nên để rỗng)
  static List<BlocProvider> get blocProviders => [];
}