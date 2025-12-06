import 'package:shared_dependencies/shared_dependencies.dart';
import 'di/discovery_injection.dart';

class DiscoveryModule {
  static Future<void> di() async {
    await initDiscoveryDI();
  }

  static List<GoRoute> get routes => [];
  static List<BlocProvider> get blocProviders => [];
}