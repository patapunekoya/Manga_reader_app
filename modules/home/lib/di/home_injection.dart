// modules/home/lib/di/home_injection.dart
import 'package:shared_dependencies/shared_dependencies.dart';
import '../home.dart';

// Usecase từ module khác
import 'package:library_manga/library.dart';
import 'package:discovery/discovery.dart';

final sl = GetIt.instance;

Future<void> initHomeDI() async {
  // 1. Usecase: BuildHomeVM
  // HomeVM cần 3 usecase con. Chúng ta lấy chúng từ GetIt (do module Library và Discovery đã đăng ký rồi)
  if (!sl.isRegistered<BuildHomeVM>()) {
    sl.registerLazySingleton<BuildHomeVM>(
      () => BuildHomeVM(
        sl<GetContinueReading>(), // Từ module Library
        sl<GetTrending>(),        // Từ module Discovery
        sl<GetLatestUpdates>(),   // Từ module Discovery
      ),
    );
  }

  // 2. Bloc Factory
  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(
      () => HomeBloc(buildHomeVM: sl<BuildHomeVM>()),
    );
  }
}