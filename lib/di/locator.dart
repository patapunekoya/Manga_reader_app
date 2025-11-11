// lib/di/locator.dart
//
// PURPOSE / CHỨC NĂNG
// - Đây là điểm tập trung cho Dependency Injection (DI) sử dụng GetIt.
// - Tách riêng khỏi bootstrap để:
//   1) Phân tách trách nhiệm: bootstrap lo trình tự khởi động (init Flutter/Hive, mở box, warm-up),
//      còn locator lo đăng ký các dependency (datasource, repo, usecase, bloc factory).
//   2) Dễ mở rộng theo module: mỗi module có hàm init riêng (vd: initDiscoveryModule, initCatalogModule)
//      và bootstrap chỉ việc gọi tuần tự.
//   3) Dễ test/mocking: test có thể gọi setupLocator() hoặc init một module cụ thể,
//      rồi ghi đè (registerSingleton) các mock mà KHÔNG cần chạy toàn bộ bootstrap.
//   4) Dễ quản lý môi trường (dev/stg/prod): có thể nhánh điều kiện trong các hàm init.
//
// KHI NÀO HÀM NÀY ĐƯỢC GỌI
// - Gọi một lần trong bootstrap.dart, TRƯỚC khi init từng module, ví dụ:
//     setupLocator();
//     initDiscoveryModule(sl);
//     initCatalogModule(sl);
//     initReaderModule(sl);
//     initLibraryModule(sl);
//   Sau đó mới init các tài nguyên cần await (vd: await sl<LibraryLocalDataSource>().init(); )
//
// NGUYÊN TẮC ĐĂNG KÝ
// - Dùng isRegistered<T>() để tránh double-register khi hot-reload.
// - Phân biệt dạng đăng ký:
//     registerSingleton    : tạo ngay và giữ một instance duy nhất
//     registerLazySingleton: tạo lần đầu khi được yêu cầu (thường dùng cho repo/datasource/Dio)
//     registerFactory      : tạo mới mỗi lần resolve (thường dùng cho BLoC/ViewModel)
// - Không side-effect nặng trong locator (mở file, I/O). Những thứ cần await làm ở bootstrap.
//
// VÍ DỤ (gợi ý, để ở module tương ứng, không đặt ở đây):
// ----------------------------------------------------------------------------
// void initDiscoveryModule(GetIt sl) {
//   if (!sl.isRegistered<DiscoveryRemoteDataSource>()) {
//     sl.registerLazySingleton(() => DiscoveryRemoteDataSource(sl<Dio>()));
//   }
//   if (!sl.isRegistered<DiscoveryRepository>()) {
//     sl.registerLazySingleton<DiscoveryRepository>(
//       () => DiscoveryRepositoryImpl(sl<DiscoveryRemoteDataSource>()),
//     );
//   }
//   if (!sl.isRegistered<GetTrending>()) {
//     sl.registerLazySingleton(() => GetTrending(sl<DiscoveryRepository>()));
//   }
//   sl.registerFactory(() => DiscoveryBloc(getTrending: sl<GetTrending>(), getLatest: sl<GetLatestUpdates>()));
// }
// ----------------------------------------------------------------------------
//
// LƯU Ý HOT-RELOAD
// - Trong Dev, hot-reload có thể gọi lại bootstrap. Hãy luôn bọc đăng ký bằng
//   !sl.isRegistered<T>() để không ném exception vì trùng binding.
//
// TỔNG KẾT
// - File này là “điểm vào DI” ở mức app shell. Nội dung có thể rỗng (như hiện tại),
//   vì đăng ký chi tiết nằm ở các module. Nhưng giữ một wrapper setupLocator()
//   giúp codebase rõ ràng, có convention thống nhất.

import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

/// setupLocator()
/// - Hàm khởi tạo “khung” DI ở cấp app shell.
/// - Có thể rỗng nếu toàn bộ đăng ký nằm trong các hàm init module.
/// - Giữ lại để:
///   + Chuẩn hóa entry point DI.
///   + Dễ cắm thêm các binding dùng chung toàn app (vd: Logger, ConfigReader) nếu cần.
void setupLocator() {
  // Ví dụ nếu muốn đăng ký các dịch vụ “toàn cục” dùng chung cho mọi module,
  // có thể đặt ở đây. Nhớ kiểm tra isRegistered trước khi đăng ký:
  //
  // if (!sl.isRegistered<Logger>()) {
  //   sl.registerLazySingleton<Logger>(() => Logger());
  // }
  //
  // Còn hiện tại, ta để rỗng và giao việc đăng ký chi tiết cho bootstrap + các module init.
}
