// lib/bootstrap.dart

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
// THÊM: Imports cho Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; 

import 'di/locator.dart';

// ===== AUTH (MỚI) =====
import 'package:auth/auth.dart';
import 'package:auth/domain/repositories/auth_repository.dart'; // Import Auth Repository

// ===== HOME =====
import 'package:home/presentation/bloc/home_bloc.dart';
import 'package:home/application/usecases/build_home_vm.dart';

// ===== LIBRARY =====
// Usecase + Bloc + Repo + DS của thư viện (yêu thích, lịch sử đọc, progress)
import 'package:library_manga/application/usecases/get_continue_reading.dart';
import 'package:library_manga/application/usecases/get_favorites.dart';
import 'package:library_manga/application/usecases/toggle_favorite.dart';
import 'package:library_manga/presentation/bloc/history_bloc.dart';
import 'package:library_manga/presentation/bloc/favorites_bloc.dart';
import 'package:library_manga/domain/repositories/library_repository.dart';
import 'package:library_manga/infrastructure/repositories/library_repository_impl.dart';
import 'package:library_manga/infrastructure/datasources/library_local_ds.dart';
// THÊM: Import Firestore DS
import 'package:library_manga/infrastructure/datasources/library_firestore_ds.dart';


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

// Usecase lưu tiến trình đọc
import 'package:reader/application/usecases/save_read_progress.dart' as reader_uc;



Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  setupLocator();
  final sl = GetIt.instance;
  
  // ==========================================================
  // ĐĂNG KÝ MODULE AUTH (MỚI)
  // ==========================================================
  try {
      if (initAuthModule != null) { 
          initAuthModule(sl);
      }
  } catch (e) {
      debugPrint("Error initializing Auth Module DI: $e");
  }
  // ==========================================================


  // 3) Core HTTP — Dio dùng chung
  if (!sl.isRegistered<Dio>()) {
      sl.registerLazySingleton<Dio>(() => Dio(
            BaseOptions(
              baseUrl: 'https://api.mangadex.org',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              
              headers: {
                'User-Agent': 'MangaReaderApp/0.0.1 (flutter)',
                'Connection': 'close', 
              },
              persistentConnection: false, 
            ),
          ));
    }

  // 4) Đăng ký Datasource cho từng module
  if (!sl.isRegistered<LibraryLocalDataSource>()) {
    sl.registerLazySingleton<LibraryLocalDataSource>(() => LibraryLocalDataSource());
  }
  // THÊM: Đăng ký Firestore DS
  if (!sl.isRegistered<LibraryFirestoreDataSource>()) {
    // FirebaseFirestore.instance phải có sẵn sau khi Firebase.initializeApp() chạy trong main.dart
    sl.registerLazySingleton<LibraryFirestoreDataSource>(() => LibraryFirestoreDataSource(FirebaseFirestore.instance));
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

  // 5) Mở Hive box — phải init SAU khi đã đăng ký LibraryLocalDataSource
  await sl<LibraryLocalDataSource>().init();

  // 6) Repository — ghép DataSource vào tầng domain
  // CẬP NHẬT: LibraryRepositoryImpl MỚI cần 3 dependencies
  if (!sl.isRegistered<LibraryRepository>()) {
    sl.registerLazySingleton<LibraryRepository>(() => LibraryRepositoryImpl(
        sl<LibraryLocalDataSource>(),
        sl<AuthRepository>(), // Cần AuthRepository từ Module Auth
        sl<LibraryFirestoreDataSource>(), // Cần Firestore DS
    ));
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

  // 7) Usecases — business logic đơn nhiệm, tái sử dụng
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
  // UseCase lưu tiến trình đọc: đặt ở module reader, nhưng phụ thuộc LibraryRepository để ghi vào Hive
  if (!sl.isRegistered<reader_uc.SaveReadProgress>()) {
    sl.registerLazySingleton<reader_uc.SaveReadProgress>(
      () => reader_uc.SaveReadProgress(sl<LibraryRepository>()),
    );
  }

  // HOME VM — tổng hợp dữ liệu cho màn Home (continue + trending + latest)
  if (!sl.isRegistered<BuildHomeVM>()) {
    sl.registerLazySingleton<BuildHomeVM>(() => BuildHomeVM(
          sl<GetContinueReading>(),
          sl<GetTrending>(),
          sl<GetLatestUpdates>(),
        ));
  }

  // 8) Bloc factories — mỗi lần resolve sẽ tạo instance mới “sạch”
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
          getFavorites: sl<GetFavorites>(),        // lấy trạng thái yêu thích hiện tại
          toggleFavorite: sl<ToggleFavorite>(),    // bật/tắt yêu thích
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