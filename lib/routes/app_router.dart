// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../page/main_shell.dart';
import '../page/home_shell_page.dart';
import '../page/search_shell_page.dart';
import '../page/library_shell_page.dart';
import '../page/manga_detail_shell_page.dart';
import '../page/reader_shell_page.dart';

/// AppRouter
/// Điều hướng tất cả màn chính:
/// - /home      -> HomeShellPage (trong MainShell + bottom nav)
/// - /search    -> SearchShellPage (trong MainShell + bottom nav)
/// - /library   -> LibraryShellPage (trong MainShell + bottom nav)
///
/// - /manga/:mangaId
///     -> MangaDetailShellPage (KHÔNG bottom nav)
///
/// - /reader/:chapterId
///     -> ReaderShellPage (KHÔNG bottom nav, full-screen)
///
/// initialLocation = '/home' để mở app vào tab Home.
class AppRouter {
  AppRouter();

  late final GoRouter config = GoRouter(
    initialLocation: '/home',
    routes: [
      // ================== HOME TAB ==================
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return MainShell(
            currentIndex: 0,
            child: const HomeShellPage(),
          );
        },
      ),

      // ================== SEARCH TAB ==================
      GoRoute(
        path: '/search',
        builder: (context, state) {
          return MainShell(
            currentIndex: 1,
            child: const SearchShellPage(),
          );
        },
      ),

      // ================== LIBRARY TAB ==================
      GoRoute(
        path: '/library',
        builder: (context, state) {
          return MainShell(
            currentIndex: 2,
            child: const LibraryShellPage(),
          );
        },
      ),

      // ================== MANGA DETAIL ==================
      // Không có bottom nav
      GoRoute(
        path: '/manga/:mangaId',
        builder: (context, state) {
          final mangaId = state.pathParameters['mangaId'] ?? '';
          return MangaDetailShellPage(
            mangaId: mangaId,
          );
        },
      ),

      // ================== READER ==================
      // Không có bottom nav, full-screen đọc chương
      //
      // YÊU CẦU ĐẦY ĐỦ:
      // - path param: chapterId  (chương đang mở)
      // - query param:
      //      mangaId=xxx
      //      page=12 (page index resume, int)
      // - extra (Map<String,dynamic>):
      //      {
      //        "chapters": <List<String>>  // danh sách tất cả chapterId theo thứ tự đọc
      //        "currentIndex": <int>       // vị trí của chapterId hiện tại trong list trên
      //      }
      //
      // Nếu thiếu extra => fallback an toàn: chỉ có 1 chương, không next/prev.
      GoRoute(
        path: '/reader/:chapterId',
        builder: (context, state) {
          // lấy mangaId để quay lại detail
          final mangaId = state.uri.queryParameters['mangaId'] ?? '';

          // page resume
          final pageIndexStr = state.uri.queryParameters['page'] ?? '0';
          final initialPageIndex = int.tryParse(pageIndexStr) ?? 0;

          // chapterId hiện tại (lấy từ path)
          final currentChapterId =
              state.pathParameters['chapterId'] ?? '';

          // đọc extra
          final extra = state.extra as Map<String, dynamic>?;

          // nếu MangaDetailShellPage có truyền extra thì dùng,
          // còn không thì fallback 1-element list để tránh crash
          final List<String> chapters =
              (extra?['chapters'] as List<String>?) ??
              <String>[currentChapterId];

          // index của currentChapterId trong list chapters
          // - ưu tiên lấy thẳng từ extra['currentIndex'] nếu có
          // - nếu không có thì tự tính từ chapters
          int currentIndex =
              extra?['currentIndex'] as int? ??
              chapters.indexOf(currentChapterId);

          if (currentIndex < 0) {
            currentIndex = 0;
          }

          return ReaderShellPage(
            mangaId: mangaId,
            chapters: chapters,
            currentIndex: currentIndex,
            initialPageIndex: initialPageIndex,
          );
        },
      ),
    ],
  );
}
