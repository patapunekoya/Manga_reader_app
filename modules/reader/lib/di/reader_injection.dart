import 'package:shared_dependencies/shared_dependencies.dart'; // Thay thế get_it, dio...
import '../reader.dart';

// Import Library Repository từ module khác để inject vào SaveReadProgress
import 'package:library_manga/domain/repositories/library_repository.dart';

final sl = GetIt.instance;

Future<void> initReaderDI() async {
  // 1. Datasource
  if (!sl.isRegistered<ReaderRemoteDataSource>()) {
    sl.registerLazySingleton<ReaderRemoteDataSource>(
      () => ReaderRemoteDataSource(sl<Dio>()),
    );
  }

  // 2. Repository
  if (!sl.isRegistered<ReaderRepository>()) {
    sl.registerLazySingleton<ReaderRepository>(
      () => ReaderRepositoryImpl(sl<ReaderRemoteDataSource>()),
    );
  }

  // 3. Usecases
  if (!sl.isRegistered<GetChapterPages>()) {
    sl.registerLazySingleton(() => GetChapterPages(sl<ReaderRepository>()));
  }
  if (!sl.isRegistered<PrefetchPages>()) {
    sl.registerLazySingleton(() => PrefetchPages(sl<ReaderRepository>()));
  }
  if (!sl.isRegistered<ReportImageError>()) {
    sl.registerLazySingleton(() => ReportImageError(sl<ReaderRepository>()));
  }
  
  // Usecase SaveReadProgress: phụ thuộc vào LibraryRepository (của module Library)
  // Đảm bảo LibraryModule.di() đã được gọi trước hoặc GetIt đã có LibraryRepository.
  if (!sl.isRegistered<SaveReadProgress>()) {
    sl.registerLazySingleton(
      () => SaveReadProgress(sl<LibraryRepository>()),
    );
  }

  // 4. Bloc Factory (Tạo mới mỗi lần dùng)
  // Không đăng ký Singleton cho Bloc vì mỗi lần mở Reader là một context khác nhau
  if (!sl.isRegistered<ReaderBloc>()) {
    sl.registerFactory(() => ReaderBloc(
          getChapterPages: sl<GetChapterPages>(),
          prefetchPages: sl<PrefetchPages>(),
          reportImageError: sl<ReportImageError>(),
          saveReadProgress: sl<SaveReadProgress>(),
        ));
  }
}