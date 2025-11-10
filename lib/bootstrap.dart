// lib/bootstrap.dart
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

import 'di/locator.dart';

// ===== HOME =====
import 'package:home/presentation/bloc/home_bloc.dart';
import 'package:home/application/usecases/build_home_vm.dart';

// ===== LIBRARY =====
import 'package:library_manga/application/usecases/get_continue_reading.dart';
import 'package:library_manga/application/usecases/get_favorites.dart';
import 'package:library_manga/application/usecases/toggle_favorite.dart';
import 'package:library_manga/presentation/bloc/history_bloc.dart';
import 'package:library_manga/presentation/bloc/favorites_bloc.dart';
import 'package:library_manga/domain/repositories/library_repository.dart';
import 'package:library_manga/infrastructure/repositories/library_repository_impl.dart';
import 'package:library_manga/infrastructure/datasources/library_local_ds.dart';

// ===== DISCOVERY =====
import 'package:discovery/application/usecases/get_trending.dart';
import 'package:discovery/application/usecases/get_latest_updates.dart';
import 'package:discovery/presentation/bloc/discovery_bloc.dart';
import 'package:discovery/domain/repositories/discovery_repository.dart';
import 'package:discovery/infrastructure/repositories/discovery_repository_impl.dart';
import 'package:discovery/infrastructure/datasources/discovery_remote_ds.dart';

// ===== CATALOG =====
import 'package:catalog/application/usecases/search_manga.dart';
import 'package:catalog/application/usecases/get_manga_detail.dart';
import 'package:catalog/application/usecases/list_chapters.dart';
import 'package:catalog/presentation/bloc/search_bloc.dart';
import 'package:catalog/presentation/bloc/manga_detail_bloc.dart';
import 'package:catalog/domain/repositories/catalog_repository.dart';
import 'package:catalog/infrastructure/repositories/catalog_repository_impl.dart';
import 'package:catalog/infrastructure/datasources/catalog_remote_ds.dart';
import 'package:catalog/infrastructure/datasources/catalog_local_ds.dart';

// ===== READER =====
import 'package:reader/application/usecases/get_chapter_pages.dart';
import 'package:reader/application/usecases/prefetch_pages.dart';
import 'package:reader/application/usecases/report_image_error.dart';
import 'package:reader/presentation/bloc/reader_bloc.dart';
import 'package:reader/domain/repositories/reader_repository.dart';
import 'package:reader/infrastructure/repositories/reader_repository_impl.dart';
import 'package:reader/infrastructure/datasources/reader_remote_ds.dart';

