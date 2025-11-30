import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart'; 
import 'package:auth/auth.dart'; 

import '../page/main_shell.dart';
import '../page/manga_detail_shell_page.dart';
import '../page/reader_shell_page.dart';


/// ===========================================================
/// File: routes/app_router.dart
/// CẬP NHẬT: Xóa refreshListenable/redirect để tránh lỗi ép kiểu runtime.
/// ===========================================================
class AppRouter {
  AppRouter();

  // -----------------------------------------------------------
  // Helper: tạo CustomTransitionPage với hiệu ứng slide-in. (GIỮ NGUYÊN)
  // -----------------------------------------------------------
  CustomTransitionPage<T> _slidePage<T>({
    required Widget child,
    Offset begin = const Offset(1, 0),
  }) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: begin, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // -----------------------------------------------------------
  // GoRouter cấu hình chính cho app.
  // -----------------------------------------------------------
  late final GoRouter config = GoRouter(
    // XÓA: refreshListenable: _getAuthBlocListenable(),
    
    initialLocation: '/home',
    
    // XÓA: redirect: (context, state) { ... }
    redirect: (context, state) {
        // HÀM REDIRECT NÀY CHỈ CÒN ĐỂ XỬ LÝ VIỆC ĐI TỚI CÁC TRANG CẦN BẢO VỆ NẾU CÓ.
        // NHƯNG LOGIC CHÍNH ĐÃ CHUYỂN QUA APP.DART/MAIN.DART
        
        // Bạn có thể giữ lại logic này nếu muốn Router tự xử lý việc chuyển hướng sau Login/Register thành công
        final authBloc = GetIt.instance<AuthStatusBloc>();
        final isAuthenticated = authBloc.state.status == AuthStatus.authenticated;
        final path = state.uri.path;
        final isLoggingIn = path == '/login';
        final isRegistering = path == '/register';

        // Nếu đã đăng nhập và đang cố gắng truy cập trang Auth, chuyển về Home
        if (isAuthenticated && (isLoggingIn || isRegistering)) {
            return '/home';
        }
        
        // Nếu không có lỗi, tiếp tục
        return null; 
    },
    
    routes: [
      // ================== AUTH ROUTES (MỚI) ==================
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(), 
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(), 
        ),
      ),

      // ================== TABS ==================
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 0),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 1),
        ),
      ),
      GoRoute(
        path: '/library',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 2),
        ),
      ),

      // THÊM ROUTE MỚI
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(currentIndex: 3), // Tab thứ 4
        ),
      ),

      // ================== MANGA DETAIL (ĐÃ CẬP NHẬT) ==================
      GoRoute(
        path: '/manga/:mangaId',
        pageBuilder: (context, state) {
          final mangaId = state.pathParameters['mangaId'] ?? '';
          final origin =
              (state.uri.queryParameters['from'] ?? 'home').toLowerCase();
          
          final resumeChapterId = state.uri.queryParameters['resume_chapter'];

          return _slidePage(
            child: MangaDetailShellPage(
              mangaId: mangaId,
              origin: origin,
              resumeChapterId: resumeChapterId, 
            ),
          );
        },
      ),

      // ================== READER (GIỮ NGUYÊN) ==================
      GoRoute(
        path: '/reader/:chapterId',
        pageBuilder: (context, state) {
          // Thông tin từ query
          final mangaId = state.uri.queryParameters['mangaId'] ?? '';
          final pageIndexStr = state.uri.queryParameters['page'] ?? '0';
          final initialPageIndex = int.tryParse(pageIndexStr) ?? 0;

          // Param đường dẫn
          final currentChapterId = state.pathParameters['chapterId'] ?? '';

          // Đọc extra an toàn (Map<String, dynamic> hoặc null)
          final extra =
              state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;

          // Danh sách chapterId: nếu không có, fallback [currentChapterId]
          final List<String> chapters = (extra?['chapters'] is List)
              ? List<String>.from(extra!['chapters'] as List)
              : <String>[currentChapterId];

          // Danh sách số chương tương ứng (nếu có). Ép tất cả về String để hiển thị ổn định.
          final List<String>? chapterNumbers = (extra?['chapterNumbers'] is List)
              ? (extra!['chapterNumbers'] as List)
                  .map((e) => e.toString())
                  .toList()
              : null;

          // Metadata hiển thị nhẹ: tiêu đề manga, ảnh bìa
          final String mangaTitle = state.uri.queryParameters['mangaTitle'] ?? '';
          final String? coverImageUrl = state.uri.queryParameters['coverImageUrl'];

          // Vị trí chương hiện tại trong danh sách
          int currentIndex = (extra?['currentIndex'] is int)
              ? extra!['currentIndex'] as int
              : chapters.indexOf(currentChapterId);
          if (currentIndex < 0) currentIndex = 0;

          return _slidePage(
            child: ReaderShellPage(
              mangaId: mangaId,
              chapters: chapters,
              currentIndex: currentIndex,
              initialPageIndex: initialPageIndex,
              mangaTitle: mangaTitle,
              coverImageUrl: coverImageUrl,
              chapterNumbers: chapterNumbers,
            ),
          );
        },
      ),
    ],
  );
}