// lib/main.dart
//
// PURPOSE / CHỨC NĂNG
// - Điểm vào (entrypoint) của ứng dụng Flutter.
// - Thực hiện khởi động hạ tầng (bootstrap) trước, sau đó khởi tạo router và runApp.
//
// THỨ TỰ KHỞI ĐỘNG
// 1) await bootstrap();   -> đảm bảo tất cả dependency đã sẵn sàng
// 2) final router = ...;  -> tạo GoRouter sau khi DI đã có đủ binding
// 3) runApp(...)          -> bắn ứng dụng lên cây widget
//


import 'dart:async';
import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'routes/app_router.dart';
import 'app.dart';

void main() {
  // Bắt lỗi async toàn cục (tuỳ chọn, giúp debug/log ổn hơn)
  runZonedGuarded(() async {
    // bootstrap() đã tự gọi WidgetsFlutterBinding.ensureInitialized()
    await bootstrap();

    // Router nên tạo SAU bootstrap để chắc chắn DI đã sẵn sàng
    final router = AppRouter();

    runApp(MangaReaderApp(router: router));
  }, (error, stack) {
    // TODO: log về analytics/Crashlytics/Sentry nếu có
    // print('Uncaught async error: $error\n$stack');
  });
}
