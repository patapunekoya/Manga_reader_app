import 'package:shared_dependencies/shared_dependencies.dart';
import 'package:auth/domain/repositories/auth_repository.dart';
import '../library.dart';



final sl = GetIt.instance;

Future<void> initLibraryDI() async {
  // 1. DataSources
  // XÓA: LibraryLocalDataSource
  if (!sl.isRegistered<LibraryFirestoreDataSource>()) {
    sl.registerLazySingleton(() => LibraryFirestoreDataSource(FirebaseFirestore.instance));
  }

  // 2. Repository
  if (!sl.isRegistered<LibraryRepository>()) {
    sl.registerLazySingleton<LibraryRepository>(
      () => LibraryRepositoryImpl(
        sl<AuthRepository>(), // Auth Repo
        sl<LibraryFirestoreDataSource>(), // Firestore DS
      ),
    );
  }

  // 3. UseCases
  if (!sl.isRegistered<GetContinueReading>()) {
    sl.registerLazySingleton(() => GetContinueReading(sl<LibraryRepository>()));
  }
  if (!sl.isRegistered<GetFavorites>()) {
    sl.registerLazySingleton(() => GetFavorites(sl<LibraryRepository>()));
  }
  if (!sl.isRegistered<ToggleFavorite>()) {
    sl.registerLazySingleton(() => ToggleFavorite(sl<LibraryRepository>()));
  }
  if (!sl.isRegistered<SaveReadProgress>()) {
    sl.registerLazySingleton(() => SaveReadProgress(sl<LibraryRepository>()));
  }

  // 4. Blocs
  if (!sl.isRegistered<FavoritesBloc>()) {
    sl.registerFactory(() => FavoritesBloc(
          getFavorites: sl<GetFavorites>(),
          toggleFavorite: sl<ToggleFavorite>(),
        ));
  }
  if (!sl.isRegistered<HistoryBloc>()) {
    sl.registerFactory(() => HistoryBloc(
          getContinueReading: sl<GetContinueReading>(),
          repo: sl<LibraryRepository>(),
        ));
  }
}