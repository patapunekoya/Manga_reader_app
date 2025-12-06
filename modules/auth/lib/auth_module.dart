import 'package:shared_dependencies/shared_dependencies.dart';
import 'di/auth_injection.dart';
import 'presentation/routes/auth_routes.dart';

class AuthModule {
  static Future<void> di() async {
    await initAuthDI();
  }

  static List<GoRoute> get routes => AuthRoutes.routes;

  // AuthStatusBloc cần được cung cấp Global (toàn app)
  // Tuy nhiên, cách dùng BlocProvider trong App.dart cũ của bạn là OK.
  // Ở đây để trống list này nếu bạn vẫn giữ BlocProvider(create: GetIt...) ở root.
  static List<BlocProvider> get blocProviders => [];
}