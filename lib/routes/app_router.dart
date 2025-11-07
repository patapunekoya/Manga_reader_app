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
/// Điều hướng các màn chính:
/// - /home      -> HomeShellPage (trong MainShell + bottom nav)
/// - /search    -> SearchShellPage (trong MainShell + bottom nav)
/// - /library   -> LibraryShellPage (trong MainShell + bottom nav)
/// - /manga/:mangaId        -> MangaDetailShellPage (KHÔNG bottom nav; nhận ?from=home|search|library)
/// - /reader/:chapterId     -> ReaderShellPage (KHÔNG bottom nav, full-screen)
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
      // Đọc ?from=home|search|library NGAY tại router và truyền xuống,
      // tránh gọi InheritedWidget trong initState bên trong page.
      GoRoute(
        path: '/manga/:mangaId',
        builder: (context, state) {
          final mangaId = state.pathParameters['mangaId'] ?? '';
          final origin = (state.uri.queryParameters['from'] ?? 'home').toLowerCase();
          return MangaDetailShellPage(
            mangaId: mangaId,
            origin: origin, // <— truyền để Back biết quay tab nào
          );
        },
      ),

      // ================== READER ==================
      // YÊU CẦU ĐẦY ĐỦ:
      // - path param: chapterId  (chương đang mở)
      // - query param:
      //      mangaId=xxx
      //      page=12 (page index resume)
      //      mangaTitle=...
      //      coverImageUrl=...
      // - extra (Map<String,dynamic>):
      //      {
      //        "chapters": <List<String>>,      // danh sách chapterId theo thứ tự đọc
      //        "currentIndex": <int>,           // vị trí hiện tại
      //        "chapterNumbers": <List<String>> // số chương song song với chapters
      //      }
      GoRoute(
        path: '/reader/:chapterId',
        builder: (context, state) {
          // Lấy id manga để quay lại detail
          final mangaId = state.uri.queryParameters['mangaId'] ?? '';

          // page resume
          final pageIndexStr = state.uri.queryParameters['page'] ?? '0';
          final initialPageIndex = int.tryParse(pageIndexStr) ?? 0;

          // chapterId hiện tại (lấy từ path)
          final currentChapterId = state.pathParameters['chapterId'] ?? '';

          // Đọc extra an toàn
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;

          // Danh sách chapterId (fallback 1 phần tử để tránh crash)
          final List<String> chapters =
              (extra?['chapters'] is List)
                  ? List<String>.from(extra!['chapters'] as List)
                  : <String>[currentChapterId];

          // Danh sách số chương tương ứng (song song với chapters)
          final List<String>? chapterNumbers =
              (extra?['chapterNumbers'] is List)
                  ? (extra!['chapterNumbers'] as List).map((e) => e.toString()).toList()
                  : null;

          // Metadata manga (để lưu progress/hiển thị)
          final String mangaTitle = state.uri.queryParameters['mangaTitle'] ?? '';
          final String? coverImageUrl = state.uri.queryParameters['coverImageUrl'];

          // Index hiện tại
          int currentIndex =
              (extra?['currentIndex'] is int)
                  ? extra!['currentIndex'] as int
                  : chapters.indexOf(currentChapterId);
          if (currentIndex < 0) currentIndex = 0;

          return ReaderShellPage(
            mangaId: mangaId,
            chapters: chapters,
            currentIndex: currentIndex,
            initialPageIndex: initialPageIndex,
            mangaTitle: mangaTitle,
            coverImageUrl: coverImageUrl,
            chapterNumbers: chapterNumbers,
          );
        },
      ),
    ],
  );
}
