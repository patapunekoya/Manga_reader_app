import 'package:shared_dependencies/shared_dependencies.dart';
import 'di/home_injection.dart';
import 'presentation/routes/home_routes.dart';

class HomeModule {
  static Future<void> di() async {
    await initHomeDI();
  }

  static List<GoRoute> get routes => HomeRoutes.routes;

  // HomeBloc thường được dùng cục bộ trong HomeShellPage nên không cần Global Provider.
  // Nhưng nếu MainShell cần access HomeBloc (ví dụ badge notification), bạn có thể thêm vào đây.
  static List<BlocProvider> get blocProviders => [];
}