// modules/catalog/lib/di/catalog_injection.dart
import 'package:shared_dependencies/shared_dependencies.dart';
import '../catalog.dart';

// Vẫn cần import Library để lấy usecase Favorite (vì nó thuộc module khác)
import 'package:library_manga/library.dart';

final sl = GetIt.instance;

Future<void> initCatalogDI() async {
  // 1. DataSources
  if (!sl.isRegistered<CatalogRemoteDataSource>()) {
    sl.registerLazySingleton(() => CatalogRemoteDataSource(sl<Dio>()));
  }
  if (!sl.isRegistered<CatalogLocalDataSource>()) {
    sl.registerLazySingleton(() => CatalogLocalDataSource());
  }

  // 2. Repository
  if (!sl.isRegistered<CatalogRepository>()) {
    sl.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        sl<CatalogRemoteDataSource>(),
        sl<CatalogLocalDataSource>(),
      ),
    );
  }

  // 3. UseCases
  if (!sl.isRegistered<SearchManga>()) {
    sl.registerLazySingleton(() => SearchManga(sl<CatalogRepository>()));
  }
  if (!sl.isRegistered<GetMangaDetail>()) {
    sl.registerLazySingleton(() => GetMangaDetail(sl<CatalogRepository>()));
  }
  if (!sl.isRegistered<ListChapters>()) {
    sl.registerLazySingleton(() => ListChapters(sl<CatalogRepository>()));
  }

  // 4. Blocs (Factory)
  if (!sl.isRegistered<SearchBloc>()) {
    sl.registerFactory(() => SearchBloc(searchManga: sl<SearchManga>()));
  }
  
  if (!sl.isRegistered<MangaDetailBloc>()) {
    sl.registerFactory(() => MangaDetailBloc(
          getMangaDetail: sl<GetMangaDetail>(),
          listChapters: sl<ListChapters>(),
          // Các usecase này từ module Library (đảm bảo Library đã init)
          getFavorites: sl<GetFavorites>(),
          toggleFavorite: sl<ToggleFavorite>(),
        ));
  }
}