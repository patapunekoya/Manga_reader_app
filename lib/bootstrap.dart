// lib/bootstrap.dart
//
// PURPOSE / CHỨC NĂNG TỔNG QUÁT
// - Hàm bootstrap() chịu trách nhiệm khởi động toàn bộ hạ tầng ứng dụng trước khi runApp:
//   + Khởi tạo Flutter binding, Hive (local storage)
//   + Tạo và cấu hình GetIt (DI container) thông qua setupLocator()
//   + Đăng ký mọi DataSource, Repository, UseCase, BLoC theo mô-đun
//   + Mở các Hive box cần dùng (ở đây là của module Library)
// - Tách phần khởi động nặng/bất đồng bộ ra khỏi main.dart để main.js gọn và an toàn.
//
// LƯU Ý KIẾN TRÚC
// - DI theo GetIt: "đăng ký trước, dùng sau". Router, UI, Bloc... lấy phụ thuộc qua GetIt.
// - Mỗi nhóm chức năng (HOME / LIBRARY / DISCOVERY / CATALOG / READER) có: datasource -> repository -> usecase -> bloc.
// - Tất cả đều được “wire” ở đây để đảm bảo chuỗi phụ thuộc đầy đủ trước khi UI chạy.
//
// THỨ TỰ KHỞI ĐỘNG BÊN TRONG bootstrap()
// 1) ensureInitialized + Hive.initFlutter()
// 2) setupLocator() để đảm bảo instance GetIt sẵn sàng
// 3) Đăng ký Dio (HTTP core) dùng chung cho các remote DS
// 4) Đăng ký DataSource (local/remote) theo mô-đun
// 5) Mở Hive box (sau khi DS local đã đăng ký)
// 6) Đăng ký Repository (phụ thuộc DS)
// 7) Đăng ký UseCase (phụ thuộc Repo)
// 8) Đăng ký Bloc factory (phụ thuộc UseCase)
// -> Sau bootstrap() thì UI có thể tự tin resolve mọi thứ từ GetIt.
//
// MẸO DEBUG / BẢO TRÌ
// - isRegistered<T>() giúp tránh double-register khi hot reload.
// - Nếu muốn log chuỗi khởi động, có thể thêm print/log nhỏ ở mỗi cụm.
// - Khi cập nhật API baseUrl, đổi tại Dio(BaseOptions(...)) duy nhất ở đây.
//
// -----------------------------------------------------------------------------------------

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

import 'di/locator.dart';

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

// ===== DISCOVERY =====
// Phần khám phá (trending, latest) — remote only
import 'package:discovery/application/usecases/get_trending.dart';
import 'package:discovery/application/usecases/get_latest_updates.dart';
import 'package:discovery/presentation/bloc/discovery_bloc.dart';
import 'package:discovery/domain/repositories/discovery_repository.dart';
import 'package:discovery/infrastructure/repositories/discovery_repository_impl.dart';
import 'package:discovery/infrastructure/datasources/discovery_remote_ds.dart';

// ===== CATALOG =====
// Phần danh mục (search, detail, list chapters) — remote + optional local cache
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
// Phần đọc truyện (load trang, prefetch, report lỗi ảnh)
import 'package:reader/application/usecases/get_chapter_pages.dart';
import 'package:reader/application/usecases/prefetch_pages.dart';
import 'package:reader/application/usecases/report_image_error.dart';
import 'package:reader/presentation/bloc/reader_bloc.dart';
import 'package:reader/domain/repositories/reader_repository.dart';
import 'package:reader/infrastructure/repositories/reader_repository_impl.dart';
import 'package:reader/infrastructure/datasources/reader_remote_ds.dart';

// Usecase lưu tiến trình đọc (đặt trong module reader, nhưng phụ thuộc LibraryRepository)
import 'package:reader/application/usecases/save_read_progress.dart' as reader_uc;

Future<void> bootstrap() async {
  // Bắt buộc: đảm bảo binding sẵn sàng cho mọi thao tác (đặc biệt là async, plugin, Hive)
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Khởi tạo Hive (Local key-value DB) cho toàn app
  await Hive.initFlutter();

  // 2) Chuẩn bị DI container (GetIt)
  //    setupLocator() chỉ đảm bảo GetIt.instance sẵn, có thể dùng để tách init theo module trong tương lai.
  setupLocator();
  final sl = GetIt.instance;

  // 3) Core HTTP — Dio dùng chung
  //    - BaseOptions cấu hình timeout, baseUrl của MangaDex API.
  //    - registerLazySingleton: chỉ tạo khi lần đầu cần, tiết kiệm startup time.
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio(
          BaseOptions(
            baseUrl: 'https://api.mangadex.org',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
          ),
        ));
  }

  // 4) Đăng ký Datasource cho từng module
  //    - Local DS của Library: quản lý Hive box cho favorites/progress
  //    - Remote DS của Discovery/Catalog/Reader: gọi API qua Dio
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

  // 5) Mở Hive box — phải init SAU khi đã đăng ký LibraryLocalDataSource
  await sl<LibraryLocalDataSource>().init();

  // 6) Repository — ghép DataSource vào tầng domain
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

  // 7) Usecases — business logic đơn nhiệm, tái sử dụng
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
  //    Ưu tiên registerFactory cho Bloc để tránh giữ state cũ ngoài ý muốn.
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
