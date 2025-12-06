import 'package:shared_dependencies/shared_dependencies.dart';
import 'di/library_injection.dart';
import 'presentation/routes/library_routes.dart';

class LibraryModule {
  static Future<void> di() async {
    await initLibraryDI();
  }

  static List<GoRoute> get routes => LibraryRoutes.routes;
  static List<BlocProvider> get blocProviders => [];
}