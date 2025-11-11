// lib/app.dart

import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

/// ------------------------------------------------------------
/// File: app.dart
/// Vai trò chính:
///   - Khởi tạo "App shell" của ứng dụng bằng MaterialApp.router.
///   - Gắn cấu hình điều hướng (router) đã được chuẩn bị ở AppRouter.
///   - Thiết lập theme (light/dark) và chiến lược ThemeMode cho toàn app.
/// Điểm vào/ra:
///   - Input: một thể hiện [AppRouter] đã được cấu hình (inject từ bootstrap/DI).
///   - Output: cây widget root của ứng dụng (MaterialApp.router).
/// Phụ thuộc:
///   - [AppRouter] (routes/app_router.dart): cung cấp [router.config] cho navigation.
///   - [buildAppTheme], [buildDarkTheme] (theme/app_theme.dart): cung cấp ThemeData.
/// Quy ước & Lưu ý:
///   - `themeMode` hiện đặt là [ThemeMode.dark] để luôn chạy giao diện dark.
///     Nếu muốn theo hệ thống, đổi sang [ThemeMode.system].
///   - Không khởi tạo DI trong file này. Tất cả DI phải diễn ra ở bootstrap trước đó.
///   - Đây là lớp "vỏ" (shell) mỏng, không chứa logic nghiệp vụ.
/// ------------------------------------------------------------
class MangaReaderApp extends StatelessWidget {
  /// Router cấu hình sẵn (GoRouter hoặc wrapper) được inject từ bên ngoài.
  /// Lý do inject: tách biệt App shell khỏi chi tiết navigation, dễ test và thay thế.
  final AppRouter router;

  /// [MangaReaderApp] là root widget của ứng dụng.
  /// - [router] bắt buộc: truyền vào từ bootstrap sau khi đã đăng ký tất cả routes/guards.
  const MangaReaderApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router:
    //   - Bản MaterialApp dùng Router API mới (Navigator 2.0).
    //   - Nhận routerConfig từ AppRouter để điều hướng dựa trên declarative routing.
    return MaterialApp.router(
      // Tắt banner "DEBUG" ở góc màn hình khi build debug.
      debugShowCheckedModeBanner: false,

      // Tên ứng dụng (dùng cho task switcher, Android Recents, v.v.)
      title: 'Manga Reader',

      // Theme sáng mặc định (nếu cần). Ở đây vẫn khai báo đầy đủ để tái dụng sau này.
      theme: buildAppTheme(),

      // Theme tối: đang là theme chính của app.
      darkTheme: buildDarkTheme(),

      // Chế độ theme: ép dùng dark. Đổi sang ThemeMode.system nếu muốn theo hệ thống.
      themeMode: ThemeMode.dark,

      // Cấu hình router đã chuẩn bị từ AppRouter (định nghĩa routes, redirect, observers…)
      routerConfig: router.config,
    );
  }
}
