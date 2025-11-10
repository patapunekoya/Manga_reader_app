import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../page/main_shell.dart';
import '../page/manga_detail_shell_page.dart';
import '../page/reader_shell_page.dart';

/// AppRouter
/// - /home, /search, /library: vào MainShell(currentIndex) không transition,
///   hiệu ứng lướt nằm trong MainShell (PageView.animateToPage)
/// - /manga/:mangaId: slide-in
/// - /reader/:chapterId: slide-in full-screen
class AppRouter {
  AppRouter();

  // Helper tạo slide transition cho các trang đẩy chồng lên shell
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

  late final GoRouter config = GoRouter(
    initialLocation: '/home',
    routes: [
      // ================== TABS (trong MainShell + PageView) ==================
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

      // ================== MANGA DETAIL ==================
      // Đọc ?from=home|search|library và truyền xuống để back đúng tab.
      GoRoute(
        path: '/manga/:mangaId',
        pageBuilder: (context, state) {
          final mangaId = state.pathParameters['mangaId'] ?? '';
          final origin =
              (state.uri.queryParameters['from'] ?? 'home').toLowerCase();
          return _slidePage(
            child: MangaDetailShellPage(
              mangaId: mangaId,
              origin: origin,
            ),
          );
        },
      ),

      // ================== READER ==================
      GoRoute(
        path: '/reader/:chapterId',
        pageBuilder: (context, state) {
          final mangaId = state.uri.queryParameters['mangaId'] ?? '';
          final pageIndexStr = state.uri.queryParameters['page'] ?? '0';
          final initialPageIndex = int.tryParse(pageIndexStr) ?? 0;

          final currentChapterId = state.pathParameters['chapterId'] ?? '';

          // Đọc extra an toàn
          final extra =
              state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;

          // Danh sách chapterId (fallback 1 phần tử để tránh crash)
          final List<String> chapters = (extra?['chapters'] is List)
              ? List<String>.from(extra!['chapters'] as List)
              : <String>[currentChapterId];

          // Danh sách số chương tương ứng
          final List<String>? chapterNumbers = (extra?['chapterNumbers'] is List)
              ? (extra!['chapterNumbers'] as List)
                  .map((e) => e.toString())
                  .toList()
              : null;

          // Metadata hiển thị
          final String mangaTitle = state.uri.queryParameters['mangaTitle'] ?? '';
          final String? coverImageUrl = state.uri.queryParameters['coverImageUrl'];

          // Vị trí hiện tại
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
