// modules/discovery/lib/di/discovery_injection.dart
import 'package:shared_dependencies/shared_dependencies.dart';
import '../discovery.dart'; // Chỉ cần import file này


final sl = GetIt.instance;

Future<void> initDiscoveryDI() async {
  // DataSource
  if (!sl.isRegistered<DiscoveryRemoteDataSource>()) {
    sl.registerLazySingleton(() => DiscoveryRemoteDataSource(sl<Dio>()));
  }
  // Repository
  if (!sl.isRegistered<DiscoveryRepository>()) {
    sl.registerLazySingleton<DiscoveryRepository>(
        () => DiscoveryRepositoryImpl(sl<DiscoveryRemoteDataSource>()));
  }
  // UseCases
  if (!sl.isRegistered<GetTrending>()) {
    sl.registerLazySingleton(() => GetTrending(sl<DiscoveryRepository>()));
  }
  if (!sl.isRegistered<GetLatestUpdates>()) {
    sl.registerLazySingleton(() => GetLatestUpdates(sl<DiscoveryRepository>()));
  }
  // Bloc
  if (!sl.isRegistered<DiscoveryBloc>()) {
    sl.registerFactory(() => DiscoveryBloc(
          getTrending: sl<GetTrending>(),
          getLatest: sl<GetLatestUpdates>(),
        ));
  }
}