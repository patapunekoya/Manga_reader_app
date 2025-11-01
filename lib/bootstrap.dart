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

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive init
  await Hive.initFlutter();
  // optional: mở box trực tiếp ở đây nếu bạn không muốn lazy init bằng LibraryLocalDataSource.init()

  // 2. base locator (env,...)
  setupLocator();
  final sl = GetIt.instance;

  // 3. Dio (global http client)
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() {
      return Dio(
        BaseOptions(
          baseUrl: 'https://api.mangadex.org',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
    });
  }

  // =========================
  // DATASOURCES
  // =========================

  // LibraryLocalDataSource (Hive-backed)
  if (!sl.isRegistered<LibraryLocalDataSource>()) {
    sl.registerLazySingleton<LibraryLocalDataSource>(() {
      return LibraryLocalDataSource();
    });
  }

  // DiscoveryRemoteDataSource
  if (!sl.isRegistered<DiscoveryRemoteDataSource>()) {
    sl.registerLazySingleton<DiscoveryRemoteDataSource>(() {
      return DiscoveryRemoteDataSource(
        sl<Dio>(),
      );
    });
  }

  // CatalogRemoteDataSource
  if (!sl.isRegistered<CatalogRemoteDataSource>()) {
    sl.registerLazySingleton<CatalogRemoteDataSource>(() {
      return CatalogRemoteDataSource(
        sl<Dio>(),
      );
    });
  }

  // CatalogLocalDataSource
  if (!sl.isRegistered<CatalogLocalDataSource>()) {
    sl.registerLazySingleton<CatalogLocalDataSource>(() {
      return CatalogLocalDataSource();
    });
  }

  // ReaderRemoteDataSource
  if (!sl.isRegistered<ReaderRemoteDataSource>()) {
    sl.registerLazySingleton<ReaderRemoteDataSource>(() {
      return ReaderRemoteDataSource(
        sl<Dio>(),
      );
    });
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  // VERY IMPORTANT: init Hive boxes here BEFORE anyone uses it
  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  // gọi init() trên LibraryLocalDataSource sau khi đã register nó
  await sl<LibraryLocalDataSource>().init();

  // =========================
  // REPOSITORIES
  // =========================

  if (!sl.isRegistered<LibraryRepository>()) {
    sl.registerLazySingleton<LibraryRepository>(() {
      return LibraryRepositoryImpl(
        sl<LibraryLocalDataSource>(),
      );
    });
  }

  if (!sl.isRegistered<DiscoveryRepository>()) {
    sl.registerLazySingleton<DiscoveryRepository>(() {
      return DiscoveryRepositoryImpl(
        sl<DiscoveryRemoteDataSource>(),
      );
    });
  }

  if (!sl.isRegistered<CatalogRepository>()) {
    sl.registerLazySingleton<CatalogRepository>(() {
      return CatalogRepositoryImpl(
        sl<CatalogRemoteDataSource>(),
        sl<CatalogLocalDataSource>(),
      );
    });
  }

  if (!sl.isRegistered<ReaderRepository>()) {
    sl.registerLazySingleton<ReaderRepository>(() {
      return ReaderRepositoryImpl(
        sl<ReaderRemoteDataSource>(),
      );
    });
  }

  // =========================
  // USECASES
  // =========================

  // LIBRARY
  if (!sl.isRegistered<GetContinueReading>()) {
    sl.registerLazySingleton<GetContinueReading>(() {
      return GetContinueReading(
        sl<LibraryRepository>(),
      );
    });
  }

  if (!sl.isRegistered<GetFavorites>()) {
    sl.registerLazySingleton<GetFavorites>(() {
      return GetFavorites(
        sl<LibraryRepository>(),
      );
    });
  }

  if (!sl.isRegistered<ToggleFavorite>()) {
    sl.registerLazySingleton<ToggleFavorite>(() {
      return ToggleFavorite(
        sl<LibraryRepository>(),
      );
    });
  }

  // DISCOVERY
  if (!sl.isRegistered<GetTrending>()) {
    sl.registerLazySingleton<GetTrending>(() {
      return GetTrending(
        sl<DiscoveryRepository>(),
      );
    });
  }

  if (!sl.isRegistered<GetLatestUpdates>()) {
    sl.registerLazySingleton<GetLatestUpdates>(() {
      return GetLatestUpdates(
        sl<DiscoveryRepository>(),
      );
    });
  }

  // CATALOG
  if (!sl.isRegistered<SearchManga>()) {
    sl.registerLazySingleton<SearchManga>(() {
      return SearchManga(
        sl<CatalogRepository>(),
      );
    });
  }

  if (!sl.isRegistered<GetMangaDetail>()) {
    sl.registerLazySingleton<GetMangaDetail>(() {
      return GetMangaDetail(
        sl<CatalogRepository>(),
      );
    });
  }

  if (!sl.isRegistered<ListChapters>()) {
    sl.registerLazySingleton<ListChapters>(() {
      return ListChapters(
        sl<CatalogRepository>(),
      );
    });
  }

  // READER
  if (!sl.isRegistered<GetChapterPages>()) {
    sl.registerLazySingleton<GetChapterPages>(() {
      return GetChapterPages(
        sl<ReaderRepository>(),
      );
    });
  }

  if (!sl.isRegistered<PrefetchPages>()) {
    sl.registerLazySingleton<PrefetchPages>(() {
      return PrefetchPages(
        sl<ReaderRepository>(),
      );
    });
  }

  if (!sl.isRegistered<ReportImageError>()) {
    sl.registerLazySingleton<ReportImageError>(() {
      return ReportImageError(
        sl<ReaderRepository>(),
      );
    });
  }

  // HOME VIEWMODEL BUILDER (Home screen glue)
  if (!sl.isRegistered<BuildHomeVM>()) {
    sl.registerLazySingleton<BuildHomeVM>(() {
      return BuildHomeVM(
        sl<GetContinueReading>(),
        sl<GetTrending>(),
        sl<GetLatestUpdates>(),
      );
    });
  }

  // =========================
  // BLOCS
  // =========================

  if (!sl.isRegistered<HistoryBloc>()) {
    sl.registerFactory<HistoryBloc>(() {
      return HistoryBloc(
        getContinueReading: sl<GetContinueReading>(),
      );
    });
  }

  if (!sl.isRegistered<FavoritesBloc>()) {
    sl.registerFactory<FavoritesBloc>(() {
      return FavoritesBloc(
        getFavorites: sl<GetFavorites>(),
        toggleFavorite: sl<ToggleFavorite>(),
      );
    });
  }

  if (!sl.isRegistered<DiscoveryBloc>()) {
    sl.registerFactory<DiscoveryBloc>(() {
      return DiscoveryBloc(
        getTrending: sl<GetTrending>(),
        getLatest: sl<GetLatestUpdates>(),
      );
    });
  }

  if (!sl.isRegistered<SearchBloc>()) {
    sl.registerFactory<SearchBloc>(() {
      return SearchBloc(
        searchManga: sl<SearchManga>(),
      );
    });
  }

  if (!sl.isRegistered<MangaDetailBloc>()) {
    sl.registerFactory<MangaDetailBloc>(() {
      return MangaDetailBloc(
        getMangaDetail: sl<GetMangaDetail>(),
        listChapters: sl<ListChapters>(),
      );
    });
  }

  if (!sl.isRegistered<ReaderBloc>()) {
    sl.registerFactory<ReaderBloc>(() {
      return ReaderBloc(
        getChapterPages: sl<GetChapterPages>(),
        prefetchPages: sl<PrefetchPages>(),
        reportImageError: sl<ReportImageError>(),
      );
    });
  }

  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(() {
      return HomeBloc(
        buildHomeVM: sl<BuildHomeVM>(),
      );
    });
  }
}