// Usecase lưu tiến trình đọc (đặt trong module reader, phụ thuộc LibraryRepository)
import 'package:reader/application/usecases/save_read_progress.dart' as reader_uc;

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Hive
  await Hive.initFlutter();

  // 2) GetIt base
  setupLocator();
  final sl = GetIt.instance;

  // 3) Core HTTP
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio(
          BaseOptions(
            baseUrl: 'https://api.mangadex.org',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
          ),
        ));
  }

  // 4) Datasources
  if (!sl.isRegistered<LibraryLocalDataSource>()) {
    sl.registerLazySingleton<LibraryLocalDataSource>(() => LibraryLocalDataSource());
  }
  if (!sl.isRegistered<DiscoveryRemoteDataSource>()) {
    sl.registerLazySingleton<DiscoveryRemoteDataSource>(() => DiscoveryRemoteDataSource(sl<Dio>()));
  }
  if (!sl.isRegistered<CatalogRemoteDataSource>()) {
    sl.registerLazySingleton<CatalogRemoteDataSource>(() => CatalogRemoteDataSource(sl<Dio>()));
  }
  if (!sl.isRegistered<CatalogLocalDataSource>()) {
    sl.registerLazySingleton<CatalogLocalDataSource>(() => CatalogLocalDataSource());
  }
  if (!sl.isRegistered<ReaderRemoteDataSource>()) {
    sl.registerLazySingleton<ReaderRemoteDataSource>(() => ReaderRemoteDataSource(sl<Dio>()));
  }

  // 5) Init Hive boxes (sau khi register datasource)
  await sl<LibraryLocalDataSource>().init();

  // 6) Repositories
  if (!sl.isRegistered<LibraryRepository>()) {
    sl.registerLazySingleton<LibraryRepository>(() => LibraryRepositoryImpl(sl<LibraryLocalDataSource>()));
  }
  if (!sl.isRegistered<DiscoveryRepository>()) {
    sl.registerLazySingleton<DiscoveryRepository>(() => DiscoveryRepositoryImpl(sl<DiscoveryRemoteDataSource>()));
  }
  if (!sl.isRegistered<CatalogRepository>()) {
    sl.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(
          sl<CatalogRemoteDataSource>(),
          sl<CatalogLocalDataSource>(),
        ));
  }
  if (!sl.isRegistered<ReaderRepository>()) {
    sl.registerLazySingleton<ReaderRepository>(() => ReaderRepositoryImpl(sl<ReaderRemoteDataSource>()));
  }

  // 7) Usecases
  // LIBRARY
  if (!sl.isRegistered<GetContinueReading>()) {
    sl.registerLazySingleton<GetContinueReading>(() => GetContinueReading(sl<LibraryRepository>()));
  }
  if (!sl.isRegistered<GetFavorites>()) {
    sl.registerLazySingleton<GetFavorites>(() => GetFavorites(sl<LibraryRepository>()));
  }
  if (!sl.isRegistered<ToggleFavorite>()) {
    sl.registerLazySingleton<ToggleFavorite>(() => ToggleFavorite(sl<LibraryRepository>()));
  }

  // DISCOVERY
  if (!sl.isRegistered<GetTrending>()) {
    sl.registerLazySingleton<GetTrending>(() => GetTrending(sl<DiscoveryRepository>()));
  }
  if (!sl.isRegistered<GetLatestUpdates>()) {
    sl.registerLazySingleton<GetLatestUpdates>(() => GetLatestUpdates(sl<DiscoveryRepository>()));
  }

  // CATALOG
  if (!sl.isRegistered<SearchManga>()) {
    sl.registerLazySingleton<SearchManga>(() => SearchManga(sl<CatalogRepository>()));
  }
  if (!sl.isRegistered<GetMangaDetail>()) {
    sl.registerLazySingleton<GetMangaDetail>(() => GetMangaDetail(sl<CatalogRepository>()));
  }
  if (!sl.isRegistered<ListChapters>()) {
    sl.registerLazySingleton<ListChapters>(() => ListChapters(sl<CatalogRepository>()));
  }

  // READER
  if (!sl.isRegistered<GetChapterPages>()) {
    sl.registerLazySingleton<GetChapterPages>(() => GetChapterPages(sl<ReaderRepository>()));
  }
  if (!sl.isRegistered<PrefetchPages>()) {
    sl.registerLazySingleton<PrefetchPages>(() => PrefetchPages(sl<ReaderRepository>()));
  }
  if (!sl.isRegistered<ReportImageError>()) {
    sl.registerLazySingleton<ReportImageError>(() => ReportImageError(sl<ReaderRepository>()));
  }
  // Usecase lưu tiến trình đọc (trong module reader)
  if (!sl.isRegistered<reader_uc.SaveReadProgress>()) {
    sl.registerLazySingleton<reader_uc.SaveReadProgress>(
      () => reader_uc.SaveReadProgress(sl<LibraryRepository>()),
    );
  }

  // HOME VM
  if (!sl.isRegistered<BuildHomeVM>()) {
    sl.registerLazySingleton<BuildHomeVM>(() => BuildHomeVM(
          sl<GetContinueReading>(),
          sl<GetTrending>(),
          sl<GetLatestUpdates>(),
        ));
  }

  // 8) Blocs
  if (!sl.isRegistered<HistoryBloc>()) {
    sl.registerFactory<HistoryBloc>(() => HistoryBloc(
      getContinueReading: sl<GetContinueReading>(),
      repo: sl<LibraryRepository>(),
    ));
  }



  if (!sl.isRegistered<FavoritesBloc>()) {
    sl.registerFactory<FavoritesBloc>(() => FavoritesBloc(
          getFavorites: sl<GetFavorites>(),
          toggleFavorite: sl<ToggleFavorite>(),
        ));
  }
  if (!sl.isRegistered<DiscoveryBloc>()) {
    sl.registerFactory<DiscoveryBloc>(() => DiscoveryBloc(
          getTrending: sl<GetTrending>(),
          getLatest: sl<GetLatestUpdates>(),
        ));
  }
  if (!sl.isRegistered<SearchBloc>()) {
    sl.registerFactory<SearchBloc>(() => SearchBloc(searchManga: sl<SearchManga>()));
  }
  if (!sl.isRegistered<MangaDetailBloc>()) {
    sl.registerFactory<MangaDetailBloc>(() => MangaDetailBloc(
          getMangaDetail: sl<GetMangaDetail>(),
          listChapters: sl<ListChapters>(),
          getFavorites: sl<GetFavorites>(),        // NEW
          toggleFavorite: sl<ToggleFavorite>(),    // NEW
        ));
  }
  if (!sl.isRegistered<ReaderBloc>()) {
    sl.registerFactory<ReaderBloc>(() => ReaderBloc(
          getChapterPages: sl<GetChapterPages>(),
          prefetchPages: sl<PrefetchPages>(),
          reportImageError: sl<ReportImageError>(),
          saveReadProgress: sl<reader_uc.SaveReadProgress>(),
        ));
  }
  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(() => HomeBloc(buildHomeVM: sl<BuildHomeVM>()));
  }
}

