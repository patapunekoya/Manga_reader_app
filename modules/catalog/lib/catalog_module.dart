import 'package:shared_dependencies/shared_dependencies.dart';
import 'di/catalog_injection.dart';
import 'presentation/routes/catalog_routes.dart';

class CatalogModule {
  static Future<void> di() async {
    await initCatalogDI();
  }

  static List<GoRoute> get routes => CatalogRoutes.routes;
  
  static List<BlocProvider> get blocProviders => [];
}