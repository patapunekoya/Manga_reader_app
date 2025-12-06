// lib/main.dart
//
// PURPOSE / CHỨC NĂNG
// - Điểm vào (entrypoint) của ứng dụng Flutter.
// - Thực hiện khởi động hạ tầng (bootstrap) trước, sau đó khởi tạo router và runApp.
//
// THỨ TỰ KHỞI ĐỘNG
// 1) await Firebase.initializeApp() -> Cần chạy trước mọi thứ
// 2) await bootstrap();             -> đảm bảo tất cả dependency đã sẵn sàng
// 3) final router = ...;            -> tạo GoRouter sau khi DI đã có đủ binding
// 4) runApp(...)                    -> bắn ứng dụng lên cây widget
//


import 'dart:async';
import 'package:flutter/material.dart';

// Thay đổi import: Dùng shared_dependencies
import 'package:shared_dependencies/shared_dependencies.dart'; // Chứa FirebaseCore

import 'firebase_options.dart';
import 'bootstrap.dart';
import 'routes/app_router.dart';
import 'app.dart';

void main() {
  // Bắt lỗi async toàn cục (tuỳ chọn, giúp debug/log ổn hơn)
  runZonedGuarded(() async {
    // Bắt buộc phải gọi trước khi sử dụng các plugin Flutter, bao gồm Firebase
    WidgetsFlutterBinding.ensureInitialized(); 
    
    // 1. KHỞI TẠO FIREBASE
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Khởi động hạ tầng DI/Module
    await bootstrap();

    // 3. Router nên tạo SAU bootstrap để chắc chắn DI đã sẵn sàng
    final router = AppRouter();

    runApp(MangaReaderApp(router: router));
  }, (error, stack) {
    // TODO: log về analytics/Crashlytics/Sentry nếu có
    // print('Uncaught async error: $error\n$stack');
  });
}