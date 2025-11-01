// lib/di/locator.dart
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

/// Hàm này được gọi trong bootstrap.dart để đăng ký
/// toàn bộ repository, data source, usecase, bloc factory...
void setupLocator() {
  // Ở đây bản thân app shell sẽ KHÔNG đăng ký chi tiết từng module.
  // bootstrap.dart sẽ gọi các hàm init riêng của từng module
  // (ví dụ: initDiscoveryModule(sl), initLibraryModule(sl), v.v.)
  //
  // Nếu ông muốn, có thể để trống ở đây và làm mọi thứ trong bootstrap.
  // Nhưng mình vẫn giữ cái wrapper này cho rõ intention.
}
